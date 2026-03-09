// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEditedMeta = const VerificationMeta(
    'isEdited',
  );
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
    'is_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pairedMessageIdMeta = const VerificationMeta(
    'pairedMessageId',
  );
  @override
  late final GeneratedColumn<String> pairedMessageId = GeneratedColumn<String>(
    'paired_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    content,
    createdAt,
    updatedAt,
    isEdited,
    isDeleted,
    pairedMessageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_edited')) {
      context.handle(
        _isEditedMeta,
        isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('paired_message_id')) {
      context.handle(
        _pairedMessageIdMeta,
        pairedMessageId.isAcceptableOrUnknown(
          data['paired_message_id']!,
          _pairedMessageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      isEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_edited'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      pairedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paired_message_id'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final bool isDeleted;
  final String? pairedMessageId;
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.isEdited,
    required this.isDeleted,
    this.pairedMessageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_edited'] = Variable<bool>(isEdited);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || pairedMessageId != null) {
      map['paired_message_id'] = Variable<String>(pairedMessageId);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      isEdited: Value(isEdited),
      isDeleted: Value(isDeleted),
      pairedMessageId: pairedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(pairedMessageId),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      pairedMessageId: serializer.fromJson<String?>(json['pairedMessageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isEdited': serializer.toJson<bool>(isEdited),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'pairedMessageId': serializer.toJson<String?>(pairedMessageId),
    };
  }

  Message copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    bool? isEdited,
    bool? isDeleted,
    Value<String?> pairedMessageId = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isEdited: isEdited ?? this.isEdited,
    isDeleted: isDeleted ?? this.isDeleted,
    pairedMessageId: pairedMessageId.present
        ? pairedMessageId.value
        : this.pairedMessageId,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      pairedMessageId: data.pairedMessageId.present
          ? data.pairedMessageId.value
          : this.pairedMessageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isEdited: $isEdited, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pairedMessageId: $pairedMessageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    content,
    createdAt,
    updatedAt,
    isEdited,
    isDeleted,
    pairedMessageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isEdited == this.isEdited &&
          other.isDeleted == this.isDeleted &&
          other.pairedMessageId == this.pairedMessageId);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isEdited;
  final Value<bool> isDeleted;
  final Value<String?> pairedMessageId;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pairedMessageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String role,
    required String content,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.pairedMessageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isEdited,
    Expression<bool>? isDeleted,
    Expression<String>? pairedMessageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isEdited != null) 'is_edited': isEdited,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (pairedMessageId != null) 'paired_message_id': pairedMessageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? role,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isEdited,
    Value<bool>? isDeleted,
    Value<String?>? pairedMessageId,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      pairedMessageId: pairedMessageId ?? this.pairedMessageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (pairedMessageId.present) {
      map['paired_message_id'] = Variable<String>(pairedMessageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isEdited: $isEdited, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('pairedMessageId: $pairedMessageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageRevisionsTable extends MessageRevisions
    with TableInfo<$MessageRevisionsTable, MessageRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionContentMeta = const VerificationMeta(
    'revisionContent',
  );
  @override
  late final GeneratedColumn<String> revisionContent = GeneratedColumn<String>(
    'revision_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    revisionContent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('revision_content')) {
      context.handle(
        _revisionContentMeta,
        revisionContent.isAcceptableOrUnknown(
          data['revision_content']!,
          _revisionContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisionContentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      revisionContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision_content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessageRevisionsTable createAlias(String alias) {
    return $MessageRevisionsTable(attachedDatabase, alias);
  }
}

class MessageRevision extends DataClass implements Insertable<MessageRevision> {
  final int id;
  final String messageId;
  final String revisionContent;
  final DateTime createdAt;
  const MessageRevision({
    required this.id,
    required this.messageId,
    required this.revisionContent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['revision_content'] = Variable<String>(revisionContent);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessageRevisionsCompanion toCompanion(bool nullToAbsent) {
    return MessageRevisionsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      revisionContent: Value(revisionContent),
      createdAt: Value(createdAt),
    );
  }

  factory MessageRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRevision(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      revisionContent: serializer.fromJson<String>(json['revisionContent']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'revisionContent': serializer.toJson<String>(revisionContent),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MessageRevision copyWith({
    int? id,
    String? messageId,
    String? revisionContent,
    DateTime? createdAt,
  }) => MessageRevision(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    revisionContent: revisionContent ?? this.revisionContent,
    createdAt: createdAt ?? this.createdAt,
  );
  MessageRevision copyWithCompanion(MessageRevisionsCompanion data) {
    return MessageRevision(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      revisionContent: data.revisionContent.present
          ? data.revisionContent.value
          : this.revisionContent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRevision(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('revisionContent: $revisionContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, revisionContent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRevision &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.revisionContent == this.revisionContent &&
          other.createdAt == this.createdAt);
}

class MessageRevisionsCompanion extends UpdateCompanion<MessageRevision> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> revisionContent;
  final Value<DateTime> createdAt;
  const MessageRevisionsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.revisionContent = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MessageRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String revisionContent,
    required DateTime createdAt,
  }) : messageId = Value(messageId),
       revisionContent = Value(revisionContent),
       createdAt = Value(createdAt);
  static Insertable<MessageRevision> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? revisionContent,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (revisionContent != null) 'revision_content': revisionContent,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MessageRevisionsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? revisionContent,
    Value<DateTime>? createdAt,
  }) {
    return MessageRevisionsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      revisionContent: revisionContent ?? this.revisionContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (revisionContent.present) {
      map['revision_content'] = Variable<String>(revisionContent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('revisionContent: $revisionContent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MemoriesTable extends Memories with TableInfo<$MemoriesTable, Memory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMessageIdMeta = const VerificationMeta(
    'sourceMessageId',
  );
  @override
  late final GeneratedColumn<String> sourceMessageId = GeneratedColumn<String>(
    'source_message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceMessageId,
    content,
    createdAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Memory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_message_id')) {
      context.handle(
        _sourceMessageIdMeta,
        sourceMessageId.isAcceptableOrUnknown(
          data['source_message_id']!,
          _sourceMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceMessageIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Memory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_message_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class Memory extends DataClass implements Insertable<Memory> {
  final String id;
  final String sourceMessageId;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;
  const Memory({
    required this.id,
    required this.sourceMessageId,
    required this.content,
    required this.createdAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_message_id'] = Variable<String>(sourceMessageId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      sourceMessageId: Value(sourceMessageId),
      content: Value(content),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory Memory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memory(
      id: serializer.fromJson<String>(json['id']),
      sourceMessageId: serializer.fromJson<String>(json['sourceMessageId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceMessageId': serializer.toJson<String>(sourceMessageId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Memory copyWith({
    String? id,
    String? sourceMessageId,
    String? content,
    DateTime? createdAt,
    bool? isDeleted,
  }) => Memory(
    id: id ?? this.id,
    sourceMessageId: sourceMessageId ?? this.sourceMessageId,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Memory copyWithCompanion(MemoriesCompanion data) {
    return Memory(
      id: data.id.present ? data.id.value : this.id,
      sourceMessageId: data.sourceMessageId.present
          ? data.sourceMessageId.value
          : this.sourceMessageId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memory(')
          ..write('id: $id, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceMessageId, content, createdAt, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memory &&
          other.id == this.id &&
          other.sourceMessageId == this.sourceMessageId &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted);
}

class MemoriesCompanion extends UpdateCompanion<Memory> {
  final Value<String> id;
  final Value<String> sourceMessageId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.sourceMessageId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String id,
    required String sourceMessageId,
    required String content,
    required DateTime createdAt,
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceMessageId = Value(sourceMessageId),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Memory> custom({
    Expression<String>? id,
    Expression<String>? sourceMessageId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceMessageId != null) 'source_message_id': sourceMessageId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceMessageId,
    Value<String>? content,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return MemoriesCompanion(
      id: id ?? this.id,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceMessageId.present) {
      map['source_message_id'] = Variable<String>(sourceMessageId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmbeddingVectorsTable extends EmbeddingVectors
    with TableInfo<$EmbeddingVectorsTable, EmbeddingVector> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmbeddingVectorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorBlobMeta = const VerificationMeta(
    'vectorBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> vectorBlob = GeneratedColumn<Uint8List>(
    'vector_blob',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCanonMeta = const VerificationMeta(
    'isCanon',
  );
  @override
  late final GeneratedColumn<bool> isCanon = GeneratedColumn<bool>(
    'is_canon',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_canon" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId,
    modelName,
    vectorBlob,
    createdAt,
    isCanon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'embedding_vectors';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmbeddingVector> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('vector_blob')) {
      context.handle(
        _vectorBlobMeta,
        vectorBlob.isAcceptableOrUnknown(data['vector_blob']!, _vectorBlobMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorBlobMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_canon')) {
      context.handle(
        _isCanonMeta,
        isCanon.isAcceptableOrUnknown(data['is_canon']!, _isCanonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmbeddingVector map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmbeddingVector(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      vectorBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector_blob'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isCanon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_canon'],
      )!,
    );
  }

  @override
  $EmbeddingVectorsTable createAlias(String alias) {
    return $EmbeddingVectorsTable(attachedDatabase, alias);
  }
}

class EmbeddingVector extends DataClass implements Insertable<EmbeddingVector> {
  final String id;
  final String memoryId;
  final String modelName;
  final Uint8List vectorBlob;
  final DateTime createdAt;
  final bool isCanon;
  const EmbeddingVector({
    required this.id,
    required this.memoryId,
    required this.modelName,
    required this.vectorBlob,
    required this.createdAt,
    required this.isCanon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['model_name'] = Variable<String>(modelName);
    map['vector_blob'] = Variable<Uint8List>(vectorBlob);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_canon'] = Variable<bool>(isCanon);
    return map;
  }

  EmbeddingVectorsCompanion toCompanion(bool nullToAbsent) {
    return EmbeddingVectorsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      modelName: Value(modelName),
      vectorBlob: Value(vectorBlob),
      createdAt: Value(createdAt),
      isCanon: Value(isCanon),
    );
  }

  factory EmbeddingVector.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmbeddingVector(
      id: serializer.fromJson<String>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      vectorBlob: serializer.fromJson<Uint8List>(json['vectorBlob']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isCanon: serializer.fromJson<bool>(json['isCanon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'modelName': serializer.toJson<String>(modelName),
      'vectorBlob': serializer.toJson<Uint8List>(vectorBlob),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isCanon': serializer.toJson<bool>(isCanon),
    };
  }

  EmbeddingVector copyWith({
    String? id,
    String? memoryId,
    String? modelName,
    Uint8List? vectorBlob,
    DateTime? createdAt,
    bool? isCanon,
  }) => EmbeddingVector(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    modelName: modelName ?? this.modelName,
    vectorBlob: vectorBlob ?? this.vectorBlob,
    createdAt: createdAt ?? this.createdAt,
    isCanon: isCanon ?? this.isCanon,
  );
  EmbeddingVector copyWithCompanion(EmbeddingVectorsCompanion data) {
    return EmbeddingVector(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      vectorBlob: data.vectorBlob.present
          ? data.vectorBlob.value
          : this.vectorBlob,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCanon: data.isCanon.present ? data.isCanon.value : this.isCanon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingVector(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('modelName: $modelName, ')
          ..write('vectorBlob: $vectorBlob, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCanon: $isCanon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    memoryId,
    modelName,
    $driftBlobEquality.hash(vectorBlob),
    createdAt,
    isCanon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmbeddingVector &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.modelName == this.modelName &&
          $driftBlobEquality.equals(other.vectorBlob, this.vectorBlob) &&
          other.createdAt == this.createdAt &&
          other.isCanon == this.isCanon);
}

class EmbeddingVectorsCompanion extends UpdateCompanion<EmbeddingVector> {
  final Value<String> id;
  final Value<String> memoryId;
  final Value<String> modelName;
  final Value<Uint8List> vectorBlob;
  final Value<DateTime> createdAt;
  final Value<bool> isCanon;
  final Value<int> rowid;
  const EmbeddingVectorsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.vectorBlob = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCanon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmbeddingVectorsCompanion.insert({
    required String id,
    required String memoryId,
    required String modelName,
    required Uint8List vectorBlob,
    required DateTime createdAt,
    this.isCanon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoryId = Value(memoryId),
       modelName = Value(modelName),
       vectorBlob = Value(vectorBlob),
       createdAt = Value(createdAt);
  static Insertable<EmbeddingVector> custom({
    Expression<String>? id,
    Expression<String>? memoryId,
    Expression<String>? modelName,
    Expression<Uint8List>? vectorBlob,
    Expression<DateTime>? createdAt,
    Expression<bool>? isCanon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (modelName != null) 'model_name': modelName,
      if (vectorBlob != null) 'vector_blob': vectorBlob,
      if (createdAt != null) 'created_at': createdAt,
      if (isCanon != null) 'is_canon': isCanon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmbeddingVectorsCompanion copyWith({
    Value<String>? id,
    Value<String>? memoryId,
    Value<String>? modelName,
    Value<Uint8List>? vectorBlob,
    Value<DateTime>? createdAt,
    Value<bool>? isCanon,
    Value<int>? rowid,
  }) {
    return EmbeddingVectorsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      modelName: modelName ?? this.modelName,
      vectorBlob: vectorBlob ?? this.vectorBlob,
      createdAt: createdAt ?? this.createdAt,
      isCanon: isCanon ?? this.isCanon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (vectorBlob.present) {
      map['vector_blob'] = Variable<Uint8List>(vectorBlob.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isCanon.present) {
      map['is_canon'] = Variable<bool>(isCanon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmbeddingVectorsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('modelName: $modelName, ')
          ..write('vectorBlob: $vectorBlob, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCanon: $isCanon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryTagsTable extends MemoryTags
    with TableInfo<$MemoryTagsTable, MemoryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, memoryId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $MemoryTagsTable createAlias(String alias) {
    return $MemoryTagsTable(attachedDatabase, alias);
  }
}

class MemoryTag extends DataClass implements Insertable<MemoryTag> {
  final int id;
  final String memoryId;
  final String tag;
  const MemoryTag({
    required this.id,
    required this.memoryId,
    required this.tag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  MemoryTagsCompanion toCompanion(bool nullToAbsent) {
    return MemoryTagsCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      tag: Value(tag),
    );
  }

  factory MemoryTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryTag(
      id: serializer.fromJson<int>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'tag': serializer.toJson<String>(tag),
    };
  }

  MemoryTag copyWith({int? id, String? memoryId, String? tag}) => MemoryTag(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    tag: tag ?? this.tag,
  );
  MemoryTag copyWithCompanion(MemoryTagsCompanion data) {
    return MemoryTag(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryTag(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryTag &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.tag == this.tag);
}

class MemoryTagsCompanion extends UpdateCompanion<MemoryTag> {
  final Value<int> id;
  final Value<String> memoryId;
  final Value<String> tag;
  const MemoryTagsCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.tag = const Value.absent(),
  });
  MemoryTagsCompanion.insert({
    this.id = const Value.absent(),
    required String memoryId,
    required String tag,
  }) : memoryId = Value(memoryId),
       tag = Value(tag);
  static Insertable<MemoryTag> custom({
    Expression<int>? id,
    Expression<String>? memoryId,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (tag != null) 'tag': tag,
    });
  }

  MemoryTagsCompanion copyWith({
    Value<int>? id,
    Value<String>? memoryId,
    Value<String>? tag,
  }) {
    return MemoryTagsCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryTagsCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

class $EntitiesTable extends Entities with TableInfo<$EntitiesTable, Entity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mentionCountMeta = const VerificationMeta(
    'mentionCount',
  );
  @override
  late final GeneratedColumn<int> mentionCount = GeneratedColumn<int>(
    'mention_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _summaryMemoryCountMeta =
      const VerificationMeta('summaryMemoryCount');
  @override
  late final GeneratedColumn<int> summaryMemoryCount = GeneratedColumn<int>(
    'summary_memory_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPromotedMeta = const VerificationMeta(
    'isPromoted',
  );
  @override
  late final GeneratedColumn<bool> isPromoted = GeneratedColumn<bool>(
    'is_promoted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_promoted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstMentionedAtMeta = const VerificationMeta(
    'firstMentionedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstMentionedAt =
      GeneratedColumn<DateTime>(
        'first_mentioned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastMentionedAtMeta = const VerificationMeta(
    'lastMentionedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMentionedAt =
      GeneratedColumn<DateTime>(
        'last_mentioned_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    summary,
    mentionCount,
    summaryMemoryCount,
    isPromoted,
    createdAt,
    updatedAt,
    firstMentionedAt,
    lastMentionedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('mention_count')) {
      context.handle(
        _mentionCountMeta,
        mentionCount.isAcceptableOrUnknown(
          data['mention_count']!,
          _mentionCountMeta,
        ),
      );
    }
    if (data.containsKey('summary_memory_count')) {
      context.handle(
        _summaryMemoryCountMeta,
        summaryMemoryCount.isAcceptableOrUnknown(
          data['summary_memory_count']!,
          _summaryMemoryCountMeta,
        ),
      );
    }
    if (data.containsKey('is_promoted')) {
      context.handle(
        _isPromotedMeta,
        isPromoted.isAcceptableOrUnknown(data['is_promoted']!, _isPromotedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('first_mentioned_at')) {
      context.handle(
        _firstMentionedAtMeta,
        firstMentionedAt.isAcceptableOrUnknown(
          data['first_mentioned_at']!,
          _firstMentionedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_mentioned_at')) {
      context.handle(
        _lastMentionedAtMeta,
        lastMentionedAt.isAcceptableOrUnknown(
          data['last_mentioned_at']!,
          _lastMentionedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      mentionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mention_count'],
      )!,
      summaryMemoryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_memory_count'],
      )!,
      isPromoted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_promoted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      firstMentionedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_mentioned_at'],
      ),
      lastMentionedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_mentioned_at'],
      ),
    );
  }

  @override
  $EntitiesTable createAlias(String alias) {
    return $EntitiesTable(attachedDatabase, alias);
  }
}

class Entity extends DataClass implements Insertable<Entity> {
  final String id;
  final String name;
  final String? summary;
  final int mentionCount;
  final int summaryMemoryCount;
  final bool isPromoted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? firstMentionedAt;
  final DateTime? lastMentionedAt;
  const Entity({
    required this.id,
    required this.name,
    this.summary,
    required this.mentionCount,
    required this.summaryMemoryCount,
    required this.isPromoted,
    required this.createdAt,
    required this.updatedAt,
    this.firstMentionedAt,
    this.lastMentionedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['mention_count'] = Variable<int>(mentionCount);
    map['summary_memory_count'] = Variable<int>(summaryMemoryCount);
    map['is_promoted'] = Variable<bool>(isPromoted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || firstMentionedAt != null) {
      map['first_mentioned_at'] = Variable<DateTime>(firstMentionedAt);
    }
    if (!nullToAbsent || lastMentionedAt != null) {
      map['last_mentioned_at'] = Variable<DateTime>(lastMentionedAt);
    }
    return map;
  }

  EntitiesCompanion toCompanion(bool nullToAbsent) {
    return EntitiesCompanion(
      id: Value(id),
      name: Value(name),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      mentionCount: Value(mentionCount),
      summaryMemoryCount: Value(summaryMemoryCount),
      isPromoted: Value(isPromoted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      firstMentionedAt: firstMentionedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstMentionedAt),
      lastMentionedAt: lastMentionedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMentionedAt),
    );
  }

  factory Entity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      summary: serializer.fromJson<String?>(json['summary']),
      mentionCount: serializer.fromJson<int>(json['mentionCount']),
      summaryMemoryCount: serializer.fromJson<int>(json['summaryMemoryCount']),
      isPromoted: serializer.fromJson<bool>(json['isPromoted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      firstMentionedAt: serializer.fromJson<DateTime?>(
        json['firstMentionedAt'],
      ),
      lastMentionedAt: serializer.fromJson<DateTime?>(json['lastMentionedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'summary': serializer.toJson<String?>(summary),
      'mentionCount': serializer.toJson<int>(mentionCount),
      'summaryMemoryCount': serializer.toJson<int>(summaryMemoryCount),
      'isPromoted': serializer.toJson<bool>(isPromoted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'firstMentionedAt': serializer.toJson<DateTime?>(firstMentionedAt),
      'lastMentionedAt': serializer.toJson<DateTime?>(lastMentionedAt),
    };
  }

  Entity copyWith({
    String? id,
    String? name,
    Value<String?> summary = const Value.absent(),
    int? mentionCount,
    int? summaryMemoryCount,
    bool? isPromoted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> firstMentionedAt = const Value.absent(),
    Value<DateTime?> lastMentionedAt = const Value.absent(),
  }) => Entity(
    id: id ?? this.id,
    name: name ?? this.name,
    summary: summary.present ? summary.value : this.summary,
    mentionCount: mentionCount ?? this.mentionCount,
    summaryMemoryCount: summaryMemoryCount ?? this.summaryMemoryCount,
    isPromoted: isPromoted ?? this.isPromoted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    firstMentionedAt: firstMentionedAt.present
        ? firstMentionedAt.value
        : this.firstMentionedAt,
    lastMentionedAt: lastMentionedAt.present
        ? lastMentionedAt.value
        : this.lastMentionedAt,
  );
  Entity copyWithCompanion(EntitiesCompanion data) {
    return Entity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      summary: data.summary.present ? data.summary.value : this.summary,
      mentionCount: data.mentionCount.present
          ? data.mentionCount.value
          : this.mentionCount,
      summaryMemoryCount: data.summaryMemoryCount.present
          ? data.summaryMemoryCount.value
          : this.summaryMemoryCount,
      isPromoted: data.isPromoted.present
          ? data.isPromoted.value
          : this.isPromoted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      firstMentionedAt: data.firstMentionedAt.present
          ? data.firstMentionedAt.value
          : this.firstMentionedAt,
      lastMentionedAt: data.lastMentionedAt.present
          ? data.lastMentionedAt.value
          : this.lastMentionedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('summary: $summary, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('summaryMemoryCount: $summaryMemoryCount, ')
          ..write('isPromoted: $isPromoted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('firstMentionedAt: $firstMentionedAt, ')
          ..write('lastMentionedAt: $lastMentionedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    summary,
    mentionCount,
    summaryMemoryCount,
    isPromoted,
    createdAt,
    updatedAt,
    firstMentionedAt,
    lastMentionedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entity &&
          other.id == this.id &&
          other.name == this.name &&
          other.summary == this.summary &&
          other.mentionCount == this.mentionCount &&
          other.summaryMemoryCount == this.summaryMemoryCount &&
          other.isPromoted == this.isPromoted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.firstMentionedAt == this.firstMentionedAt &&
          other.lastMentionedAt == this.lastMentionedAt);
}

class EntitiesCompanion extends UpdateCompanion<Entity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> summary;
  final Value<int> mentionCount;
  final Value<int> summaryMemoryCount;
  final Value<bool> isPromoted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> firstMentionedAt;
  final Value<DateTime?> lastMentionedAt;
  final Value<int> rowid;
  const EntitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.summary = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.summaryMemoryCount = const Value.absent(),
    this.isPromoted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.firstMentionedAt = const Value.absent(),
    this.lastMentionedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitiesCompanion.insert({
    required String id,
    required String name,
    this.summary = const Value.absent(),
    this.mentionCount = const Value.absent(),
    this.summaryMemoryCount = const Value.absent(),
    this.isPromoted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.firstMentionedAt = const Value.absent(),
    this.lastMentionedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Entity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? summary,
    Expression<int>? mentionCount,
    Expression<int>? summaryMemoryCount,
    Expression<bool>? isPromoted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? firstMentionedAt,
    Expression<DateTime>? lastMentionedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (summary != null) 'summary': summary,
      if (mentionCount != null) 'mention_count': mentionCount,
      if (summaryMemoryCount != null)
        'summary_memory_count': summaryMemoryCount,
      if (isPromoted != null) 'is_promoted': isPromoted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (firstMentionedAt != null) 'first_mentioned_at': firstMentionedAt,
      if (lastMentionedAt != null) 'last_mentioned_at': lastMentionedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? summary,
    Value<int>? mentionCount,
    Value<int>? summaryMemoryCount,
    Value<bool>? isPromoted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? firstMentionedAt,
    Value<DateTime?>? lastMentionedAt,
    Value<int>? rowid,
  }) {
    return EntitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      mentionCount: mentionCount ?? this.mentionCount,
      summaryMemoryCount: summaryMemoryCount ?? this.summaryMemoryCount,
      isPromoted: isPromoted ?? this.isPromoted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstMentionedAt: firstMentionedAt ?? this.firstMentionedAt,
      lastMentionedAt: lastMentionedAt ?? this.lastMentionedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (mentionCount.present) {
      map['mention_count'] = Variable<int>(mentionCount.value);
    }
    if (summaryMemoryCount.present) {
      map['summary_memory_count'] = Variable<int>(summaryMemoryCount.value);
    }
    if (isPromoted.present) {
      map['is_promoted'] = Variable<bool>(isPromoted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (firstMentionedAt.present) {
      map['first_mentioned_at'] = Variable<DateTime>(firstMentionedAt.value);
    }
    if (lastMentionedAt.present) {
      map['last_mentioned_at'] = Variable<DateTime>(lastMentionedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('summary: $summary, ')
          ..write('mentionCount: $mentionCount, ')
          ..write('summaryMemoryCount: $summaryMemoryCount, ')
          ..write('isPromoted: $isPromoted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('firstMentionedAt: $firstMentionedAt, ')
          ..write('lastMentionedAt: $lastMentionedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityAliasesTable extends EntityAliases
    with TableInfo<$EntityAliasesTable, EntityAliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entityId, alias];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_aliases';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityAliase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityAliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityAliase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
    );
  }

  @override
  $EntityAliasesTable createAlias(String alias) {
    return $EntityAliasesTable(attachedDatabase, alias);
  }
}

class EntityAliase extends DataClass implements Insertable<EntityAliase> {
  final int id;
  final String entityId;
  final String alias;
  const EntityAliase({
    required this.id,
    required this.entityId,
    required this.alias,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_id'] = Variable<String>(entityId);
    map['alias'] = Variable<String>(alias);
    return map;
  }

  EntityAliasesCompanion toCompanion(bool nullToAbsent) {
    return EntityAliasesCompanion(
      id: Value(id),
      entityId: Value(entityId),
      alias: Value(alias),
    );
  }

  factory EntityAliase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityAliase(
      id: serializer.fromJson<int>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      alias: serializer.fromJson<String>(json['alias']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityId': serializer.toJson<String>(entityId),
      'alias': serializer.toJson<String>(alias),
    };
  }

  EntityAliase copyWith({int? id, String? entityId, String? alias}) =>
      EntityAliase(
        id: id ?? this.id,
        entityId: entityId ?? this.entityId,
        alias: alias ?? this.alias,
      );
  EntityAliase copyWithCompanion(EntityAliasesCompanion data) {
    return EntityAliase(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      alias: data.alias.present ? data.alias.value : this.alias,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityAliase(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('alias: $alias')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityId, alias);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityAliase &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.alias == this.alias);
}

class EntityAliasesCompanion extends UpdateCompanion<EntityAliase> {
  final Value<int> id;
  final Value<String> entityId;
  final Value<String> alias;
  const EntityAliasesCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.alias = const Value.absent(),
  });
  EntityAliasesCompanion.insert({
    this.id = const Value.absent(),
    required String entityId,
    required String alias,
  }) : entityId = Value(entityId),
       alias = Value(alias);
  static Insertable<EntityAliase> custom({
    Expression<int>? id,
    Expression<String>? entityId,
    Expression<String>? alias,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (alias != null) 'alias': alias,
    });
  }

  EntityAliasesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityId,
    Value<String>? alias,
  }) {
    return EntityAliasesCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      alias: alias ?? this.alias,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityAliasesCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('alias: $alias')
          ..write(')'))
        .toString();
  }
}

class $EntityLinksTable extends EntityLinks
    with TableInfo<$EntityLinksTable, EntityLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relevanceMeta = const VerificationMeta(
    'relevance',
  );
  @override
  late final GeneratedColumn<double> relevance = GeneratedColumn<double>(
    'relevance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, memoryId, entityId, relevance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('relevance')) {
      context.handle(
        _relevanceMeta,
        relevance.isAcceptableOrUnknown(data['relevance']!, _relevanceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      relevance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}relevance'],
      )!,
    );
  }

  @override
  $EntityLinksTable createAlias(String alias) {
    return $EntityLinksTable(attachedDatabase, alias);
  }
}

class EntityLink extends DataClass implements Insertable<EntityLink> {
  final int id;
  final String memoryId;
  final String entityId;
  final double relevance;
  const EntityLink({
    required this.id,
    required this.memoryId,
    required this.entityId,
    required this.relevance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['memory_id'] = Variable<String>(memoryId);
    map['entity_id'] = Variable<String>(entityId);
    map['relevance'] = Variable<double>(relevance);
    return map;
  }

  EntityLinksCompanion toCompanion(bool nullToAbsent) {
    return EntityLinksCompanion(
      id: Value(id),
      memoryId: Value(memoryId),
      entityId: Value(entityId),
      relevance: Value(relevance),
    );
  }

  factory EntityLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityLink(
      id: serializer.fromJson<int>(json['id']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
      entityId: serializer.fromJson<String>(json['entityId']),
      relevance: serializer.fromJson<double>(json['relevance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'memoryId': serializer.toJson<String>(memoryId),
      'entityId': serializer.toJson<String>(entityId),
      'relevance': serializer.toJson<double>(relevance),
    };
  }

  EntityLink copyWith({
    int? id,
    String? memoryId,
    String? entityId,
    double? relevance,
  }) => EntityLink(
    id: id ?? this.id,
    memoryId: memoryId ?? this.memoryId,
    entityId: entityId ?? this.entityId,
    relevance: relevance ?? this.relevance,
  );
  EntityLink copyWithCompanion(EntityLinksCompanion data) {
    return EntityLink(
      id: data.id.present ? data.id.value : this.id,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      relevance: data.relevance.present ? data.relevance.value : this.relevance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityLink(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('entityId: $entityId, ')
          ..write('relevance: $relevance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId, entityId, relevance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityLink &&
          other.id == this.id &&
          other.memoryId == this.memoryId &&
          other.entityId == this.entityId &&
          other.relevance == this.relevance);
}

class EntityLinksCompanion extends UpdateCompanion<EntityLink> {
  final Value<int> id;
  final Value<String> memoryId;
  final Value<String> entityId;
  final Value<double> relevance;
  const EntityLinksCompanion({
    this.id = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.entityId = const Value.absent(),
    this.relevance = const Value.absent(),
  });
  EntityLinksCompanion.insert({
    this.id = const Value.absent(),
    required String memoryId,
    required String entityId,
    this.relevance = const Value.absent(),
  }) : memoryId = Value(memoryId),
       entityId = Value(entityId);
  static Insertable<EntityLink> custom({
    Expression<int>? id,
    Expression<String>? memoryId,
    Expression<String>? entityId,
    Expression<double>? relevance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId != null) 'memory_id': memoryId,
      if (entityId != null) 'entity_id': entityId,
      if (relevance != null) 'relevance': relevance,
    });
  }

  EntityLinksCompanion copyWith({
    Value<int>? id,
    Value<String>? memoryId,
    Value<String>? entityId,
    Value<double>? relevance,
  }) {
    return EntityLinksCompanion(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      entityId: entityId ?? this.entityId,
      relevance: relevance ?? this.relevance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (relevance.present) {
      map['relevance'] = Variable<double>(relevance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityLinksCompanion(')
          ..write('id: $id, ')
          ..write('memoryId: $memoryId, ')
          ..write('entityId: $entityId, ')
          ..write('relevance: $relevance')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMemoryIdMeta = const VerificationMeta(
    'summaryMemoryId',
  );
  @override
  late final GeneratedColumn<String> summaryMemoryId = GeneratedColumn<String>(
    'summary_memory_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    kind,
    displayName,
    mimeType,
    byteSize,
    status,
    failureReason,
    localPath,
    rawText,
    summary,
    summaryMemoryId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('summary_memory_id')) {
      context.handle(
        _summaryMemoryIdMeta,
        summaryMemoryId.isAcceptableOrUnknown(
          data['summary_memory_id']!,
          _summaryMemoryIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      summaryMemoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_memory_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String messageId;
  final String kind;
  final String? displayName;
  final String? mimeType;
  final int? byteSize;
  final String status;
  final String? failureReason;
  final String? localPath;
  final String? rawText;
  final String? summary;
  final String? summaryMemoryId;
  final DateTime createdAt;
  const Attachment({
    required this.id,
    required this.messageId,
    required this.kind,
    this.displayName,
    this.mimeType,
    this.byteSize,
    required this.status,
    this.failureReason,
    this.localPath,
    this.rawText,
    this.summary,
    this.summaryMemoryId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message_id'] = Variable<String>(messageId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || byteSize != null) {
      map['byte_size'] = Variable<int>(byteSize);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || summaryMemoryId != null) {
      map['summary_memory_id'] = Variable<String>(summaryMemoryId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      kind: Value(kind),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      byteSize: byteSize == null && nullToAbsent
          ? const Value.absent()
          : Value(byteSize),
      status: Value(status),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      summaryMemoryId: summaryMemoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryMemoryId),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      kind: serializer.fromJson<String>(json['kind']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      byteSize: serializer.fromJson<int?>(json['byteSize']),
      status: serializer.fromJson<String>(json['status']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      summary: serializer.fromJson<String?>(json['summary']),
      summaryMemoryId: serializer.fromJson<String?>(json['summaryMemoryId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messageId': serializer.toJson<String>(messageId),
      'kind': serializer.toJson<String>(kind),
      'displayName': serializer.toJson<String?>(displayName),
      'mimeType': serializer.toJson<String?>(mimeType),
      'byteSize': serializer.toJson<int?>(byteSize),
      'status': serializer.toJson<String>(status),
      'failureReason': serializer.toJson<String?>(failureReason),
      'localPath': serializer.toJson<String?>(localPath),
      'rawText': serializer.toJson<String?>(rawText),
      'summary': serializer.toJson<String?>(summary),
      'summaryMemoryId': serializer.toJson<String?>(summaryMemoryId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? messageId,
    String? kind,
    Value<String?> displayName = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<int?> byteSize = const Value.absent(),
    String? status,
    Value<String?> failureReason = const Value.absent(),
    Value<String?> localPath = const Value.absent(),
    Value<String?> rawText = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> summaryMemoryId = const Value.absent(),
    DateTime? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    kind: kind ?? this.kind,
    displayName: displayName.present ? displayName.value : this.displayName,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    byteSize: byteSize.present ? byteSize.value : this.byteSize,
    status: status ?? this.status,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    localPath: localPath.present ? localPath.value : this.localPath,
    rawText: rawText.present ? rawText.value : this.rawText,
    summary: summary.present ? summary.value : this.summary,
    summaryMemoryId: summaryMemoryId.present
        ? summaryMemoryId.value
        : this.summaryMemoryId,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      kind: data.kind.present ? data.kind.value : this.kind,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      status: data.status.present ? data.status.value : this.status,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      summary: data.summary.present ? data.summary.value : this.summary,
      summaryMemoryId: data.summaryMemoryId.present
          ? data.summaryMemoryId.value
          : this.summaryMemoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('kind: $kind, ')
          ..write('displayName: $displayName, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('status: $status, ')
          ..write('failureReason: $failureReason, ')
          ..write('localPath: $localPath, ')
          ..write('rawText: $rawText, ')
          ..write('summary: $summary, ')
          ..write('summaryMemoryId: $summaryMemoryId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    messageId,
    kind,
    displayName,
    mimeType,
    byteSize,
    status,
    failureReason,
    localPath,
    rawText,
    summary,
    summaryMemoryId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.kind == this.kind &&
          other.displayName == this.displayName &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.status == this.status &&
          other.failureReason == this.failureReason &&
          other.localPath == this.localPath &&
          other.rawText == this.rawText &&
          other.summary == this.summary &&
          other.summaryMemoryId == this.summaryMemoryId &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> messageId;
  final Value<String> kind;
  final Value<String?> displayName;
  final Value<String?> mimeType;
  final Value<int?> byteSize;
  final Value<String> status;
  final Value<String?> failureReason;
  final Value<String?> localPath;
  final Value<String?> rawText;
  final Value<String?> summary;
  final Value<String?> summaryMemoryId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.kind = const Value.absent(),
    this.displayName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.status = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.summary = const Value.absent(),
    this.summaryMemoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String messageId,
    required String kind,
    this.displayName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.status = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rawText = const Value.absent(),
    this.summary = const Value.absent(),
    this.summaryMemoryId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messageId = Value(messageId),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? messageId,
    Expression<String>? kind,
    Expression<String>? displayName,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? status,
    Expression<String>? failureReason,
    Expression<String>? localPath,
    Expression<String>? rawText,
    Expression<String>? summary,
    Expression<String>? summaryMemoryId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (kind != null) 'kind': kind,
      if (displayName != null) 'display_name': displayName,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (status != null) 'status': status,
      if (failureReason != null) 'failure_reason': failureReason,
      if (localPath != null) 'local_path': localPath,
      if (rawText != null) 'raw_text': rawText,
      if (summary != null) 'summary': summary,
      if (summaryMemoryId != null) 'summary_memory_id': summaryMemoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? messageId,
    Value<String>? kind,
    Value<String?>? displayName,
    Value<String?>? mimeType,
    Value<int?>? byteSize,
    Value<String>? status,
    Value<String?>? failureReason,
    Value<String?>? localPath,
    Value<String?>? rawText,
    Value<String?>? summary,
    Value<String?>? summaryMemoryId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      kind: kind ?? this.kind,
      displayName: displayName ?? this.displayName,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      localPath: localPath ?? this.localPath,
      rawText: rawText ?? this.rawText,
      summary: summary ?? this.summary,
      summaryMemoryId: summaryMemoryId ?? this.summaryMemoryId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (summaryMemoryId.present) {
      map['summary_memory_id'] = Variable<String>(summaryMemoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('kind: $kind, ')
          ..write('displayName: $displayName, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('status: $status, ')
          ..write('failureReason: $failureReason, ')
          ..write('localPath: $localPath, ')
          ..write('rawText: $rawText, ')
          ..write('summary: $summary, ')
          ..write('summaryMemoryId: $summaryMemoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagePairsTable extends MessagePairs
    with TableInfo<$MessagePairsTable, MessagePair> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagePairsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userMessageIdMeta = const VerificationMeta(
    'userMessageId',
  );
  @override
  late final GeneratedColumn<String> userMessageId = GeneratedColumn<String>(
    'user_message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assistantMessageIdMeta =
      const VerificationMeta('assistantMessageId');
  @override
  late final GeneratedColumn<String> assistantMessageId =
      GeneratedColumn<String>(
        'assistant_message_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [userMessageId, assistantMessageId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_pairs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessagePair> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_message_id')) {
      context.handle(
        _userMessageIdMeta,
        userMessageId.isAcceptableOrUnknown(
          data['user_message_id']!,
          _userMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userMessageIdMeta);
    }
    if (data.containsKey('assistant_message_id')) {
      context.handle(
        _assistantMessageIdMeta,
        assistantMessageId.isAcceptableOrUnknown(
          data['assistant_message_id']!,
          _assistantMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assistantMessageIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userMessageId};
  @override
  MessagePair map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessagePair(
      userMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_message_id'],
      )!,
      assistantMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assistant_message_id'],
      )!,
    );
  }

  @override
  $MessagePairsTable createAlias(String alias) {
    return $MessagePairsTable(attachedDatabase, alias);
  }
}

class MessagePair extends DataClass implements Insertable<MessagePair> {
  final String userMessageId;
  final String assistantMessageId;
  const MessagePair({
    required this.userMessageId,
    required this.assistantMessageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_message_id'] = Variable<String>(userMessageId);
    map['assistant_message_id'] = Variable<String>(assistantMessageId);
    return map;
  }

  MessagePairsCompanion toCompanion(bool nullToAbsent) {
    return MessagePairsCompanion(
      userMessageId: Value(userMessageId),
      assistantMessageId: Value(assistantMessageId),
    );
  }

  factory MessagePair.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessagePair(
      userMessageId: serializer.fromJson<String>(json['userMessageId']),
      assistantMessageId: serializer.fromJson<String>(
        json['assistantMessageId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userMessageId': serializer.toJson<String>(userMessageId),
      'assistantMessageId': serializer.toJson<String>(assistantMessageId),
    };
  }

  MessagePair copyWith({String? userMessageId, String? assistantMessageId}) =>
      MessagePair(
        userMessageId: userMessageId ?? this.userMessageId,
        assistantMessageId: assistantMessageId ?? this.assistantMessageId,
      );
  MessagePair copyWithCompanion(MessagePairsCompanion data) {
    return MessagePair(
      userMessageId: data.userMessageId.present
          ? data.userMessageId.value
          : this.userMessageId,
      assistantMessageId: data.assistantMessageId.present
          ? data.assistantMessageId.value
          : this.assistantMessageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessagePair(')
          ..write('userMessageId: $userMessageId, ')
          ..write('assistantMessageId: $assistantMessageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userMessageId, assistantMessageId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessagePair &&
          other.userMessageId == this.userMessageId &&
          other.assistantMessageId == this.assistantMessageId);
}

class MessagePairsCompanion extends UpdateCompanion<MessagePair> {
  final Value<String> userMessageId;
  final Value<String> assistantMessageId;
  final Value<int> rowid;
  const MessagePairsCompanion({
    this.userMessageId = const Value.absent(),
    this.assistantMessageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagePairsCompanion.insert({
    required String userMessageId,
    required String assistantMessageId,
    this.rowid = const Value.absent(),
  }) : userMessageId = Value(userMessageId),
       assistantMessageId = Value(assistantMessageId);
  static Insertable<MessagePair> custom({
    Expression<String>? userMessageId,
    Expression<String>? assistantMessageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userMessageId != null) 'user_message_id': userMessageId,
      if (assistantMessageId != null)
        'assistant_message_id': assistantMessageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagePairsCompanion copyWith({
    Value<String>? userMessageId,
    Value<String>? assistantMessageId,
    Value<int>? rowid,
  }) {
    return MessagePairsCompanion(
      userMessageId: userMessageId ?? this.userMessageId,
      assistantMessageId: assistantMessageId ?? this.assistantMessageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userMessageId.present) {
      map['user_message_id'] = Variable<String>(userMessageId.value);
    }
    if (assistantMessageId.present) {
      map['assistant_message_id'] = Variable<String>(assistantMessageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagePairsCompanion(')
          ..write('userMessageId: $userMessageId, ')
          ..write('assistantMessageId: $assistantMessageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MessageRevisionsTable messageRevisions = $MessageRevisionsTable(
    this,
  );
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $EmbeddingVectorsTable embeddingVectors = $EmbeddingVectorsTable(
    this,
  );
  late final $MemoryTagsTable memoryTags = $MemoryTagsTable(this);
  late final $EntitiesTable entities = $EntitiesTable(this);
  late final $EntityAliasesTable entityAliases = $EntityAliasesTable(this);
  late final $EntityLinksTable entityLinks = $EntityLinksTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $MessagePairsTable messagePairs = $MessagePairsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    messageRevisions,
    memories,
    embeddingVectors,
    memoryTags,
    entities,
    entityAliases,
    entityLinks,
    attachments,
    messagePairs,
  ];
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String role,
      required String content,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isEdited,
      Value<bool> isDeleted,
      Value<String?> pairedMessageId,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> role,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isEdited,
      Value<bool> isDeleted,
      Value<String?> pairedMessageId,
      Value<int> rowid,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pairedMessageId => $composableBuilder(
    column: $table.pairedMessageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pairedMessageId => $composableBuilder(
    column: $table.pairedMessageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get pairedMessageId => $composableBuilder(
    column: $table.pairedMessageId,
    builder: (column) => column,
  );
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> pairedMessageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                role: role,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isEdited: isEdited,
                isDeleted: isDeleted,
                pairedMessageId: pairedMessageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String role,
                required String content,
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> pairedMessageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                role: role,
                content: content,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isEdited: isEdited,
                isDeleted: isDeleted,
                pairedMessageId: pairedMessageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$MessageRevisionsTableCreateCompanionBuilder =
    MessageRevisionsCompanion Function({
      Value<int> id,
      required String messageId,
      required String revisionContent,
      required DateTime createdAt,
    });
typedef $$MessageRevisionsTableUpdateCompanionBuilder =
    MessageRevisionsCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> revisionContent,
      Value<DateTime> createdAt,
    });

class $$MessageRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageRevisionsTable> {
  $$MessageRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revisionContent => $composableBuilder(
    column: $table.revisionContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageRevisionsTable> {
  $$MessageRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revisionContent => $composableBuilder(
    column: $table.revisionContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageRevisionsTable> {
  $$MessageRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get revisionContent => $composableBuilder(
    column: $table.revisionContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessageRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageRevisionsTable,
          MessageRevision,
          $$MessageRevisionsTableFilterComposer,
          $$MessageRevisionsTableOrderingComposer,
          $$MessageRevisionsTableAnnotationComposer,
          $$MessageRevisionsTableCreateCompanionBuilder,
          $$MessageRevisionsTableUpdateCompanionBuilder,
          (
            MessageRevision,
            BaseReferences<
              _$AppDatabase,
              $MessageRevisionsTable,
              MessageRevision
            >,
          ),
          MessageRevision,
          PrefetchHooks Function()
        > {
  $$MessageRevisionsTableTableManager(
    _$AppDatabase db,
    $MessageRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> revisionContent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MessageRevisionsCompanion(
                id: id,
                messageId: messageId,
                revisionContent: revisionContent,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String revisionContent,
                required DateTime createdAt,
              }) => MessageRevisionsCompanion.insert(
                id: id,
                messageId: messageId,
                revisionContent: revisionContent,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageRevisionsTable,
      MessageRevision,
      $$MessageRevisionsTableFilterComposer,
      $$MessageRevisionsTableOrderingComposer,
      $$MessageRevisionsTableAnnotationComposer,
      $$MessageRevisionsTableCreateCompanionBuilder,
      $$MessageRevisionsTableUpdateCompanionBuilder,
      (
        MessageRevision,
        BaseReferences<_$AppDatabase, $MessageRevisionsTable, MessageRevision>,
      ),
      MessageRevision,
      PrefetchHooks Function()
    >;
typedef $$MemoriesTableCreateCompanionBuilder =
    MemoriesCompanion Function({
      required String id,
      required String sourceMessageId,
      required String content,
      required DateTime createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$MemoriesTableUpdateCompanionBuilder =
    MemoriesCompanion Function({
      Value<String> id,
      Value<String> sourceMessageId,
      Value<String> content,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$MemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$MemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoriesTable,
          Memory,
          $$MemoriesTableFilterComposer,
          $$MemoriesTableOrderingComposer,
          $$MemoriesTableAnnotationComposer,
          $$MemoriesTableCreateCompanionBuilder,
          $$MemoriesTableUpdateCompanionBuilder,
          (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
          Memory,
          PrefetchHooks Function()
        > {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceMessageId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion(
                id: id,
                sourceMessageId: sourceMessageId,
                content: content,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceMessageId,
                required String content,
                required DateTime createdAt,
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion.insert(
                id: id,
                sourceMessageId: sourceMessageId,
                content: content,
                createdAt: createdAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoriesTable,
      Memory,
      $$MemoriesTableFilterComposer,
      $$MemoriesTableOrderingComposer,
      $$MemoriesTableAnnotationComposer,
      $$MemoriesTableCreateCompanionBuilder,
      $$MemoriesTableUpdateCompanionBuilder,
      (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
      Memory,
      PrefetchHooks Function()
    >;
typedef $$EmbeddingVectorsTableCreateCompanionBuilder =
    EmbeddingVectorsCompanion Function({
      required String id,
      required String memoryId,
      required String modelName,
      required Uint8List vectorBlob,
      required DateTime createdAt,
      Value<bool> isCanon,
      Value<int> rowid,
    });
typedef $$EmbeddingVectorsTableUpdateCompanionBuilder =
    EmbeddingVectorsCompanion Function({
      Value<String> id,
      Value<String> memoryId,
      Value<String> modelName,
      Value<Uint8List> vectorBlob,
      Value<DateTime> createdAt,
      Value<bool> isCanon,
      Value<int> rowid,
    });

class $$EmbeddingVectorsTableFilterComposer
    extends Composer<_$AppDatabase, $EmbeddingVectorsTable> {
  $$EmbeddingVectorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vectorBlob => $composableBuilder(
    column: $table.vectorBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCanon => $composableBuilder(
    column: $table.isCanon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmbeddingVectorsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmbeddingVectorsTable> {
  $$EmbeddingVectorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vectorBlob => $composableBuilder(
    column: $table.vectorBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCanon => $composableBuilder(
    column: $table.isCanon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmbeddingVectorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmbeddingVectorsTable> {
  $$EmbeddingVectorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<Uint8List> get vectorBlob => $composableBuilder(
    column: $table.vectorBlob,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCanon =>
      $composableBuilder(column: $table.isCanon, builder: (column) => column);
}

class $$EmbeddingVectorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmbeddingVectorsTable,
          EmbeddingVector,
          $$EmbeddingVectorsTableFilterComposer,
          $$EmbeddingVectorsTableOrderingComposer,
          $$EmbeddingVectorsTableAnnotationComposer,
          $$EmbeddingVectorsTableCreateCompanionBuilder,
          $$EmbeddingVectorsTableUpdateCompanionBuilder,
          (
            EmbeddingVector,
            BaseReferences<
              _$AppDatabase,
              $EmbeddingVectorsTable,
              EmbeddingVector
            >,
          ),
          EmbeddingVector,
          PrefetchHooks Function()
        > {
  $$EmbeddingVectorsTableTableManager(
    _$AppDatabase db,
    $EmbeddingVectorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmbeddingVectorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmbeddingVectorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmbeddingVectorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<Uint8List> vectorBlob = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isCanon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingVectorsCompanion(
                id: id,
                memoryId: memoryId,
                modelName: modelName,
                vectorBlob: vectorBlob,
                createdAt: createdAt,
                isCanon: isCanon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoryId,
                required String modelName,
                required Uint8List vectorBlob,
                required DateTime createdAt,
                Value<bool> isCanon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmbeddingVectorsCompanion.insert(
                id: id,
                memoryId: memoryId,
                modelName: modelName,
                vectorBlob: vectorBlob,
                createdAt: createdAt,
                isCanon: isCanon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmbeddingVectorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmbeddingVectorsTable,
      EmbeddingVector,
      $$EmbeddingVectorsTableFilterComposer,
      $$EmbeddingVectorsTableOrderingComposer,
      $$EmbeddingVectorsTableAnnotationComposer,
      $$EmbeddingVectorsTableCreateCompanionBuilder,
      $$EmbeddingVectorsTableUpdateCompanionBuilder,
      (
        EmbeddingVector,
        BaseReferences<_$AppDatabase, $EmbeddingVectorsTable, EmbeddingVector>,
      ),
      EmbeddingVector,
      PrefetchHooks Function()
    >;
typedef $$MemoryTagsTableCreateCompanionBuilder =
    MemoryTagsCompanion Function({
      Value<int> id,
      required String memoryId,
      required String tag,
    });
typedef $$MemoryTagsTableUpdateCompanionBuilder =
    MemoryTagsCompanion Function({
      Value<int> id,
      Value<String> memoryId,
      Value<String> tag,
    });

class $$MemoryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryTagsTable> {
  $$MemoryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$MemoryTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryTagsTable,
          MemoryTag,
          $$MemoryTagsTableFilterComposer,
          $$MemoryTagsTableOrderingComposer,
          $$MemoryTagsTableAnnotationComposer,
          $$MemoryTagsTableCreateCompanionBuilder,
          $$MemoryTagsTableUpdateCompanionBuilder,
          (
            MemoryTag,
            BaseReferences<_$AppDatabase, $MemoryTagsTable, MemoryTag>,
          ),
          MemoryTag,
          PrefetchHooks Function()
        > {
  $$MemoryTagsTableTableManager(_$AppDatabase db, $MemoryTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> tag = const Value.absent(),
              }) => MemoryTagsCompanion(id: id, memoryId: memoryId, tag: tag),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String memoryId,
                required String tag,
              }) => MemoryTagsCompanion.insert(
                id: id,
                memoryId: memoryId,
                tag: tag,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryTagsTable,
      MemoryTag,
      $$MemoryTagsTableFilterComposer,
      $$MemoryTagsTableOrderingComposer,
      $$MemoryTagsTableAnnotationComposer,
      $$MemoryTagsTableCreateCompanionBuilder,
      $$MemoryTagsTableUpdateCompanionBuilder,
      (MemoryTag, BaseReferences<_$AppDatabase, $MemoryTagsTable, MemoryTag>),
      MemoryTag,
      PrefetchHooks Function()
    >;
typedef $$EntitiesTableCreateCompanionBuilder =
    EntitiesCompanion Function({
      required String id,
      required String name,
      Value<String?> summary,
      Value<int> mentionCount,
      Value<int> summaryMemoryCount,
      Value<bool> isPromoted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> firstMentionedAt,
      Value<DateTime?> lastMentionedAt,
      Value<int> rowid,
    });
typedef $$EntitiesTableUpdateCompanionBuilder =
    EntitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> summary,
      Value<int> mentionCount,
      Value<int> summaryMemoryCount,
      Value<bool> isPromoted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> firstMentionedAt,
      Value<DateTime?> lastMentionedAt,
      Value<int> rowid,
    });

class $$EntitiesTableFilterComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryMemoryCount => $composableBuilder(
    column: $table.summaryMemoryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPromoted => $composableBuilder(
    column: $table.isPromoted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstMentionedAt => $composableBuilder(
    column: $table.firstMentionedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMentionedAt => $composableBuilder(
    column: $table.lastMentionedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryMemoryCount => $composableBuilder(
    column: $table.summaryMemoryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPromoted => $composableBuilder(
    column: $table.isPromoted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstMentionedAt => $composableBuilder(
    column: $table.firstMentionedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMentionedAt => $composableBuilder(
    column: $table.lastMentionedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitiesTable> {
  $$EntitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get mentionCount => $composableBuilder(
    column: $table.mentionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get summaryMemoryCount => $composableBuilder(
    column: $table.summaryMemoryCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPromoted => $composableBuilder(
    column: $table.isPromoted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get firstMentionedAt => $composableBuilder(
    column: $table.firstMentionedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMentionedAt => $composableBuilder(
    column: $table.lastMentionedAt,
    builder: (column) => column,
  );
}

class $$EntitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitiesTable,
          Entity,
          $$EntitiesTableFilterComposer,
          $$EntitiesTableOrderingComposer,
          $$EntitiesTableAnnotationComposer,
          $$EntitiesTableCreateCompanionBuilder,
          $$EntitiesTableUpdateCompanionBuilder,
          (Entity, BaseReferences<_$AppDatabase, $EntitiesTable, Entity>),
          Entity,
          PrefetchHooks Function()
        > {
  $$EntitiesTableTableManager(_$AppDatabase db, $EntitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> summaryMemoryCount = const Value.absent(),
                Value<bool> isPromoted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> firstMentionedAt = const Value.absent(),
                Value<DateTime?> lastMentionedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion(
                id: id,
                name: name,
                summary: summary,
                mentionCount: mentionCount,
                summaryMemoryCount: summaryMemoryCount,
                isPromoted: isPromoted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                firstMentionedAt: firstMentionedAt,
                lastMentionedAt: lastMentionedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> summary = const Value.absent(),
                Value<int> mentionCount = const Value.absent(),
                Value<int> summaryMemoryCount = const Value.absent(),
                Value<bool> isPromoted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> firstMentionedAt = const Value.absent(),
                Value<DateTime?> lastMentionedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitiesCompanion.insert(
                id: id,
                name: name,
                summary: summary,
                mentionCount: mentionCount,
                summaryMemoryCount: summaryMemoryCount,
                isPromoted: isPromoted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                firstMentionedAt: firstMentionedAt,
                lastMentionedAt: lastMentionedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitiesTable,
      Entity,
      $$EntitiesTableFilterComposer,
      $$EntitiesTableOrderingComposer,
      $$EntitiesTableAnnotationComposer,
      $$EntitiesTableCreateCompanionBuilder,
      $$EntitiesTableUpdateCompanionBuilder,
      (Entity, BaseReferences<_$AppDatabase, $EntitiesTable, Entity>),
      Entity,
      PrefetchHooks Function()
    >;
typedef $$EntityAliasesTableCreateCompanionBuilder =
    EntityAliasesCompanion Function({
      Value<int> id,
      required String entityId,
      required String alias,
    });
typedef $$EntityAliasesTableUpdateCompanionBuilder =
    EntityAliasesCompanion Function({
      Value<int> id,
      Value<String> entityId,
      Value<String> alias,
    });

class $$EntityAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $EntityAliasesTable> {
  $$EntityAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityAliasesTable> {
  $$EntityAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityAliasesTable> {
  $$EntityAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);
}

class $$EntityAliasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityAliasesTable,
          EntityAliase,
          $$EntityAliasesTableFilterComposer,
          $$EntityAliasesTableOrderingComposer,
          $$EntityAliasesTableAnnotationComposer,
          $$EntityAliasesTableCreateCompanionBuilder,
          $$EntityAliasesTableUpdateCompanionBuilder,
          (
            EntityAliase,
            BaseReferences<_$AppDatabase, $EntityAliasesTable, EntityAliase>,
          ),
          EntityAliase,
          PrefetchHooks Function()
        > {
  $$EntityAliasesTableTableManager(_$AppDatabase db, $EntityAliasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> alias = const Value.absent(),
              }) => EntityAliasesCompanion(
                id: id,
                entityId: entityId,
                alias: alias,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityId,
                required String alias,
              }) => EntityAliasesCompanion.insert(
                id: id,
                entityId: entityId,
                alias: alias,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityAliasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityAliasesTable,
      EntityAliase,
      $$EntityAliasesTableFilterComposer,
      $$EntityAliasesTableOrderingComposer,
      $$EntityAliasesTableAnnotationComposer,
      $$EntityAliasesTableCreateCompanionBuilder,
      $$EntityAliasesTableUpdateCompanionBuilder,
      (
        EntityAliase,
        BaseReferences<_$AppDatabase, $EntityAliasesTable, EntityAliase>,
      ),
      EntityAliase,
      PrefetchHooks Function()
    >;
typedef $$EntityLinksTableCreateCompanionBuilder =
    EntityLinksCompanion Function({
      Value<int> id,
      required String memoryId,
      required String entityId,
      Value<double> relevance,
    });
typedef $$EntityLinksTableUpdateCompanionBuilder =
    EntityLinksCompanion Function({
      Value<int> id,
      Value<String> memoryId,
      Value<String> entityId,
      Value<double> relevance,
    });

class $$EntityLinksTableFilterComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get relevance => $composableBuilder(
    column: $table.relevance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get relevance => $composableBuilder(
    column: $table.relevance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntityLinksTable> {
  $$EntityLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<double> get relevance =>
      $composableBuilder(column: $table.relevance, builder: (column) => column);
}

class $$EntityLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntityLinksTable,
          EntityLink,
          $$EntityLinksTableFilterComposer,
          $$EntityLinksTableOrderingComposer,
          $$EntityLinksTableAnnotationComposer,
          $$EntityLinksTableCreateCompanionBuilder,
          $$EntityLinksTableUpdateCompanionBuilder,
          (
            EntityLink,
            BaseReferences<_$AppDatabase, $EntityLinksTable, EntityLink>,
          ),
          EntityLink,
          PrefetchHooks Function()
        > {
  $$EntityLinksTableTableManager(_$AppDatabase db, $EntityLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<double> relevance = const Value.absent(),
              }) => EntityLinksCompanion(
                id: id,
                memoryId: memoryId,
                entityId: entityId,
                relevance: relevance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String memoryId,
                required String entityId,
                Value<double> relevance = const Value.absent(),
              }) => EntityLinksCompanion.insert(
                id: id,
                memoryId: memoryId,
                entityId: entityId,
                relevance: relevance,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntityLinksTable,
      EntityLink,
      $$EntityLinksTableFilterComposer,
      $$EntityLinksTableOrderingComposer,
      $$EntityLinksTableAnnotationComposer,
      $$EntityLinksTableCreateCompanionBuilder,
      $$EntityLinksTableUpdateCompanionBuilder,
      (
        EntityLink,
        BaseReferences<_$AppDatabase, $EntityLinksTable, EntityLink>,
      ),
      EntityLink,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String messageId,
      required String kind,
      Value<String?> displayName,
      Value<String?> mimeType,
      Value<int?> byteSize,
      Value<String> status,
      Value<String?> failureReason,
      Value<String?> localPath,
      Value<String?> rawText,
      Value<String?> summary,
      Value<String?> summaryMemoryId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> messageId,
      Value<String> kind,
      Value<String?> displayName,
      Value<String?> mimeType,
      Value<int?> byteSize,
      Value<String> status,
      Value<String?> failureReason,
      Value<String?> localPath,
      Value<String?> rawText,
      Value<String?> summary,
      Value<String?> summaryMemoryId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryMemoryId => $composableBuilder(
    column: $table.summaryMemoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryMemoryId => $composableBuilder(
    column: $table.summaryMemoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get summaryMemoryId => $composableBuilder(
    column: $table.summaryMemoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryMemoryId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                messageId: messageId,
                kind: kind,
                displayName: displayName,
                mimeType: mimeType,
                byteSize: byteSize,
                status: status,
                failureReason: failureReason,
                localPath: localPath,
                rawText: rawText,
                summary: summary,
                summaryMemoryId: summaryMemoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messageId,
                required String kind,
                Value<String?> displayName = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryMemoryId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                messageId: messageId,
                kind: kind,
                displayName: displayName,
                mimeType: mimeType,
                byteSize: byteSize,
                status: status,
                failureReason: failureReason,
                localPath: localPath,
                rawText: rawText,
                summary: summary,
                summaryMemoryId: summaryMemoryId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$MessagePairsTableCreateCompanionBuilder =
    MessagePairsCompanion Function({
      required String userMessageId,
      required String assistantMessageId,
      Value<int> rowid,
    });
typedef $$MessagePairsTableUpdateCompanionBuilder =
    MessagePairsCompanion Function({
      Value<String> userMessageId,
      Value<String> assistantMessageId,
      Value<int> rowid,
    });

class $$MessagePairsTableFilterComposer
    extends Composer<_$AppDatabase, $MessagePairsTable> {
  $$MessagePairsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userMessageId => $composableBuilder(
    column: $table.userMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assistantMessageId => $composableBuilder(
    column: $table.assistantMessageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagePairsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagePairsTable> {
  $$MessagePairsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userMessageId => $composableBuilder(
    column: $table.userMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assistantMessageId => $composableBuilder(
    column: $table.assistantMessageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagePairsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagePairsTable> {
  $$MessagePairsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userMessageId => $composableBuilder(
    column: $table.userMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assistantMessageId => $composableBuilder(
    column: $table.assistantMessageId,
    builder: (column) => column,
  );
}

class $$MessagePairsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagePairsTable,
          MessagePair,
          $$MessagePairsTableFilterComposer,
          $$MessagePairsTableOrderingComposer,
          $$MessagePairsTableAnnotationComposer,
          $$MessagePairsTableCreateCompanionBuilder,
          $$MessagePairsTableUpdateCompanionBuilder,
          (
            MessagePair,
            BaseReferences<_$AppDatabase, $MessagePairsTable, MessagePair>,
          ),
          MessagePair,
          PrefetchHooks Function()
        > {
  $$MessagePairsTableTableManager(_$AppDatabase db, $MessagePairsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagePairsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagePairsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagePairsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userMessageId = const Value.absent(),
                Value<String> assistantMessageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagePairsCompanion(
                userMessageId: userMessageId,
                assistantMessageId: assistantMessageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userMessageId,
                required String assistantMessageId,
                Value<int> rowid = const Value.absent(),
              }) => MessagePairsCompanion.insert(
                userMessageId: userMessageId,
                assistantMessageId: assistantMessageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagePairsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagePairsTable,
      MessagePair,
      $$MessagePairsTableFilterComposer,
      $$MessagePairsTableOrderingComposer,
      $$MessagePairsTableAnnotationComposer,
      $$MessagePairsTableCreateCompanionBuilder,
      $$MessagePairsTableUpdateCompanionBuilder,
      (
        MessagePair,
        BaseReferences<_$AppDatabase, $MessagePairsTable, MessagePair>,
      ),
      MessagePair,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MessageRevisionsTableTableManager get messageRevisions =>
      $$MessageRevisionsTableTableManager(_db, _db.messageRevisions);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$EmbeddingVectorsTableTableManager get embeddingVectors =>
      $$EmbeddingVectorsTableTableManager(_db, _db.embeddingVectors);
  $$MemoryTagsTableTableManager get memoryTags =>
      $$MemoryTagsTableTableManager(_db, _db.memoryTags);
  $$EntitiesTableTableManager get entities =>
      $$EntitiesTableTableManager(_db, _db.entities);
  $$EntityAliasesTableTableManager get entityAliases =>
      $$EntityAliasesTableTableManager(_db, _db.entityAliases);
  $$EntityLinksTableTableManager get entityLinks =>
      $$EntityLinksTableTableManager(_db, _db.entityLinks);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$MessagePairsTableTableManager get messagePairs =>
      $$MessagePairsTableTableManager(_db, _db.messagePairs);
}
