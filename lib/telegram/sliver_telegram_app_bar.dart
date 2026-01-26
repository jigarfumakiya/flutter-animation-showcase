import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SliverTelegramAppBar extends StatefulWidget {
  final AsyncCallback? onStretchTrigger;
  final String title;
  final String? subtitle;
  final Widget? backButton;
  final double expandedHeight;
  final double collapsedHeight;

  /// defaultExpandedHeightBase is for height for default state when user are not scrolling
  final double defaultExpandedHeightBase;

  const SliverTelegramAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backButton,
    this.onStretchTrigger,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.defaultExpandedHeightBase,
  });

  @override
  State<SliverTelegramAppBar> createState() => _SliverTelegramAppBarState();
}

class _SliverTelegramAppBarState extends State<SliverTelegramAppBar> {
  bool _isExpandedState = false;
  double _titleCollapseProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final collapsedHeightWithStatusBar =
        widget.collapsedHeight + statusBarHeight;
    final currentExpandedHeight = _isExpandedState
        ? widget.expandedHeight
        : (widget.defaultExpandedHeightBase + statusBarHeight);

    return SliverAppBar(
      pinned: true,
      stretch: true,
      onStretchTrigger: widget.onStretchTrigger,
      expandedHeight: currentExpandedHeight,
      collapsedHeight: widget.collapsedHeight,
      toolbarHeight: widget.collapsedHeight,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.black,
      flexibleSpace: TelegramAppBarFlexibleSpace(
        statusBarHeight: statusBarHeight,
        screenWidth: screenWidth,
        minHeight: collapsedHeight,
        maxHeight: currentExpandedHeight,
        defaultMaxHeight: defaultExpandedHeight,
        expandedStateHeight: expandedStateHeight,
        isExpandedState: _isExpandedState,
        onHeightChanged: _onHeightChanged,
        onTitleProgress: _onTitleProgress,
      ),
    );
  }
}

class TelegramAppBarFlexibleSpace extends StatefulWidget {
  const TelegramAppBarFlexibleSpace({super.key});

  @override
  State<TelegramAppBarFlexibleSpace> createState() =>
      _TelegramAppBarFlexibleSpaceState();
}

class _TelegramAppBarFlexibleSpaceState
    extends State<TelegramAppBarFlexibleSpace> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Track height changes when expanded
        final currentHeight = constraints.maxHeight;

        return Stack(

        );
      },
    );
  }
}
