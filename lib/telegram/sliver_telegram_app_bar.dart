import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================
// CONTROLLER
// ============================================================

/// Controller to manage the state of TelegramAppBar and sync with action buttons
class TelegramAppBarController extends ChangeNotifier {
  bool _isExpandedState = false;
  double _shrinkProgress = 0.0;

  /// Whether the app bar is in full expanded state
  bool get isExpandedState => _isExpandedState;

  /// Progress of button shrinking (0.0 = full size, 1.0 = hidden)
  double get shrinkProgress => _shrinkProgress;

  void _updateExpandedState(bool isExpanded) {
    if (_isExpandedState != isExpanded) {
      _isExpandedState = isExpanded;
      notifyListeners();
    }
  }

  void _updateShrinkProgress(double progress) {
    print(
      "🟢 CONTROLLER: Received progress=$progress (current=$_shrinkProgress)",
    );
    if (_shrinkProgress != progress) {
      _shrinkProgress = progress;
      print("🟢 CONTROLLER: Updated and notifying listeners");
      notifyListeners();
    } else {
      print("🟢 CONTROLLER: Same value, skipping update");
    }
  }
}

// ============================================================
// PUBLIC API
// ============================================================

/// A Telegram-style animated SliverAppBar with stretch and collapse animations.
///
/// Usage:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverTelegramAppBar(
///       title: 'Channel Name',
///       subtitle: '1M subscribers',
///       imageUrl: 'https://example.com/image.jpg',
///       collapsedHeight: 56.0,
///       expandedHeight: 185.0,
///       actions: [
///         TelegramActionButton(
///           icon: Icons.notifications_off_outlined,
///           label: 'unmute',
///         ),
///       ],
///     ),
///     // Your content here
///   ],
/// )
/// ```
class SliverTelegramAppBar extends StatefulWidget {
  /// The main title text (e.g., channel name)
  final String title;

  /// The subtitle text (e.g., subscriber count)
  final String subtitle;

  /// URL or asset path for the header image
  final String imageUrl;

  /// Height when fully collapsed (toolbar height)
  final double collapsedHeight;

  /// Default expanded height (when not in full-screen expanded state)
  final double expandedHeight;

  /// Height when in full-screen expanded state
  /// If null, calculated as screenHeight * expandedStateHeightRatio
  final double? fullExpandedHeight;

  /// The ratio of screen height for full expanded state (default: 0.65)
  /// Only used if fullExpandedHeight is null
  final double expandedStateHeightRatio;

  /// Configuration for all animation and layout parameters
  final TelegramAppBarConfig config;

  /// Controller to sync state with action buttons (optional)
  final TelegramAppBarController? controller;

  /// Action buttons shown in the expanded state
  final List<TelegramActionButton>? actions;

  /// Custom leading widget (defaults to back button)
  final Widget? leading;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Background color (defaults to black)
  final Color? backgroundColor;

  /// Whether to use network image or asset image
  final bool isNetworkImage;

  /// Custom image error builder
  final Widget Function(BuildContext, Object, StackTrace?)? imageErrorBuilder;

  const SliverTelegramAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.collapsedHeight = 56.0,
    this.expandedHeight = 185.0,
    this.fullExpandedHeight,
    this.expandedStateHeightRatio = 0.65,
    this.config = const TelegramAppBarConfig(),
    this.controller,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.backgroundColor,
    this.isNetworkImage = true,
    this.imageErrorBuilder,
  });

  @override
  State<SliverTelegramAppBar> createState() => _SliverTelegramAppBarState();
}

/// Configuration for action buttons in the expanded state
class TelegramActionButton {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const TelegramActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });
}

/// Configuration class for all animation and layout parameters
class TelegramAppBarConfig {
  // Avatar configuration
  final double avatarSize;
  final double avatarMaxStretchRatio; // Ratio of avatarSize
  final double avatarStretchFactor;
  final double avatarShrinkFactor;
  final double avatarCollapsedSize;

  // Button configuration
  final double buttonHeight;
  final double buttonWidth;
  final double buttonRadius;
  final double buttonBlurSigma;

  // Text sizes - Expanded state
  final double titleSizeExpanded;
  final double subtitleSizeExpanded;

  // Text sizes - Default state
  final double titleSizeDefault;
  final double subtitleSizeDefault;

  // Text sizes - Collapsed state
  final double titleSizeCollapsed;
  final double subtitleSizeCollapsed;

  // Spacing
  final double horizontalPadding;
  final double expandedPadding;
  final double buttonSpacing;

  // Animation durations
  final Duration fastAnimation;
  final Duration mediumAnimation;

  // Threshold for exiting expanded state (ratio of expanded height)
  final double expandedExitThreshold;

  const TelegramAppBarConfig({
    // Avatar
    this.avatarSize = 90.0,
    this.avatarMaxStretchRatio = 0.33, // 33% of avatar size
    this.avatarStretchFactor = 0.3,
    this.avatarShrinkFactor = 0.65,
    this.avatarCollapsedSize = 35.0,

    // Buttons
    this.buttonHeight = 56.0,
    this.buttonWidth = 75.0,
    this.buttonRadius = 12.0,
    this.buttonBlurSigma = 20.0,

    // Text sizes - Expanded
    this.titleSizeExpanded = 28.0,
    this.subtitleSizeExpanded = 16.0,

    // Text sizes - Default
    this.titleSizeDefault = 24.0,
    this.subtitleSizeDefault = 15.0,

    // Text sizes - Collapsed
    this.titleSizeCollapsed = 13.0,
    this.subtitleSizeCollapsed = 10.0,

    // Spacing
    this.horizontalPadding = 20.0,
    this.expandedPadding = 16.0,
    this.buttonSpacing = 8.0,

    // Animation
    this.fastAnimation = const Duration(milliseconds: 50),
    this.mediumAnimation = const Duration(milliseconds: 100),

    // Threshold
    this.expandedExitThreshold = 0.02,
  });

  // Calculated values
  double get avatarMaxStretch => avatarSize * avatarMaxStretchRatio;

  double get buttonInnerHeight => buttonHeight + 4.0;

  double get buttonClipRadius => buttonRadius + 6.0;
}

// ============================================================
// IMPLEMENTATION
// ============================================================

class _SliverTelegramAppBarState extends State<SliverTelegramAppBar> {
  bool _isExpandedState = false;

  @override
  void initState() {
    super.initState();
    _updateController();
  }

  @override
  void didUpdateWidget(SliverTelegramAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _updateController();
    }
  }

  void _updateController() {
    widget.controller?._updateExpandedState(_isExpandedState);
  }

  void _onHeightChanged(double currentHeight, double expandedHeight) {
    if (!_isExpandedState) return;

    final threshold = expandedHeight * widget.config.expandedExitThreshold;
    final thresholdHeight = expandedHeight - threshold;
    if (currentHeight <= thresholdHeight) {
      setState(() => _isExpandedState = false);
      widget.controller?._updateExpandedState(false);
    }
  }

  void _onStretchTrigger() {
    print('_onStretchTrigger');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isExpandedState) {
        setState(() => _isExpandedState = true);
        widget.controller?._updateExpandedState(true);
      }
    });
  }

  void _onTitleProgress(double progress) {
    widget.controller?._updateShrinkProgress(progress);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final collapsedHeight = widget.collapsedHeight + statusBarHeight;
    final defaultExpandedHeight = widget.expandedHeight + statusBarHeight;
    final fullExpandedStateHeight =
        widget.fullExpandedHeight ??
        (screenHeight * widget.expandedStateHeightRatio);

    final currentExpandedHeight = _isExpandedState
        ? fullExpandedStateHeight
        : defaultExpandedHeight;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      onStretchTrigger: () async => _onStretchTrigger(),
      expandedHeight: currentExpandedHeight,
      collapsedHeight: widget.collapsedHeight,
      toolbarHeight: widget.collapsedHeight,
      surfaceTintColor: Colors.transparent,
      backgroundColor: widget.backgroundColor ?? Colors.black,
      leading: const SizedBox.shrink(),
      // We handle leading in flexibleSpace
      flexibleSpace: _ProfileFlexibleSpace(
        title: widget.title,
        subtitle: widget.subtitle,
        imageUrl: widget.imageUrl,
        isNetworkImage: widget.isNetworkImage,
        imageErrorBuilder: widget.imageErrorBuilder,
        actions: widget.actions,
        leading: widget.leading,
        onBackPressed: widget.onBackPressed,
        collapsedHeight: widget.collapsedHeight,
        statusBarHeight: statusBarHeight,
        screenWidth: screenWidth,
        minHeight: collapsedHeight,
        maxHeight: currentExpandedHeight,
        defaultMaxHeight: defaultExpandedHeight,
        expandedStateHeight: fullExpandedStateHeight,
        isExpandedState: _isExpandedState,
        onHeightChanged: _onHeightChanged,
        onTitleProgress: _onTitleProgress,
        config: widget.config,
      ),
    );
  }
}

// ============================================================
// FLEXIBLE SPACE
// ============================================================

class _ProfileFlexibleSpace extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isNetworkImage;
  final Widget Function(BuildContext, Object, StackTrace?)? imageErrorBuilder;
  final List<TelegramActionButton>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final double collapsedHeight;
  final double statusBarHeight;
  final double screenWidth;
  final double minHeight;
  final double maxHeight;
  final double defaultMaxHeight;
  final double expandedStateHeight;
  final bool isExpandedState;
  final void Function(double height, double maxHeight) onHeightChanged;
  final void Function(double progress) onTitleProgress;
  final TelegramAppBarConfig config;

  const _ProfileFlexibleSpace({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isNetworkImage,
    required this.imageErrorBuilder,
    required this.actions,
    required this.leading,
    required this.onBackPressed,
    required this.collapsedHeight,
    required this.statusBarHeight,
    required this.screenWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.defaultMaxHeight,
    required this.expandedStateHeight,
    required this.isExpandedState,
    required this.onHeightChanged,
    required this.onTitleProgress,
    required this.config,
  });

  @override
  State<_ProfileFlexibleSpace> createState() => _ProfileFlexibleSpaceState();
}

class _ProfileFlexibleSpaceState extends State<_ProfileFlexibleSpace> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentHeight = constraints.maxHeight;

        if (widget.isExpandedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onHeightChanged(currentHeight, widget.expandedStateHeight);
            }
          });
        }

        return _ProfileHeader(
          title: widget.title,
          subtitle: widget.subtitle,
          imageUrl: widget.imageUrl,
          isNetworkImage: widget.isNetworkImage,
          imageErrorBuilder: widget.imageErrorBuilder,
          actions: widget.actions,
          leading: widget.leading,
          onBackPressed: widget.onBackPressed,
          collapsedHeight: widget.collapsedHeight,
          statusBarHeight: widget.statusBarHeight,
          screenWidth: widget.screenWidth,
          currentHeight: currentHeight,
          minHeight: widget.minHeight,
          maxHeight: widget.maxHeight,
          defaultMaxHeight: widget.defaultMaxHeight,
          isExpandedState: widget.isExpandedState,
          onTitleProgress: widget.onTitleProgress,
          config: widget.config,
        );
      },
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _ProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isNetworkImage;
  final Widget Function(BuildContext, Object, StackTrace?)? imageErrorBuilder;
  final List<TelegramActionButton>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final double collapsedHeight;
  final double statusBarHeight;
  final double screenWidth;
  final double currentHeight;
  final double minHeight;
  final double maxHeight;
  final double defaultMaxHeight;
  final bool isExpandedState;
  final void Function(double progress) onTitleProgress;
  final TelegramAppBarConfig config;

  const _ProfileHeader({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isNetworkImage,
    required this.imageErrorBuilder,
    required this.actions,
    required this.leading,
    required this.onBackPressed,
    required this.collapsedHeight,
    required this.statusBarHeight,
    required this.screenWidth,
    required this.currentHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.defaultMaxHeight,
    required this.isExpandedState,
    required this.onTitleProgress,
    required this.config,
  });

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final avatar = _calculateAvatar(progress);
    final titleData = _calculateTitle(progress, avatar);

    // Notify title progress for button shrinking
    _notifyTitleProgress(titleData.collapsedY, titleData.y);

    final avatarLeft = isExpandedState ? 0.0 : avatar.left;
    final avatarTop = isExpandedState ? 0.0 : avatar.top;
    final avatarWidth = isExpandedState ? screenWidth : avatar.size;
    final avatarHeight = isExpandedState ? currentHeight : avatar.size;
    final avatarRadius = isExpandedState ? 0.0 : avatar.size / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar/Image
        AnimatedPositioned(
          duration: config.fastAnimation,
          curve: Curves.easeInOut,
          left: avatarLeft,
          top: avatarTop,
          width: avatarWidth,
          height: avatarHeight,
          child: AnimatedContainer(
            duration: config.fastAnimation,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(avatarRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(),
          ),
        ),

        // Leading (Back button)
        _buildLeading(context),

        // Title
        _TitleText(
          text: title,
          left: _calculateTitleLeft(titleData.size),
          top: _calculateTitleTop(progress.collapse, titleData),
          fontSize: titleData.size,
          isExpandedState: isExpandedState,
          config: config,
        ),

        // Subtitle
        _SubtitleText(
          text: subtitle,
          top: _calculateSubtitleTop(progress.collapse, titleData),
          fontSize: titleData.subtitleSize,
          isExpandedState: isExpandedState,
          config: config,
        ),

        // Action buttons (expanded state only)
        if (isExpandedState && actions != null && actions!.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            top: titleData.buttonsY,
            child: _ActionButtons(
              actions: actions!,
              isExpandedState: true,
              config: config,
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    final errorBuilder =
        imageErrorBuilder ??
        (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.person, color: Colors.white54, size: 40),
        );

    if (isNetworkImage) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: errorBuilder,
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: errorBuilder,
      );
    }
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) {
      return Positioned(left: 8, top: statusBarHeight + 8, child: leading!);
    }

    return Positioned(
      left: 8,
      top: statusBarHeight + 8,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isExpandedState ? 0.4 : 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          padding: EdgeInsets.zero,
          onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  // -------------------- Calculations --------------------

  _ProgressData _calculateProgress() {
    final isStretching = currentHeight > maxHeight;
    final stretchAmount = isStretching ? currentHeight - maxHeight : 0.0;

    final collapseRange = defaultMaxHeight - minHeight;
    final collapse = isStretching
        ? 0.0
        : ((defaultMaxHeight - currentHeight) / collapseRange).clamp(0.0, 2.0);

    final eased = Curves.easeInOut.transform(collapse.clamp(0.0, 1.0));

    return _ProgressData(
      isStretching: isStretching,
      stretchAmount: stretchAmount,
      collapse: collapse,
      eased: eased,
    );
  }

  _AvatarData _calculateAvatar(_ProgressData progress) {
    final shrinkProgress = Curves.easeOut.transform(
      (progress.collapse * config.avatarShrinkFactor).clamp(0.0, 1.0),
    );

    double size;
    if (progress.isStretching) {
      size =
          config.avatarSize +
          (progress.stretchAmount * config.avatarStretchFactor).clamp(
            0.0,
            config.avatarMaxStretch,
          );
    } else {
      size = _lerp(
        config.avatarSize,
        config.avatarCollapsedSize,
        shrinkProgress,
      );
    }

    final centerX = screenWidth / 2;
    final backButtonBottom = statusBarHeight + 8 + 20;
    final baseY = backButtonBottom + config.avatarSize / 2;
    final stretchOffsetY = progress.isStretching
        ? progress.stretchAmount * 0.2
        : 0.0;
    final expandedCenterY = baseY + stretchOffsetY;

    // Calculate collapsed Y position relative to toolbar
    final avatarCollapsedY = -40.0;

    final centerY = _lerp(expandedCenterY, avatarCollapsedY, progress.collapse);

    return _AvatarData(
      size: size,
      left: centerX - size / 2,
      top: centerY - size / 2,
      centerY: centerY,
    );
  }

  _TitleData _calculateTitle(_ProgressData progress, _AvatarData avatar) {
    final avatarBottomY = avatar.centerY + avatar.size / 2;
    final toolbarCenterY = statusBarHeight + (collapsedHeight / 2);
    final collapsedTitleY = toolbarCenterY - 8;

    double titleY, titleSize, subtitleY, subtitleSize;

    if (isExpandedState) {
      titleSize = config.titleSizeExpanded;
      subtitleSize = config.subtitleSizeExpanded;
      titleY = currentHeight - 140;
      subtitleY = titleY + titleSize + 8.0;
    } else {
      titleSize = _lerp(
        config.titleSizeDefault,
        config.titleSizeCollapsed,
        progress.eased,
      );
      subtitleSize = _lerp(
        config.subtitleSizeDefault,
        config.subtitleSizeCollapsed,
        progress.eased,
      );

      final avatarToTitleGap = _lerp(
        4.0,
        20.0,
        progress.collapse.clamp(0.0, 1.0),
      );
      final titleToSubtitleGap = _lerp(
        2.0,
        8.0,
        progress.collapse.clamp(0.0, 1.0),
      );

      titleY = avatarBottomY + avatarToTitleGap;
      subtitleY = titleY + titleSize + titleToSubtitleGap;
    }

    final buttonsY = subtitleY + subtitleSize + 16;

    return _TitleData(
      y: titleY,
      size: titleSize,
      subtitleY: subtitleY,
      subtitleSize: subtitleSize,
      collapsedY: collapsedTitleY,
      buttonsY: buttonsY,
    );
  }

  double _calculateTitleLeft(double titleSize) {
    if (isExpandedState) {
      return config.expandedPadding;
    }
    return (screenWidth - (titleSize * title.length * 0.55)) / 2;
  }

  double _calculateTitleTop(double collapseProgress, _TitleData titleData) {
    if (isExpandedState) return titleData.y;
    return titleData.y < titleData.collapsedY
        ? titleData.collapsedY
        : titleData.y;
  }

  double _calculateSubtitleTop(double collapseProgress, _TitleData titleData) {
    if (isExpandedState) return titleData.subtitleY;
    final collapsedSubY = titleData.collapsedY + titleData.size + 4;
    return titleData.subtitleY < collapsedSubY
        ? collapsedSubY
        : titleData.subtitleY;
  }

  void _notifyTitleProgress(double collapsedY, double titleY) {
    final progress = ((collapsedY - (titleY + statusBarHeight)) / 15.0).clamp(
      0.0,
      1.0,
    );

    print(
      "🔵 NOTIFY: collapsedY=$collapsedY, titleY=$titleY, statusBar=$statusBarHeight, progress=$progress",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onTitleProgress(progress);
    });
  }
}

// ============================================================
// DATA CLASSES
// ============================================================

class _ProgressData {
  final bool isStretching;
  final double stretchAmount;
  final double collapse;
  final double eased;

  const _ProgressData({
    required this.isStretching,
    required this.stretchAmount,
    required this.collapse,
    required this.eased,
  });
}

class _AvatarData {
  final double size;
  final double left;
  final double top;
  final double centerY;

  const _AvatarData({
    required this.size,
    required this.left,
    required this.top,
    required this.centerY,
  });
}

class _TitleData {
  final double y;
  final double size;
  final double subtitleY;
  final double subtitleSize;
  final double collapsedY;
  final double buttonsY;

  const _TitleData({
    required this.y,
    required this.size,
    required this.subtitleY,
    required this.subtitleSize,
    required this.collapsedY,
    required this.buttonsY,
  });
}

// ============================================================
// TEXT WIDGETS
// ============================================================

class _TitleText extends StatelessWidget {
  final String text;
  final double left;
  final double top;
  final double fontSize;
  final bool isExpandedState;
  final TelegramAppBarConfig config;

  const _TitleText({
    required this.text,
    required this.left,
    required this.top,
    required this.fontSize,
    required this.isExpandedState,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: config.fastAnimation,
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: AnimatedDefaultTextStyle(
        duration: config.fastAnimation,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
        ),
        child: Text(text),
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  final String text;
  final double top;
  final double fontSize;
  final bool isExpandedState;
  final TelegramAppBarConfig config;

  const _SubtitleText({
    required this.text,
    required this.top,
    required this.fontSize,
    required this.isExpandedState,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: config.fastAnimation,
      curve: Curves.easeInOut,
      left: 16,
      right: 16,
      top: top,
      child: AnimatedAlign(
        alignment: isExpandedState ? Alignment.centerLeft : Alignment.center,
        duration: config.mediumAnimation,
        child: AnimatedDefaultTextStyle(
          duration: config.fastAnimation,
          style: TextStyle(
            color: isExpandedState ? Colors.white : Colors.grey.shade500,
            fontSize: fontSize,
          ),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// ============================================================
// ACTION BUTTONS SLIVER (for use outside appbar)
// ============================================================

/// A sliver widget that displays action buttons that shrink as the appbar collapses.
/// Use this in your CustomScrollView after the SliverTelegramAppBar when you want
/// buttons to show in the default/collapsed states (not in expanded state).
///
/// Example:
/// ```dart
/// final controller = TelegramAppBarController();
///
/// CustomScrollView(
///   slivers: [
///     SliverTelegramAppBar(controller: controller, ...),
///     SliverTelegramActionButtons(controller: controller, ...),
///   ],
/// )
/// ```
class SliverTelegramActionButtons extends StatelessWidget {
  final TelegramAppBarController controller;
  final List<TelegramActionButton> actions;
  final TelegramAppBarConfig config;

  const SliverTelegramActionButtons({
    super.key,
    required this.controller,
    required this.actions,
    this.config = const TelegramAppBarConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        print(
          "🟡 SLIVER: isExpanded=${controller.isExpandedState}, shrinkProgress=${controller.shrinkProgress}",
        );

        // Hide when in expanded state
        if (controller.isExpandedState) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: _ActionButtons(
            actions: actions,
            isExpandedState: false,
            shrinkProgress: controller.shrinkProgress,
            config: config,
          ),
        );
      },
    );
  }
}

// ============================================================
// ACTION BUTTONS
// ============================================================

class _ActionButtons extends StatelessWidget {
  final List<TelegramActionButton> actions;
  final bool isExpandedState;
  final double shrinkProgress;
  final TelegramAppBarConfig config;

  const _ActionButtons({
    required this.actions,
    required this.isExpandedState,
    this.shrinkProgress = 0.0,
    required this.config,
  });

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final t = shrinkProgress.clamp(0.0, 1.0);

    print(
      "🔴 BUTTONS: shrinkProgress=$shrinkProgress, isExpanded=$isExpandedState",
    );

    final height = _lerp(config.buttonHeight, 0.0, t);
    final paddingV = _lerp(10.0, 0.0, t);
    final iconSize = _lerp(25.0, 0.0, t);
    final fontSize = _lerp(10.0, 0.0, t);
    final radius = _lerp(config.buttonRadius, 0.0, t);

    return ClipRect(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: config.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions
                .map(
                  (action) => _ActionButton(
                    config: action,
                    isExpandedState: isExpandedState,
                    appBarConfig: config,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    paddingV: paddingV,
                    radius: radius,
                  ),
                )
                .expand(
                  (widget) => [widget, SizedBox(width: config.buttonSpacing)],
                )
                .take(actions.length * 2 - 1)
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final TelegramActionButton config;
  final bool isExpandedState;
  final TelegramAppBarConfig appBarConfig;
  final double? iconSize;
  final double? fontSize;
  final double? paddingV;
  final double? radius;

  const _ActionButton({
    required this.config,
    required this.isExpandedState,
    required this.appBarConfig,
    this.iconSize,
    this.fontSize,
    this.paddingV,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpandedState ? Colors.white : Colors.blue;
    final effectiveIconSize = iconSize ?? 25.0;
    final effectiveFontSize = fontSize ?? 10.0;
    final effectiveRadius = radius ?? appBarConfig.buttonRadius;

    final child = Container(
      width: appBarConfig.buttonWidth,
      height: appBarConfig.buttonInnerHeight,
      decoration: BoxDecoration(
        color: isExpandedState
            ? Colors.white.withOpacity(0.10)
            : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: config.onPressed,
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (effectiveIconSize > 0)
                  Icon(config.icon, size: effectiveIconSize, color: color),
                if (effectiveFontSize > 0)
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: effectiveFontSize,
                      color: color,
                      fontWeight: isExpandedState
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(appBarConfig.buttonClipRadius),
      child: isExpandedState
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: appBarConfig.buttonBlurSigma,
                sigmaY: appBarConfig.buttonBlurSigma,
              ),
              child: child,
            )
          : child,
    );
  }
}
