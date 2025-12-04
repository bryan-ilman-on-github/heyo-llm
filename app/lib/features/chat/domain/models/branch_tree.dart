import 'dart:collection';

import 'message.dart';

/// Segment type for drawing
enum SegmentType {
  straight,   // Same lane, vertical line
  curveOut,   // Parent lane to child lane (branching out)
}

/// A node in the branch tree visualization
class TreeNode {
  final String id;
  final String? parentId;
  final List<String> childrenIds;
  final int depth;           // Distance from root (0-indexed)
  final int siblingIndex;    // Which sibling this is (0, 1, 2...)
  final int siblingsCount;   // Total siblings at this branch point
  int assignedLane;          // Globally consistent lane (-n to +n, 0 = center)

  TreeNode({
    required this.id,
    this.parentId,
    required this.childrenIds,
    required this.depth,
    required this.siblingIndex,
    required this.siblingsCount,
    this.assignedLane = 0,
  });

  bool get hasChildren => childrenIds.isNotEmpty;
  bool get hasSiblings => siblingsCount > 1;
}

/// A drawable segment between two nodes
class BranchSegment {
  final String fromId;
  final String toId;
  final int fromLane;
  final int toLane;
  final int fromDepth;
  final int toDepth;
  final bool isOnCurrentPath;
  final SegmentType type;
  final bool isTerminal;     // True if this segment ends at a leaf node

  const BranchSegment({
    required this.fromId,
    required this.toId,
    required this.fromLane,
    required this.toLane,
    required this.fromDepth,
    required this.toDepth,
    required this.isOnCurrentPath,
    required this.type,
    this.isTerminal = false,
  });
}

/// Global tree representation for branch visualization
class BranchTreeModel {
  final Map<String, TreeNode> nodes;
  final List<String> currentPathIds;
  final int minLane;
  final int maxLane;
  final int maxDepth;
  final List<BranchSegment> _segments;

  BranchTreeModel._({
    required this.nodes,
    required this.currentPathIds,
    required this.minLane,
    required this.maxLane,
    required this.maxDepth,
    required List<BranchSegment> segments,
  }) : _segments = segments;

  /// All segments in the tree
  List<BranchSegment> get allSegments => _segments;

  /// Only segments on the current active path
  List<BranchSegment> get activeSegments =>
      _segments.where((s) => s.isOnCurrentPath).toList();

  /// Only segments NOT on the current path (inactive branches)
  List<BranchSegment> get inactiveSegments =>
      _segments.where((s) => !s.isOnCurrentPath).toList();

  /// Total number of unique lanes used
  int get laneCount => maxLane - minLane + 1;

  /// Get adaptive lane width based on branch count
  double get adaptiveLaneWidth {
    if (laneCount < 7) return 14.0;
    if (laneCount < 15) return 10.0;
    return 6.0;
  }

  /// Check if a node is on the current path
  bool isOnCurrentPath(String nodeId) => currentPathIds.contains(nodeId);

  /// Get node by ID
  TreeNode? getNode(String id) => nodes[id];

  /// Build tree model from message tree
  factory BranchTreeModel.fromMessageTree(
    Map<String, Message> messageTree,
    List<String> currentPath,
  ) {
    if (messageTree.isEmpty || currentPath.isEmpty) {
      return BranchTreeModel._(
        nodes: {},
        currentPathIds: [],
        minLane: 0,
        maxLane: 0,
        maxDepth: 0,
        segments: [],
      );
    }

    // Build TreeNodes from messages
    final nodes = <String, TreeNode>{};
    final rootId = currentPath.first;

    // BFS to build tree and assign depths
    final queue = Queue<(String, int)>(); // (messageId, depth)
    queue.add((rootId, 0));

    int maxDepth = 0;

    while (queue.isNotEmpty) {
      final (msgId, depth) = queue.removeFirst();
      final message = messageTree[msgId];
      if (message == null || nodes.containsKey(msgId)) continue;

      maxDepth = depth > maxDepth ? depth : maxDepth;

      nodes[msgId] = TreeNode(
        id: msgId,
        parentId: message.parentId,
        childrenIds: List.from(message.childrenIds),
        depth: depth,
        siblingIndex: message.siblingIndex,
        siblingsCount: message.siblingsCount,
      );

      // Add children to queue
      for (final childId in message.childrenIds) {
        queue.add((childId, depth + 1));
      }
    }

    // Assign lanes using BFS
    final (minLane, maxLane) = _assignLanes(nodes, rootId);

    // Build segments
    final segments = _buildSegments(nodes, currentPath);

    return BranchTreeModel._(
      nodes: nodes,
      currentPathIds: currentPath,
      minLane: minLane,
      maxLane: maxLane,
      maxDepth: maxDepth,
      segments: segments,
    );
  }

  /// Assign lanes to all nodes using BFS
  /// Returns (minLane, maxLane)
  static (int, int) _assignLanes(Map<String, TreeNode> nodes, String rootId) {
    final root = nodes[rootId];
    if (root == null) return (0, 0);

    root.assignedLane = 0;
    int minLane = 0;
    int maxLane = 0;

    // BFS to assign lanes
    final queue = Queue<String>();
    queue.add(rootId);

    while (queue.isNotEmpty) {
      final nodeId = queue.removeFirst();
      final node = nodes[nodeId];
      if (node == null) continue;

      final children = node.childrenIds
          .map((id) => nodes[id])
          .whereType<TreeNode>()
          .toList();

      if (children.isEmpty) continue;

      // First child inherits parent's lane
      children[0].assignedLane = node.assignedLane;
      queue.add(children[0].id);

      // Additional children spread out alternating
      // +1, -1, +2, -2, +3, -3, ...
      for (int i = 1; i < children.length; i++) {
        final offset = _getLaneOffset(i);
        children[i].assignedLane = node.assignedLane + offset;

        if (children[i].assignedLane < minLane) {
          minLane = children[i].assignedLane;
        }
        if (children[i].assignedLane > maxLane) {
          maxLane = children[i].assignedLane;
        }

        queue.add(children[i].id);
      }
    }

    return (minLane, maxLane);
  }

  /// Get lane offset for sibling index
  /// index 1 → +1, index 2 → -1, index 3 → +2, index 4 → -2, ...
  static int _getLaneOffset(int siblingIndex) {
    if (siblingIndex <= 0) return 0;
    final magnitude = (siblingIndex + 1) ~/ 2;
    final sign = siblingIndex.isOdd ? 1 : -1;
    return magnitude * sign;
  }

  /// Build all segments from node relationships
  static List<BranchSegment> _buildSegments(
    Map<String, TreeNode> nodes,
    List<String> currentPath,
  ) {
    final segments = <BranchSegment>[];
    final currentPathSet = currentPath.toSet();

    for (final node in nodes.values) {
      for (final childId in node.childrenIds) {
        final child = nodes[childId];
        if (child == null) continue;

        final isOnPath = currentPathSet.contains(node.id) &&
                         currentPathSet.contains(childId);

        final type = node.assignedLane == child.assignedLane
            ? SegmentType.straight
            : SegmentType.curveOut;

        // Check if child is a leaf (terminal)
        final isTerminal = child.childrenIds.isEmpty;

        segments.add(BranchSegment(
          fromId: node.id,
          toId: childId,
          fromLane: node.assignedLane,
          toLane: child.assignedLane,
          fromDepth: node.depth,
          toDepth: child.depth,
          isOnCurrentPath: isOnPath,
          type: type,
          isTerminal: isTerminal,
        ));
      }
    }

    return segments;
  }
}
