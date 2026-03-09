import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/attachment_ingestion_service.dart';
import '../application/attachment_picker_service.dart';
import '../data/chat_api_client.dart';
import '../data/local/app_database.dart';
import '../domain/chat_models.dart';

class ChatController extends ChangeNotifier {
  final AppDatabase appDatabase;
  final ChatApiClient chatApiClient;
  final AttachmentPickerService attachmentPickerService;
  final AttachmentIngestionService attachmentIngestionService;

  final List<ChatMessageRecord> _messages = <ChatMessageRecord>[];
  final List<MemoryConfirmation> _memoryConfirmations = <MemoryConfirmation>[];
  final List<PendingAttachmentDraft> _pendingAttachments =
      <PendingAttachmentDraft>[];

  PrepareDecision? _pendingClarificationDecision;
  String? _pendingClarificationMessageId;
  bool _isBusy = false;
  bool _isLoadingOlder = false;
  int _pageSize = 30;
  String? _errorMessage;

  ChatController({
    required this.appDatabase,
    required this.chatApiClient,
    AttachmentPickerService? attachmentPickerService,
    AttachmentIngestionService? attachmentIngestionService,
  }) : attachmentPickerService =
           attachmentPickerService ?? FilePickerAttachmentPicker(),
       attachmentIngestionService =
           attachmentIngestionService ??
           AttachmentIngestionService(
             appDatabase: appDatabase,
             chatApiClient: chatApiClient,
           );

  List<ChatMessageRecord> get messages =>
      List<ChatMessageRecord>.unmodifiable(_messages);
  List<MemoryConfirmation> get memoryConfirmations =>
      List<MemoryConfirmation>.unmodifiable(_memoryConfirmations);
  ClarificationPrompt? get clarificationPrompt =>
      _pendingClarificationDecision?.clarificationPrompt;
  bool get isBusy => _isBusy;
  bool get isLoadingOlder => _isLoadingOlder;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;
  List<PendingAttachmentDraft> get pendingAttachments =>
      List<PendingAttachmentDraft>.unmodifiable(_pendingAttachments);
  bool get hasPendingAttachments => _pendingAttachments.isNotEmpty;

  Future<void> loadInitialState() async {
    _messages
      ..clear()
      ..addAll(await appDatabase.fetchVisibleMessages(limit: _pageSize));
    await _refreshConfirmations();
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    if (_isLoadingOlder) {
      return;
    }

    _isLoadingOlder = true;
    notifyListeners();

    _pageSize += 20;
    _messages
      ..clear()
      ..addAll(await appDatabase.fetchVisibleMessages(limit: _pageSize));

    _isLoadingOlder = false;
    notifyListeners();
  }

  Future<void> pickAttachments() async {
    if (_isBusy) {
      return;
    }

    try {
      final List<PendingAttachmentDraft> pickedAttachments =
          await attachmentPickerService.pickAttachments();
      await addPendingAttachments(pickedAttachments);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> addPendingAttachments(
    List<PendingAttachmentDraft> attachments,
  ) async {
    if (attachments.isEmpty) {
      return;
    }

    final int currentImageCount = _pendingAttachments
        .where(
          (PendingAttachmentDraft attachment) =>
              attachment.kind == ChatAttachmentKind.image,
        )
        .length;
    final int incomingImageCount = attachments
        .where(
          (PendingAttachmentDraft attachment) =>
              attachment.kind == ChatAttachmentKind.image,
        )
        .length;
    if (currentImageCount + incomingImageCount > 10) {
      _errorMessage = 'You can attach up to 10 images in one message.';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _pendingAttachments.addAll(attachments);
    notifyListeners();
  }

  void removePendingAttachment(String attachmentId) {
    _pendingAttachments.removeWhere(
      (PendingAttachmentDraft attachment) => attachment.id == attachmentId,
    );
    notifyListeners();
  }

  Future<void> submitMessage(String input) async {
    final String trimmedInput = input.trim();
    if ((trimmedInput.isEmpty && _pendingAttachments.isEmpty) || _isBusy) {
      return;
    }
    final List<PendingAttachmentDraft> pendingAttachments =
        List<PendingAttachmentDraft>.from(_pendingAttachments);

    _errorMessage = null;
    _pendingClarificationDecision = null;
    _pendingClarificationMessageId = null;
    _isBusy = true;
    _pendingAttachments.clear();
    notifyListeners();

    final ChatMessageRecord userMessage = await appDatabase.insertMessage(
      role: ChatMessageRole.user,
      content: trimmedInput,
    );
    _messages.add(
      userMessage.copyWith(
        attachments: pendingAttachments
            .map(_pendingAttachmentToRecord)
            .toList(growable: false),
      ),
    );
    notifyListeners();

    try {
      if (pendingAttachments.isNotEmpty) {
        await attachmentIngestionService.ingestAttachments(
          messageId: userMessage.id,
          messageText: trimmedInput,
          pendingAttachments: pendingAttachments,
        );
        await _reloadMessages();
        await _refreshConfirmations();
      }

      if (trimmedInput.isEmpty) {
        return;
      }

      final PrepareDecision prepareDecision = await chatApiClient.prepare(
        message: trimmedInput,
        recentMessages: _recentMessagesForPrepare(),
      );

      await _applyPrepareDecision(
        prepareDecision: prepareDecision,
        userMessage: userMessage,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> resolveClarificationAsMemory() async {
    final PrepareDecision? prepareDecision = _pendingClarificationDecision;
    final String? messageId = _pendingClarificationMessageId;
    if (prepareDecision == null || messageId == null) {
      return;
    }

    _isBusy = true;
    notifyListeners();

    try {
      await appDatabase.replaceMemoryPlansForMessage(
        sourceMessageId: messageId,
        memoryWritePlans: prepareDecision.memoryWritePlans,
      );

      _pendingClarificationDecision = null;
      _pendingClarificationMessageId = null;
      await _refreshConfirmations();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> resolveClarificationAsQuestion() async {
    final PrepareDecision? prepareDecision = _pendingClarificationDecision;
    final String? messageId = _pendingClarificationMessageId;
    final ChatMessageRecord? userMessage = _messages
        .where((ChatMessageRecord record) => record.id == messageId)
        .cast<ChatMessageRecord?>()
        .firstOrNull;
    if (prepareDecision == null || messageId == null || userMessage == null) {
      return;
    }

    _pendingClarificationDecision = null;
    _pendingClarificationMessageId = null;
    _isBusy = true;
    notifyListeners();

    try {
      final PrepareDecision queryDecision = PrepareDecision(
        outcome: PrepareOutcome.query,
        assistantDraft: '',
        tags: prepareDecision.tags,
        entities: prepareDecision.entities,
        literalTerms: prepareDecision.literalTerms,
        timeFilters: prepareDecision.timeFilters,
        queryEmbedding: prepareDecision.queryEmbedding,
        clarificationPrompt: null,
        memoryWritePlans: prepareDecision.memoryWritePlans,
        retrievalPlan: prepareDecision.retrievalPlan,
      );

      final List<RetrievedMemory> retrievedMemories = await appDatabase
          .retrieveMemories(prepareDecision: queryDecision);
      await _streamAssistantResponse(
        message: userMessage.content,
        prepareDecision: queryDecision,
        retrievedMemories: retrievedMemories,
        userMessageId: messageId,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    final String trimmedContent = newContent.trim();
    if (trimmedContent.isEmpty || _isBusy) {
      return;
    }

    _errorMessage = null;
    _isBusy = true;
    notifyListeners();

    try {
      final PrepareDecision prepareDecision = await chatApiClient.prepare(
        message: trimmedContent,
        recentMessages: _recentMessagesForPrepare(
          messageId: messageId,
          newContent: trimmedContent,
        ),
      );

      await appDatabase.editMessage(
        messageId: messageId,
        newContent: trimmedContent,
      );
      await _syncEditedMessageMemories(
        messageId: messageId,
        prepareDecision: prepareDecision,
      );
      await _reloadMessages();
      await _refreshConfirmations();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (_pendingClarificationMessageId == messageId) {
      _pendingClarificationDecision = null;
      _pendingClarificationMessageId = null;
    }
    await appDatabase.softDeleteMessage(messageId);
    await _refreshConfirmations();
    await _reloadMessages();
  }

  Future<void> _applyPrepareDecision({
    required PrepareDecision prepareDecision,
    required ChatMessageRecord userMessage,
  }) async {
    if (prepareDecision.outcome == PrepareOutcome.memoryOnly ||
        prepareDecision.outcome == PrepareOutcome.mixed ||
        prepareDecision.outcome == PrepareOutcome.briefRefusal) {
      for (final MemoryWritePlan memoryWritePlan
          in prepareDecision.memoryWritePlans) {
        await appDatabase.insertMemoryPlan(
          sourceMessageId: userMessage.id,
          memoryWritePlan: memoryWritePlan,
        );
      }
      await _refreshConfirmations();
    }

    if (prepareDecision.outcome == PrepareOutcome.memoryOnly) {
      return;
    }

    if (prepareDecision.outcome == PrepareOutcome.clarify) {
      _pendingClarificationDecision = prepareDecision;
      _pendingClarificationMessageId = userMessage.id;
      return;
    }

    if (prepareDecision.outcome == PrepareOutcome.briefRefusal &&
        prepareDecision.assistantDraft.isNotEmpty) {
      final ChatMessageRecord assistantMessage = await appDatabase
          .insertMessage(
            role: ChatMessageRole.assistant,
            content: prepareDecision.assistantDraft,
          );
      await appDatabase.pairMessages(
        userMessageId: userMessage.id,
        assistantMessageId: assistantMessage.id,
      );
      _updateLocalPairing(
        userMessageId: userMessage.id,
        assistantMessageId: assistantMessage.id,
      );
      _messages.add(assistantMessage.copyWith(pairedMessageId: userMessage.id));
      return;
    }

    final List<RetrievedMemory> retrievedMemories = await appDatabase
        .retrieveMemories(prepareDecision: prepareDecision);
    await _streamAssistantResponse(
      message: userMessage.content,
      prepareDecision: prepareDecision,
      retrievedMemories: retrievedMemories,
      userMessageId: userMessage.id,
    );
  }

  Future<void> _streamAssistantResponse({
    required String message,
    required PrepareDecision prepareDecision,
    required List<RetrievedMemory> retrievedMemories,
    required String userMessageId,
  }) async {
    final ChatMessageRecord assistantMessage = await appDatabase.insertMessage(
      role: ChatMessageRole.assistant,
      content: '',
    );

    await appDatabase.pairMessages(
      userMessageId: userMessageId,
      assistantMessageId: assistantMessage.id,
    );
    _updateLocalPairing(
      userMessageId: userMessageId,
      assistantMessageId: assistantMessage.id,
    );

    ChatMessageRecord currentAssistantMessage = assistantMessage;
    currentAssistantMessage = currentAssistantMessage.copyWith(
      pairedMessageId: userMessageId,
    );
    _messages.add(currentAssistantMessage);
    notifyListeners();

    await for (final String delta in chatApiClient.respond(
      message: message,
      prepareDecision: prepareDecision,
      retrievedMemories: retrievedMemories,
    )) {
      currentAssistantMessage = currentAssistantMessage.copyWith(
        content: '${currentAssistantMessage.content}$delta',
      );
      final int index = _messages.indexWhere(
        (ChatMessageRecord record) => record.id == currentAssistantMessage.id,
      );
      if (index >= 0) {
        _messages[index] = currentAssistantMessage;
      }
      await appDatabase.updateAssistantDraft(
        messageId: currentAssistantMessage.id,
        content: currentAssistantMessage.content,
      );
      notifyListeners();
    }
  }

  Future<void> _refreshConfirmations() async {
    _memoryConfirmations
      ..clear()
      ..addAll(await appDatabase.recentMemoryConfirmations());
  }

  void _updateLocalPairing({
    required String userMessageId,
    required String assistantMessageId,
  }) {
    final int userIndex = _messages.indexWhere(
      (ChatMessageRecord record) => record.id == userMessageId,
    );
    if (userIndex >= 0) {
      _messages[userIndex] = _messages[userIndex].copyWith(
        pairedMessageId: assistantMessageId,
      );
    }

    final int assistantIndex = _messages.indexWhere(
      (ChatMessageRecord record) => record.id == assistantMessageId,
    );
    if (assistantIndex >= 0) {
      _messages[assistantIndex] = _messages[assistantIndex].copyWith(
        pairedMessageId: userMessageId,
      );
    }
  }

  List<ChatMessageRecord> _recentMessagesForPrepare({
    String? messageId,
    String? newContent,
  }) {
    final List<ChatMessageRecord> latestMessages = _messages.length <= 8
        ? List<ChatMessageRecord>.from(_messages)
        : _messages.sublist(_messages.length - 8);

    return latestMessages
        .map((ChatMessageRecord message) {
          if (messageId == null ||
              newContent == null ||
              message.id != messageId) {
            return message;
          }
          return message.copyWith(content: newContent, isEdited: true);
        })
        .toList(growable: false);
  }

  Future<void> _syncEditedMessageMemories({
    required String messageId,
    required PrepareDecision prepareDecision,
  }) async {
    _pendingClarificationDecision = null;
    _pendingClarificationMessageId = null;

    if (_storesMemory(prepareDecision.outcome)) {
      await appDatabase.replaceMemoryPlansForMessage(
        sourceMessageId: messageId,
        memoryWritePlans: prepareDecision.memoryWritePlans,
      );
      return;
    }

    await appDatabase.deactivateMemoriesForMessage(messageId);
    if (prepareDecision.outcome == PrepareOutcome.clarify) {
      _pendingClarificationDecision = prepareDecision;
      _pendingClarificationMessageId = messageId;
    }
  }

  bool _storesMemory(PrepareOutcome outcome) {
    return outcome == PrepareOutcome.memoryOnly ||
        outcome == PrepareOutcome.mixed ||
        outcome == PrepareOutcome.briefRefusal;
  }

  Future<void> _reloadMessages() async {
    _messages
      ..clear()
      ..addAll(await appDatabase.fetchVisibleMessages(limit: _pageSize));
    notifyListeners();
  }

  ChatAttachmentRecord _pendingAttachmentToRecord(
    PendingAttachmentDraft attachment,
  ) {
    return ChatAttachmentRecord(
      id: attachment.id,
      kind: attachment.kind,
      displayName: attachment.displayName,
      mimeType: attachment.mimeType,
      localPath: attachment.localPath,
      byteSize: attachment.byteSize,
      status: ChatAttachmentStatus.pending,
      failureReason: null,
      rawText: null,
      summary: null,
      summaryMemoryId: null,
      createdAt: DateTime.now(),
    );
  }
}

extension _NullableFirstOrNull<T> on Iterable<T?> {
  T? get firstOrNull {
    for (final T? value in this) {
      if (value != null) {
        return value;
      }
    }
    return null;
  }
}
