import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/branch_tree.dart';

/// Git-like branch visualization rail with mini-map canvas
/// Shows complete conversation tree with all branches visible
/// Red dot navigates like Google Maps mini-player with smooth animations
class BranchNavRail extends StatefulWidget {
  final ScrollController scrollController;
  final int messageCount;
  final BranchTreeModel branchTree;

  const BranchNavRail({
    super.key,
    required this.scrollController,
    required this.messageCount,
    required this.branchTree,
  });

  @override
  State<BranchNavRail> createState() => _BranchNavRailState();
}

class _BranchNavRailState extends State<BranchNavRail>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isDragging = false;
  double _handlePosition = 0.5; // 0.0 = top, 1.0 = bottom
  double _totalDragDistance = 0;
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  double _scrollProgress = 0.0;

  // Branch switch animation
  late AnimationController _branchSwitchController;
  List<String> _previousPathIds = [];
  BranchSwitchAnimation? _branchAnimation;

  // Canvas dimensions - wider for branch visualization
  static const double _canvasWidth = 120;
  static const double _canvasHeight = 140;
  static const double _handleWidth = 20;
  static const double _handleHeight = 56;
  static const double _gapWidth = 8;

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

    // Branch switch animation controller
    _branchSwitchController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _branchSwitchController.addListener(() => setState(() {}));

    widget.scrollController.addListener(_onScroll);
    _previousPathIds = List.from(widget.branchTree.currentPathIds);
  }

  @override
  void didUpdateWidget(BranchNavRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect branch switch
    final newPathIds = widget.branchTree.currentPathIds;
    if (!_listEquals(_previousPathIds, newPathIds) && _previousPathIds.isNotEmpty && newPathIds.isNotEmpty) {
      _startBranchAnimation(_previousPathIds, newPathIds);
    }
    _previousPathIds = List.from(newPathIds);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _startBranchAnimation(List<String> oldPath, List<String> newPath) {
    // Find divergence point (last common ancestor)
    int divergeIndex = 0;
    for (int i = 0; i < oldPath.length && i < newPath.length; i++) {
      if (oldPath[i] == newPath[i]) {
        divergeIndex = i;
      } else {
        break;
      }
    }

    // Get nodes for animation
    final oldEndId = oldPath.isNotEmpty ? oldPath.last : null;
    final newEndId = newPath.isNotEmpty ? newPath.last : null;
    final divergeId = divergeIndex < oldPath.length ? oldPath[divergeIndex] : null;

    if (oldEndId == null || newEndId == null || divergeId == null) return;

    final oldNode = widget.branchTree.getNode(oldEndId);
    final newNode = widget.branchTree.getNode(newEndId);
    final divergeNode = widget.branchTree.getNode(divergeId);

    if (oldNode == null || newNode == null || divergeNode == null) return;

    _branchAnimation = BranchSwitchAnimation(
      fromLane: oldNode.assignedLane,
      fromDepth: oldNode.depth,
      toLane: newNode.assignedLane,
      toDepth: newNode.depth,
      divergeLane: divergeNode.assignedLane,
      divergeDepth: divergeNode.depth,
    );

    _branchSwitchController.forward(from: 0);
    HapticFeedback.selectionClick();
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

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _controller.dispose();
    _branchSwitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageCount == 0) return const SizedBox.shrink();

    // Get screen height for positioning calculation
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - _handleHeight - 300;
    final handleTop = 120 + (availableHeight * _handlePosition);

    return Positioned(
      right: 4,
      top: handleTop,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Canvas panel
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset((_canvasWidth + _gapWidth) * (1 - _slideAnimation.value), 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildBranchCanvas(context),
          ),
          SizedBox(width: _gapWidth),
          // Handle
          _buildHandle(context, availableHeight),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context, double availableHeight) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        _totalDragDistance = 0;
        HapticFeedback.mediumImpact();
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        _totalDragDistance += details.delta.dy.abs();
        setState(() {
          _handlePosition = (_handlePosition + details.delta.dy / availableHeight)
              .clamp(0.0, 1.0);
        });
      },
      onPanEnd: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isDragging = false);
        // If barely moved, treat as tap
        if (_totalDragDistance < 10) {
          _toggleExpanded();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _handleWidth,
        height: _isDragging ? 72 : _handleHeight,
        decoration: BoxDecoration(
          color: _isDragging
              ? context.textTertiary.withValues(alpha: 0.15)
              : context.glassColor.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          border: Border.all(
            color: _isDragging
                ? context.textSecondary.withValues(alpha: 0.4)
                : context.glassBorder,
            width: _isDragging ? 1.5 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDragging ? 0.12 : 0.08),
              blurRadius: _isDragging ? 12 : 8,
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
              color: _isDragging ? context.textSecondary : context.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCanvas(BuildContext context) {
    return ClipRRect(
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
                painter: _BranchTreePainter(
                  scrollProgress: _scrollProgress,
                  branchTree: widget.branchTree,
                  activeLineColor: context.textTertiary.withValues(alpha: 0.5),
                  inactiveLineColor: context.textTertiary.withValues(alpha: 0.2),
                  activeNodeColor: context.textTertiary.withValues(alpha: 0.6),
                  inactiveNodeColor: context.textTertiary.withValues(alpha: 0.25),
                  dotColor: HeyoColors.error,
                  branchAnimation: _branchAnimation,
                  animationProgress: _branchSwitchController.value,
                ),
                size: Size(_canvasWidth, _canvasHeight),
              ),
            ),
          ),
        ),
    );
  }
}

/// Data class for branch switch animation
class BranchSwitchAnimation {
  final int fromLane;
  final int fromDepth;
  final int toLane;
  final int toDepth;
  final int divergeLane;
  final int divergeDepth;

  const BranchSwitchAnimation({
    required this.fromLane,
    required this.fromDepth,
    required this.toLane,
    required this.toDepth,
    required this.divergeLane,
    required this.divergeDepth,
  });

  /// Calculate dot position during animation
  /// Phase 1 (0-30%): Move UP from fromDepth to divergeDepth
  /// Phase 2 (30-70%): Move HORIZONTALLY from divergeLane to toLane
  /// Phase 3 (70-100%): Move DOWN from divergeDepth to toDepth
  (int lane, double depth) getPosition(double progress) {
    if (progress <= 0.3) {
      // Phase 1: Move up to divergence point
      final phase = progress / 0.3;
      final eased = Curves.easeOutCubic.transform(phase);
      final depth = fromDepth + (divergeDepth - fromDepth) * eased;
      return (fromLane, depth);
    } else if (progress <= 0.7) {
      // Phase 2: Move horizontally
      final phase = (progress - 0.3) / 0.4;
      final eased = Curves.easeInOutCubic.transform(phase);
      final lane = fromLane + ((toLane - fromLane) * eased).round();
      return (lane, divergeDepth.toDouble());
    } else {
      // Phase 3: Move down to target
      final phase = (progress - 0.7) / 0.3;
      final eased = Curves.easeInCubic.transform(phase);
      final depth = divergeDepth + (toDepth - divergeDepth) * eased;
      return (toLane, depth);
    }
  }
}

/// Custom painter for complete branch tree visualization
/// Draws ALL branches, highlighting the active path
class _BranchTreePainter extends CustomPainter {
  final double scrollProgress;
  final BranchTreeModel branchTree;
  final Color activeLineColor;
  final Color inactiveLineColor;
  final Color activeNodeColor;
  final Color inactiveNodeColor;
  final Color dotColor;
  final BranchSwitchAnimation? branchAnimation;
  final double animationProgress;

  _BranchTreePainter({
    required this.scrollProgress,
    required this.branchTree,
    required this.activeLineColor,
    required this.inactiveLineColor,
    required this.activeNodeColor,
    required this.inactiveNodeColor,
    required this.dotColor,
    this.branchAnimation,
    this.animationProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (branchTree.nodes.isEmpty) return;

    final padding = 14.0;
    final viewportHeight = size.height - (padding * 2);
    final centerX = size.width / 2;

    // Calculate lane width based on number of lanes
    final laneWidth = branchTree.adaptiveLaneWidth;

    // Calculate viewport scrolling
    final maxDepth = branchTree.maxDepth;
    final visibleRatio = maxDepth > 0 ? (5 / (maxDepth + 1)).clamp(0.12, 1.0) : 1.0;
    final totalHeight = viewportHeight / visibleRatio;
    final viewportOffset = (totalHeight - viewportHeight) * scrollProgress;

    // Helper to get X position for a lane
    double laneX(int lane) => centerX + (lane * laneWidth);

    // Helper to get Y position for a depth
    double depthY(double depth) {
      if (maxDepth == 0) return padding + viewportHeight / 2;
      final progress = depth / maxDepth;
      return padding + (totalHeight * progress) - viewportOffset;
    }

    // Paint styles
    final inactiveLine = Paint()
      ..color = inactiveLineColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activeLine = Paint()
      ..color = activeLineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final inactiveNode = Paint()
      ..color = inactiveNodeColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final activeNode = Paint()..color = activeNodeColor;

    // Draw all segments (inactive first, then active on top)
    for (final segment in branchTree.inactiveSegments) {
      _drawSegment(canvas, segment, laneX, depthY, inactiveLine, size, padding);
    }

    for (final segment in branchTree.activeSegments) {
      _drawSegment(canvas, segment, laneX, depthY, activeLine, size, padding);
    }

    // Draw all nodes (inactive first, then active on top)
    for (final node in branchTree.nodes.values) {
      final isActive = branchTree.isOnCurrentPath(node.id);
      final nodeY = depthY(node.depth.toDouble());
      final nodeX = laneX(node.assignedLane);

      // Skip if outside visible range
      if (nodeY < -20 || nodeY > size.height + 20) continue;

      if (isActive) {
        // Filled dot for active path
        canvas.drawCircle(Offset(nodeX, nodeY), 3.5, activeNode);
      } else {
        // Outline dot for inactive branches
        canvas.drawCircle(Offset(nodeX, nodeY), 3.0, inactiveNode);
      }
    }

    // Draw scroll position indicator (red dot) on active path
    _drawScrollIndicator(canvas, size, centerX, padding, totalHeight, viewportOffset, laneX, depthY);

    // Draw edge arrows if content extends beyond viewport
    final topY = depthY(0);
    final bottomY = depthY(maxDepth.toDouble());
    _drawEdgeArrow(canvas, size, isTop: true, show: topY < padding);
    _drawEdgeArrow(canvas, size, isTop: false, show: bottomY > size.height - padding);
  }

  void _drawSegment(
    Canvas canvas,
    BranchSegment segment,
    double Function(int) laneX,
    double Function(double) depthY,
    Paint paint,
    Size size,
    double padding,
  ) {
    final fromX = laneX(segment.fromLane);
    final fromY = depthY(segment.fromDepth.toDouble());
    final toX = laneX(segment.toLane);
    final toY = depthY(segment.toDepth.toDouble());

    // Skip if entirely outside visible range
    if (fromY > size.height + 50 && toY > size.height + 50) return;
    if (fromY < -50 && toY < -50) return;

    final path = Path();
    path.moveTo(fromX, fromY);

    if (segment.type == SegmentType.straight) {
      // Simple vertical line
      path.lineTo(toX, toY);
    } else {
      // Curve out: horizontal S-curve to new lane, then straight down
      // Keep dots horizontally aligned at branch point
      final curveY = fromY; // Branch point stays at same Y

      // Horizontal S-curve
      path.cubicTo(
        fromX + (toX - fromX) * 0.3, curveY, // Control point 1
        toX - (toX - fromX) * 0.3, curveY,   // Control point 2
        toX, curveY,                          // End at same Y
      );

      // Then straight down to target
      path.lineTo(toX, toY);
    }

    canvas.drawPath(path, paint);

    // Draw termination cap if this is a terminal segment
    if (segment.isTerminal && toY > -20 && toY < size.height + 20) {
      final capPaint = Paint()
        ..color = paint.color
        ..strokeWidth = paint.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(toX - 4, toY),
        Offset(toX + 4, toY),
        capPaint,
      );
    }
  }

  void _drawScrollIndicator(
    Canvas canvas,
    Size size,
    double centerX,
    double padding,
    double totalHeight,
    double viewportOffset,
    double Function(int) laneX,
    double Function(double) depthY,
  ) {
    // Find current position on active path based on scroll progress
    final activePath = branchTree.currentPathIds;
    if (activePath.isEmpty) return;

    double dotX;
    double dotY;

    // If animating branch switch, use animated position
    if (branchAnimation != null && animationProgress > 0 && animationProgress < 1) {
      final (lane, depth) = branchAnimation!.getPosition(animationProgress);
      dotX = laneX(lane);
      dotY = depthY(depth);
    } else {
      // Normal scroll-based position
      final nodeIndex = (scrollProgress * (activePath.length - 1)).round();
      final currentNodeId = activePath[nodeIndex.clamp(0, activePath.length - 1)];
      final currentNode = branchTree.getNode(currentNodeId);
      if (currentNode == null) return;

      dotX = laneX(currentNode.assignedLane);
      dotY = depthY(currentNode.depth.toDouble());
    }

    final clampedDotY = dotY.clamp(padding, size.height - padding);

    // Glow effect
    canvas.drawCircle(
      Offset(dotX, clampedDotY),
      8,
      Paint()
        ..color = dotColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Red dot
    canvas.drawCircle(
      Offset(dotX, clampedDotY),
      5,
      Paint()..color = dotColor,
    );
  }

  void _drawEdgeArrow(Canvas canvas, Size size, {required bool isTop, required bool show}) {
    if (!show) return;

    final paint = Paint()
      ..color = inactiveLineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final arrowSize = 4.0;
    final y = isTop ? 7.0 : size.height - 7.0;
    final dir = isTop ? 1.0 : -1.0;

    canvas.drawLine(Offset(centerX - arrowSize, y + arrowSize * dir), Offset(centerX, y), paint);
    canvas.drawLine(Offset(centerX, y), Offset(centerX + arrowSize, y + arrowSize * dir), paint);
  }

  @override
  bool shouldRepaint(_BranchTreePainter oldDelegate) {
    return scrollProgress != oldDelegate.scrollProgress ||
        branchTree.nodes.length != oldDelegate.branchTree.nodes.length ||
        branchTree.currentPathIds.length != oldDelegate.branchTree.currentPathIds.length ||
        branchTree.maxLane != oldDelegate.branchTree.maxLane ||
        branchTree.minLane != oldDelegate.branchTree.minLane ||
        animationProgress != oldDelegate.animationProgress;
  }
}
