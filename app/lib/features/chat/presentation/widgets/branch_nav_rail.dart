import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/heyo_theme.dart';

/// Git-like branch visualization rail with mini-map canvas
/// Shows conversation flow like source control graph
/// Red dot navigates like Google Maps mini-player
class BranchNavRail extends StatefulWidget {
  final ScrollController scrollController;
  final int messageCount;
  final Function(int)? onMessageTap;
  // Future: branch data for visualization
  // final List<ConversationBranch>? branches;

  const BranchNavRail({
    super.key,
    required this.scrollController,
    required this.messageCount,
    this.onMessageTap,
  });

  @override
  State<BranchNavRail> createState() => _BranchNavRailState();
}

class _BranchNavRailState extends State<BranchNavRail>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isDraggingHandle = false;
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  double _scrollProgress = 0.0;

  // Canvas dimensions - 3:2 aspect ratio
  static const double _canvasWidth = 72;
  static const double _canvasHeight = 108; // 3:2 ratio
  static const double _handleWidth = 20;
  static const double _gapWidth = 8; // Space between canvas and handle

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      setState(() => _scrollProgress = 1.0);
      return;
    }

    final currentScroll = widget.scrollController.offset;
    setState(() {
      _scrollProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onHandleDragStart() {
    HapticFeedback.mediumImpact();
    setState(() => _isDraggingHandle = true);
  }

  void _onHandleDragUpdate(DragUpdateDetails details) {
    // Horizontal drag to expand/collapse
    if (details.delta.dx < -2 && !_isExpanded) {
      _toggleExpanded();
    } else if (details.delta.dx > 2 && _isExpanded) {
      _toggleExpanded();
    }
  }

  void _onHandleDragEnd() {
    HapticFeedback.lightImpact();
    setState(() => _isDraggingHandle = false);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageCount == 0) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: 100,
      bottom: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Expanded canvas panel
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: _slideAnimation.value,
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBranchCanvas(context),
                SizedBox(width: _gapWidth), // Gap between canvas and handle
              ],
            ),
          ),
          // Slideable handle
          _buildHandle(context),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      onLongPressStart: (_) => _onHandleDragStart(),
      onLongPressMoveUpdate: (details) {
        _onHandleDragUpdate(DragUpdateDetails(
          delta: details.offsetFromOrigin,
          globalPosition: details.globalPosition,
        ));
      },
      onLongPressEnd: (_) => _onHandleDragEnd(),
      onHorizontalDragStart: (_) => _onHandleDragStart(),
      onHorizontalDragUpdate: _onHandleDragUpdate,
      onHorizontalDragEnd: (_) => _onHandleDragEnd(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _handleWidth,
        height: _isDraggingHandle ? 72 : 56,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: _isDraggingHandle
              ? HeyoColors.primary.withValues(alpha: 0.2)
              : context.glassColor.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          border: Border.all(
            color: _isDraggingHandle
                ? HeyoColors.primary.withValues(alpha: 0.5)
                : context.glassBorder,
            width: _isDraggingHandle ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isDraggingHandle
                  ? HeyoColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: _isDraggingHandle ? 12 : 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Center(
          child: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: _isDraggingHandle
                  ? HeyoColors.primary
                  : context.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCanvas(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: _canvasWidth,
            height: _canvasHeight,
            decoration: BoxDecoration(
              color: context.glassColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.glassBorder,
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(-2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11.5),
              child: CustomPaint(
                painter: _BranchGraphPainter(
                  scrollProgress: _scrollProgress,
                  messageCount: widget.messageCount,
                  lineColor: context.textTertiary.withValues(alpha: 0.3),
                  nodeColor: context.textTertiary.withValues(alpha: 0.4),
                  dotColor: HeyoColors.error,
                  // Future: branches for git-like splits
                ),
                size: Size(_canvasWidth, _canvasHeight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for git-like branch visualization
class _BranchGraphPainter extends CustomPainter {
  final double scrollProgress;
  final int messageCount;
  final Color lineColor;
  final Color nodeColor;
  final Color dotColor;

  _BranchGraphPainter({
    required this.scrollProgress,
    required this.messageCount,
    required this.lineColor,
    required this.nodeColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final padding = 12.0;
    final viewportHeight = size.height - (padding * 2);

    // Calculate how much of the conversation is visible
    // Assume viewport shows ~4 messages worth
    final visibleRatio = messageCount > 0 ? (4 / messageCount).clamp(0.2, 1.0) : 1.0;

    // Calculate total conversation height (extends beyond canvas)
    final totalHeight = viewportHeight / visibleRatio;
    final viewportOffset = (totalHeight - viewportHeight) * scrollProgress;

    // Main branch line paint
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw main branch line extending beyond canvas
    final lineTop = padding - viewportOffset;
    final lineBottom = padding + totalHeight - viewportOffset;

    // Clip to canvas but show lines extending out
    canvas.save();

    // Draw the main branch line
    canvas.drawLine(
      Offset(centerX, lineTop.clamp(-20, size.height + 20)),
      Offset(centerX, lineBottom.clamp(-20, size.height + 20)),
      linePaint,
    );

    // Draw message nodes along the line
    if (messageCount > 0) {
      final nodePaint = Paint()..color = nodeColor;
      final nodeRadius = 3.0;

      for (int i = 0; i < messageCount; i++) {
        final progress = messageCount > 1 ? i / (messageCount - 1) : 0.5;
        final nodeY = padding + (totalHeight * progress) - viewportOffset;

        // Only draw nodes that are near the visible area
        if (nodeY >= -10 && nodeY <= size.height + 10) {
          canvas.drawCircle(
            Offset(centerX, nodeY),
            nodeRadius,
            nodePaint,
          );
        }
      }
    }

    // Draw current position indicator (red dot - Heyo's nose!)
    final dotY = padding + (totalHeight * scrollProgress) - viewportOffset;
    final clampedDotY = dotY.clamp(padding, size.height - padding);

    // Glow effect
    final glowPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
      Offset(centerX, clampedDotY),
      8,
      glowPaint,
    );

    // Main red dot (full solid)
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(
      Offset(centerX, clampedDotY),
      6,
      dotPaint,
    );

    // Draw fade gradients at top and bottom to indicate more content
    _drawEdgeFade(canvas, size, isTop: true, hasContent: lineTop < padding);
    _drawEdgeFade(canvas, size, isTop: false, hasContent: lineBottom > size.height - padding);

    canvas.restore();
  }

  void _drawEdgeFade(Canvas canvas, Size size, {required bool isTop, required bool hasContent}) {
    if (!hasContent) return;

    // Draw arrow indicators
    final arrowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final arrowSize = 4.0;

    if (isTop) {
      final arrowY = 6.0;
      canvas.drawLine(
        Offset(centerX - arrowSize, arrowY + arrowSize),
        Offset(centerX, arrowY),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(centerX, arrowY),
        Offset(centerX + arrowSize, arrowY + arrowSize),
        arrowPaint,
      );
    } else {
      final arrowY = size.height - 6.0;
      canvas.drawLine(
        Offset(centerX - arrowSize, arrowY - arrowSize),
        Offset(centerX, arrowY),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(centerX, arrowY),
        Offset(centerX + arrowSize, arrowY - arrowSize),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BranchGraphPainter oldDelegate) {
    return scrollProgress != oldDelegate.scrollProgress ||
        messageCount != oldDelegate.messageCount;
  }
}
