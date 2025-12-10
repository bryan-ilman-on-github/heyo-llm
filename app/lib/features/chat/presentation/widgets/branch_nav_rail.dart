import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/heyo_theme.dart';
import '../../domain/models/branch_tree.dart';

/// Git-like branch visualization rail with mini-map canvas
/// Shows complete conversation tree with all branches visible
/// Red dot navigates like Google Maps mini-player with smooth animations
/// Supports zoom with pinch gesture and fixed mode
class BranchNavRail extends StatefulWidget {
  final ScrollController scrollController;
  final int messageCount;
  final BranchTreeModel branchTree;
  final bool branchColoringEnabled;

  const BranchNavRail({
    super.key,
    required this.scrollController,
    required this.messageCount,
    required this.branchTree,
    this.branchColoringEnabled = false,
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

  // Track previous path for detecting branch switches
  List<String> _previousPathIds = [];

  // Zoom and pan state
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  bool _isFixedMode = false; // When true, doesn't follow red dot
  double _baseZoom = 1.0;
  Offset _basePanOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero; // Track start point for pan

  // Canvas dimensions
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

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    widget.scrollController.addListener(_onScroll);
    _previousPathIds = List.from(widget.branchTree.currentPathIds);
  }

  @override
  void didUpdateWidget(BranchNavRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect branch switch
    final newPathIds = widget.branchTree.currentPathIds;
    if (!_listEquals(_previousPathIds, newPathIds) &&
        _previousPathIds.isNotEmpty &&
        newPathIds.isNotEmpty) {
      // Skip animation - just recalculate position and show final state
      // Force recalculate scroll progress after frame builds
      // This ensures red dot updates immediately on branch switch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScroll();
      });
      HapticFeedback.selectionClick();
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

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final position = widget.scrollController.position;
    final maxScroll = position.maxScrollExtent;

    if (maxScroll <= 0) {
      setState(() => _scrollProgress = 1.0);
      return;
    }

    final currentScroll = position.pixels;
    // Add look-ahead bias (1/3 of viewport) to trigger node switch earlier
    // This helps the indicator reflect messages "showing up from below"
    final lookAhead = position.viewportDimension / 3;

    setState(() {
      _scrollProgress = ((currentScroll + lookAhead) / maxScroll).clamp(
        0.0,
        1.0,
      );
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

  void _resetZoom() {
    HapticFeedback.mediumImpact();
    setState(() {
      _zoom = 1.0;
      _panOffset = Offset.zero;
      _isFixedMode = false;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _zoom;
    _basePanOffset = _panOffset;
    _startFocalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Zoom
      final newZoom = (_baseZoom * details.scale).clamp(0.5, 3.0);
      final zoomChanged = (newZoom - _zoom).abs() > 0.01;
      _zoom = newZoom;

      // Pan - calculate total delta from start point
      final totalPanDelta = details.localFocalPoint - _startFocalPoint;
      final hasPan = totalPanDelta.dx.abs() > 2 || totalPanDelta.dy.abs() > 2;

      if (hasPan || zoomChanged) {
        _panOffset = _basePanOffset + totalPanDelta;
        _isFixedMode = true; // Enter fixed mode when user interacts
      }
    });
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
                offset: Offset(
                  (_canvasWidth + _gapWidth) * (1 - _slideAnimation.value),
                  0,
                ),
                child: Opacity(opacity: _fadeAnimation.value, child: child),
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
          _handlePosition =
              (_handlePosition + details.delta.dy / availableHeight).clamp(
                0.0,
                1.0,
              );
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
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onLongPress: _resetZoom,
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
                color: context.textTertiary.withValues(
                  alpha: 0.15,
                ), // Faint border
                width: 1,
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
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _BranchTreePainter(
                      scrollProgress: _scrollProgress,
                      branchTree: widget.branchTree,
                      visibleMessageCount: widget.messageCount,
                      activeLineColor: context.textTertiary.withValues(
                        alpha: 0.5,
                      ),
                      inactiveLineColor: context.textTertiary.withValues(
                        alpha: 0.2,
                      ),
                      activeNodeColor: context.textTertiary.withValues(
                        alpha: 0.6,
                      ),
                      inactiveNodeColor: context.textTertiary.withValues(
                        alpha: 0.25,
                      ),
                      dotColor: HeyoColors.error,
                      zoom: _zoom,
                      panOffset: _panOffset,
                      isFixedMode: _isFixedMode,
                      canvasWidth: _canvasWidth,
                      branchColoringEnabled: widget.branchColoringEnabled,
                    ),
                    size: Size(_canvasWidth, _canvasHeight),
                  ),
                  // Fixed mode indicator
                  if (_isFixedMode)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.textTertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(_zoom * 100).round()}%',
                          style: TextStyle(
                            fontSize: 8,
                            color: context.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for complete branch tree visualization
/// Draws ALL branches, highlighting the active path
class _BranchTreePainter extends CustomPainter {
  final double scrollProgress;
  final BranchTreeModel branchTree;
  final int visibleMessageCount;
  final Color activeLineColor;
  final Color inactiveLineColor;
  final Color activeNodeColor;
  final Color inactiveNodeColor;
  final Color dotColor;
  final double zoom;
  final Offset panOffset;
  final bool isFixedMode;
  final double canvasWidth;
  final bool branchColoringEnabled;

  _BranchTreePainter({
    required this.scrollProgress,
    required this.branchTree,
    required this.visibleMessageCount,
    required this.activeLineColor,
    required this.inactiveLineColor,
    required this.activeNodeColor,
    required this.inactiveNodeColor,
    required this.dotColor,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.isFixedMode = false,
    this.canvasWidth = 120,
    this.branchColoringEnabled = false,
  });

  /// Get color for a branch when branch coloring is enabled
  Color _getBranchColor(int branchIndex, bool isActive) {
    final colors = HeyoColors.branchColors;
    final colorIndex = branchIndex % colors.length;
    final baseColor = colors[colorIndex];
    return isActive
        ? baseColor.withValues(alpha: 0.7)
        : baseColor.withValues(alpha: 0.35);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (branchTree.nodes.isEmpty) return;

    final padding = 14.0;
    final viewportHeight = size.height - (padding * 2);

    // Fixed lane width - branches can go off-screen
    final laneWidth = BranchTreeModel.laneWidth;

    // Calculate viewport scrolling
    final maxDepth = branchTree.maxDepth;
    final visibleRatio = maxDepth > 0
        ? (5 / (maxDepth + 1)).clamp(0.12, 1.0)
        : 1.0;
    final totalHeight = viewportHeight / visibleRatio;

    // Calculate current node's lane for horizontal follow (snap to discrete node)
    final activePath = branchTree.currentPathIds;
    int currentLane = 0;
    int currentNodeIndex = 0;
    if (activePath.isNotEmpty) {
      final pathLength = activePath.length;
      // Simple mapping: scroll progress maps directly to path position
      currentNodeIndex = pathLength == 1
          ? 0
          : (scrollProgress * (pathLength - 1)).round().clamp(
              0,
              pathLength - 1,
            );
      final node = branchTree.getNode(activePath[currentNodeIndex]);
      currentLane = node?.assignedLane ?? 0;
    }

    // Calculate follow offset (centers red dot horizontally when in follow mode)
    final baseCenterX = padding + 10; // Left-aligned with some padding
    final redDotX = baseCenterX + (currentLane * laneWidth);
    final canvasCenter = size.width / 2;
    final horizontalFollowOffset = isFixedMode ? 0.0 : (canvasCenter - redDotX);

    // Apply zoom and pan transform
    canvas.save();
    final effectivePanX = isFixedMode ? panOffset.dx : horizontalFollowOffset;
    final effectivePanY = panOffset.dy;
    canvas.translate(
      size.width / 2 + effectivePanX,
      size.height / 2 + effectivePanY,
    );
    canvas.scale(zoom);
    canvas.translate(-size.width / 2, -size.height / 2);

    // In fixed mode, don't auto-scroll to follow. Otherwise, follow scroll progress.
    final effectiveScrollProgress = isFixedMode ? 0.5 : scrollProgress;
    final viewportOffset =
        (totalHeight - viewportHeight) * effectiveScrollProgress;

    // Center X is at left edge (lane 0), branches go rightward
    final centerX = padding + 10; // Left-aligned with some padding

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
      final segmentPaint = branchColoringEnabled
          ? (Paint()
              ..color = _getBranchColor(segment.branchIndex, false)
              ..strokeWidth = 1.5
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke)
          : inactiveLine;
      _drawSegment(canvas, segment, laneX, depthY, segmentPaint, size, padding);
    }

    for (final segment in branchTree.activeSegments) {
      final segmentPaint = branchColoringEnabled
          ? (Paint()
              ..color = _getBranchColor(segment.branchIndex, true)
              ..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke)
          : activeLine;
      _drawSegment(canvas, segment, laneX, depthY, segmentPaint, size, padding);
    }

    // Get the current scroll node ID for red dot (reuse activePath from above)
    final currentScrollNodeId =
        activePath.isNotEmpty && currentNodeIndex < activePath.length
        ? activePath[currentNodeIndex]
        : null;

    // Draw all nodes (inactive first, then active on top)
    // Also draw red dot at the exact same position as its corresponding grey node
    for (final node in branchTree.nodes.values) {
      final isActive = branchTree.isOnCurrentPath(node.id);
      final nodeY = depthY(node.depth.toDouble());
      final nodeX = laneX(node.assignedLane);

      // Skip if outside visible range (accounting for zoom)
      if (nodeY < -50 || nodeY > size.height + 50) continue;

      if (isActive) {
        // Filled dot for active path
        final nodePaint = branchColoringEnabled
            ? (Paint()..color = _getBranchColor(node.branchIndex, true))
            : activeNode;
        canvas.drawCircle(Offset(nodeX, nodeY), 3.5, nodePaint);

        // Draw red scroll indicator if this is the current node
        if (node.id == currentScrollNodeId) {
          // Glow effect
          canvas.drawCircle(
            Offset(nodeX, nodeY),
            8,
            Paint()
              ..color = dotColor.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          );
          // Red dot
          canvas.drawCircle(Offset(nodeX, nodeY), 5, Paint()..color = dotColor);
        }
      } else {
        // Outline dot for inactive branches
        final nodePaint = branchColoringEnabled
            ? (Paint()
                ..color = _getBranchColor(node.branchIndex, false)
                ..strokeWidth = 1.5
                ..style = PaintingStyle.stroke)
            : inactiveNode;
        canvas.drawCircle(Offset(nodeX, nodeY), 3.0, nodePaint);
      }
    }

    // Draw edge arrows if content extends beyond viewport
    final topY = depthY(0);
    final bottomY = depthY(maxDepth.toDouble());
    _drawEdgeArrow(canvas, size, isTop: true, show: topY < padding);
    _drawEdgeArrow(
      canvas,
      size,
      isTop: false,
      show: bottomY > size.height - padding,
    );

    canvas.restore();
  }

  // Removed _drawScrollIndicator - now drawn inline with nodes for exact position match

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
        fromX + (toX - fromX) * 0.3,
        curveY, // Control point 1
        toX - (toX - fromX) * 0.3,
        curveY, // Control point 2
        toX,
        curveY, // End at same Y
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

      canvas.drawLine(Offset(toX - 4, toY), Offset(toX + 4, toY), capPaint);
    }
  }

  void _drawEdgeArrow(
    Canvas canvas,
    Size size, {
    required bool isTop,
    required bool show,
  }) {
    if (!show) return;

    final paint = Paint()
      ..color = inactiveLineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leftX = 24.0; // Left-aligned arrows
    final arrowSize = 4.0;
    final y = isTop ? 7.0 : size.height - 7.0;
    final dir = isTop ? 1.0 : -1.0;

    canvas.drawLine(
      Offset(leftX - arrowSize, y + arrowSize * dir),
      Offset(leftX, y),
      paint,
    );
    canvas.drawLine(
      Offset(leftX, y),
      Offset(leftX + arrowSize, y + arrowSize * dir),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BranchTreePainter oldDelegate) {
    return scrollProgress != oldDelegate.scrollProgress ||
        branchTree.nodes.length != oldDelegate.branchTree.nodes.length ||
        !_pathEquals(
          branchTree.currentPathIds,
          oldDelegate.branchTree.currentPathIds,
        ) ||
        branchTree.maxLane != oldDelegate.branchTree.maxLane ||
        branchTree.minLane != oldDelegate.branchTree.minLane ||
        visibleMessageCount != oldDelegate.visibleMessageCount ||
        zoom != oldDelegate.zoom ||
        panOffset != oldDelegate.panOffset ||
        isFixedMode != oldDelegate.isFixedMode ||
        branchColoringEnabled != oldDelegate.branchColoringEnabled;
  }

  bool _pathEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
