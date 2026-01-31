import 'dart:ui';

import 'package:flutter/material.dart';

class _ProfileConstants {
  // Heights
  static const double collapsedHeight = 56.0;
  static const double defaultExpandedHeightBase = 185.0;
  static const double expandedStateHeightRatio = 0.65;

  // Avatar
  static const double avatarSize = 90.0;
  static const double avatarMaxStretch = 30.0;
  static const double avatarStretchFactor = 0.3;
  static const double avatarShrinkFactor = 0.65;
  static const double avatarCollapsedY = -40.0;

  // Buttons
  static const double buttonHeight = 56.0;
  static const double buttonWidth = 75.0;
  static const double buttonInnerHeight = 60.0;
  static const double buttonRadius = 12.0;
  static const double buttonClipRadius = 18.0;
  static const double buttonBlurSigma = 20.0;

  // Text sizes
  static const double titleSizeExpanded = 28.0;
  static const double titleSizeDefault = 24.0;
  static const double titleSizeCollapsed = 13.0;
  static const double subtitleSizeExpanded = 16.0;
  static const double subtitleSizeDefault = 15.0;
  static const double subtitleSizeCollapsed = 10.0;

  // Spacing
  static const double horizontalPadding = 20.0;
  static const double expandedPadding = 16.0;
  static const double buttonSpacing = 8.0;

  // Animation
  static const Duration fastAnimation = Duration(milliseconds: 40);
  static const Duration mediumAnimation = Duration(milliseconds: 100);

  const _ProfileConstants._();
}

class TelegramProfileAnimation extends StatefulWidget {
  const TelegramProfileAnimation({super.key});

  @override
  State<TelegramProfileAnimation> createState() =>
      _TelegramProfileAnimationState();
}

class _TelegramProfileAnimationState extends State<TelegramProfileAnimation> {
  bool _isExpandedState = false;
  double _titleCollapseProgress = 0.0;

  /// Handles height changes to determine when to exit expanded state
  void _onHeightChanged(double currentHeight, double expandedHeight) {
    if (!_isExpandedState) return;

    // final threshold = expandedHeight * _ProfileConstants.expandedExitThreshold;
    final threshold = expandedHeight * 0.02;
    final thresholdHeight = expandedHeight - threshold;

    if (currentHeight <= thresholdHeight) {
      setState(() => _isExpandedState = false);
    }
  }

  /// Updates title collapse progress for button shrinking
  void _onTitleProgress(double progress) {
    if (_titleCollapseProgress != progress) {
      setState(() => _titleCollapseProgress = progress);
    }
  }

  /// Triggers expanded state when user pulls down
  void _onStretchTrigger() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isExpandedState) {
        setState(() => _isExpandedState = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final collapsedHeight = _ProfileConstants.collapsedHeight + statusBarHeight;
    final defaultExpandedHeight =
        _ProfileConstants.defaultExpandedHeightBase + statusBarHeight;
    final expandedStateHeight =
        screenHeight * _ProfileConstants.expandedStateHeightRatio;
    final currentExpandedHeight = _isExpandedState
        ? expandedStateHeight
        : defaultExpandedHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            stretch: true,
            onStretchTrigger: () async => _onStretchTrigger(),
            expandedHeight: currentExpandedHeight,
            collapsedHeight: _ProfileConstants.collapsedHeight,
            toolbarHeight: _ProfileConstants.collapsedHeight,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.black,
            flexibleSpace: _ProfileFlexibleSpace(
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
          ),

          // Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Action buttons (when not expanded)
          if (!_isExpandedState)
            SliverToBoxAdapter(
              child: _ActionButtons(
                shrinkProgress: _titleCollapseProgress,
                isExpandedState: false,
              ),
            ),

          // Description card
          SliverToBoxAdapter(child: _DescriptionCard()),

          // Tabs
          SliverToBoxAdapter(child: _TabsSection()),

          // Gift grid
          _GiftGrid(),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ProfileFlexibleSpace extends StatefulWidget {
  final double statusBarHeight;
  final double screenWidth;
  final double minHeight;
  final double maxHeight;
  final double defaultMaxHeight;
  final double expandedStateHeight;
  final bool isExpandedState;
  final void Function(double height, double maxHeight) onHeightChanged;
  final void Function(double progress) onTitleProgress;

  const _ProfileFlexibleSpace({
    required this.statusBarHeight,
    required this.screenWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.defaultMaxHeight,
    required this.expandedStateHeight,
    required this.isExpandedState,
    required this.onHeightChanged,
    required this.onTitleProgress,
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

        // Track height changes when expanded
        if (widget.isExpandedState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onHeightChanged(currentHeight, widget.expandedStateHeight);
            }
          });
        }

        return _ProfileHeader(
          statusBarHeight: widget.statusBarHeight,
          screenWidth: widget.screenWidth,
          currentHeight: currentHeight,
          minHeight: widget.minHeight,
          maxHeight: widget.maxHeight,
          defaultMaxHeight: widget.defaultMaxHeight,
          isExpandedState: widget.isExpandedState,
          onTitleProgress: widget.onTitleProgress,
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final double statusBarHeight;
  final double screenWidth;
  final double currentHeight;
  final double minHeight;
  final double maxHeight;
  final double defaultMaxHeight;
  final bool isExpandedState;
  final void Function(double progress) onTitleProgress;

  const _ProfileHeader({
    required this.statusBarHeight,
    required this.screenWidth,
    required this.currentHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.defaultMaxHeight,
    required this.isExpandedState,
    required this.onTitleProgress,
  });

  static const String _channelName = 'SHOWBOX';
  static const String _subscriberCount = '974,652 subscribers';
  static const String _imageUrl = 'https://picsum.photos/800/800';

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final avatar = _calculateAvatar(progress);
    final title = _calculateTitle(progress, avatar);

    // Notify title progress
    _notifyTitleProgress(title.collapsedY, title.y);

    final avatarLeft = isExpandedState ? 0.0 : avatar.left;
    final avatarTop = isExpandedState ? 0.0 : avatar.top;
    final avatarWidth = isExpandedState ? screenWidth : avatar.size;
    final avatarHeight = isExpandedState ? currentHeight : avatar.size;
    final avatarRadius = isExpandedState ? 0.0 : avatar.size / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedPositioned(
          duration: _ProfileConstants.fastAnimation,
          curve: Curves.easeInOut,
          left: avatarLeft,
          top: avatarTop,
          width: avatarWidth,
          height: avatarHeight,
          child: AnimatedContainer(
            duration: _ProfileConstants.fastAnimation,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(avatarRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
            ),
          ),
        ),

        // Back button
        _BackButton(top: statusBarHeight + 8, isExpandedState: isExpandedState),

        // Title
        _TitleText(
          text: _channelName,
          left: _calculateTitleLeft(title.size),
          top: _calculateTitleTop(progress.collapse, title),
          fontSize: title.size,
          isExpandedState: isExpandedState,
        ),

        // Subtitle
        _SubtitleText(
          text: _subscriberCount,
          top: _calculateSubtitleTop(progress.collapse, title),
          fontSize: title.subtitleSize,
          isExpandedState: isExpandedState,
        ),

        // Action buttons (expanded state only)
        if (isExpandedState)
          Positioned(
            left: 0,
            right: 0,
            top: title.buttonsY,
            child: _ActionButtons(shrinkProgress: 0.0, isExpandedState: true),
          ),
      ],
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
      (progress.collapse * _ProfileConstants.avatarShrinkFactor).clamp(
        0.0,
        1.0,
      ),
    );

    // Size
    double size;
    if (progress.isStretching) {
      size =
          _ProfileConstants.avatarSize +
          (progress.stretchAmount * _ProfileConstants.avatarStretchFactor)
              .clamp(0.0, _ProfileConstants.avatarMaxStretch);
    } else {
      size = _lerp(_ProfileConstants.avatarSize, 35.0, shrinkProgress);
    }

    // Position
    final centerX = screenWidth / 2;
    final backButtonBottom = statusBarHeight + 8 + 20;
    final baseY = backButtonBottom + _ProfileConstants.avatarSize / 2;
    final stretchOffsetY = progress.isStretching
        ? progress.stretchAmount * 0.2
        : 0.0;
    final expandedCenterY = baseY + stretchOffsetY;

    final centerY = _lerp(
      expandedCenterY,
      _ProfileConstants.avatarCollapsedY,
      progress.collapse,
    );

    return _AvatarData(
      size: size,
      left: centerX - size / 2,
      top: centerY - size / 2,
      centerY: centerY,
    );
  }

  _TitleData _calculateTitle(_ProgressData progress, _AvatarData avatar) {
    final avatarBottomY = avatar.centerY + avatar.size / 2;

    final toolbarCenterY =
        statusBarHeight + (_ProfileConstants.collapsedHeight / 2);
    final collapsedTitleY =
        toolbarCenterY - 8; // Slight offset for visual balance

    double titleY, titleSize, subtitleY, subtitleSize;

    if (isExpandedState) {
      titleSize = _ProfileConstants.titleSizeExpanded;
      subtitleSize = _ProfileConstants.subtitleSizeExpanded;
      titleY = currentHeight - 140;
      subtitleY = titleY + titleSize + 8.0;
    } else {
      titleSize = _lerp(
        _ProfileConstants.titleSizeDefault,
        _ProfileConstants.titleSizeCollapsed,
        progress.eased,
      );
      subtitleSize = _lerp(
        _ProfileConstants.subtitleSizeDefault,
        _ProfileConstants.subtitleSizeCollapsed,
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

    // final collapsedTitleY = statusBarHeight + 18;
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
      return _ProfileConstants.expandedPadding;
    }
    return (screenWidth - (titleSize * _channelName.length * 0.75)) / 2;
  }

  double _calculateTitleTop(double collapseProgress, _TitleData title) {
    if (isExpandedState) return title.y;
    // Smoothly pin title at collapsed position when it reaches there
    // title.y decreases as we scroll up, once it goes below collapsedY, pin it
    return title.y < title.collapsedY ? title.collapsedY : title.y;

  }

  double _calculateSubtitleTop(double collapseProgress, _TitleData title) {
    if (isExpandedState) return title.subtitleY;
    final collapsedSubY = title.collapsedY + title.size + 4;
    return title.subtitleY < collapsedSubY ? collapsedSubY : title.subtitleY;
  }

  void _notifyTitleProgress(double collapsedY, double titleY) {
    print("collapsedY: $collapsedY, titleY: $titleY");
    final progress = ((collapsedY - (titleY + statusBarHeight)) / 15.0).clamp(
      0.0,
      1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onTitleProgress(progress);
    });
  }
}

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

class _BackButton extends StatelessWidget {
  final double top;
  final bool isExpandedState;

  const _BackButton({required this.top, required this.isExpandedState});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 8,
      top: top,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isExpandedState ? 0.4 : 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String text;
  final double left;
  final double top;
  final double fontSize;
  final bool isExpandedState;

  const _TitleText({
    required this.text,
    required this.left,
    required this.top,
    required this.fontSize,
    required this.isExpandedState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _ProfileConstants.fastAnimation,
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: AnimatedDefaultTextStyle(
        duration: _ProfileConstants.fastAnimation,
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

  const _SubtitleText({
    required this.text,
    required this.top,
    required this.fontSize,
    required this.isExpandedState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _ProfileConstants.fastAnimation,
      curve: Curves.easeInOut,
      left: 16,
      right: 16,
      top: top,
      child: AnimatedAlign(
        alignment: isExpandedState ? Alignment.centerLeft : Alignment.center,
        duration: _ProfileConstants.mediumAnimation,
        child: AnimatedDefaultTextStyle(
          duration: _ProfileConstants.fastAnimation,
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
// ACTION BUTTONS
// ============================================================

class _ActionButtons extends StatelessWidget {
  final double shrinkProgress;
  final bool isExpandedState;

  const _ActionButtons({
    required this.shrinkProgress,
    required this.isExpandedState,
  });

  static const List<_ButtonConfig> _buttons = [
    _ButtonConfig(Icons.notifications_off_outlined, 'unmute'),
    _ButtonConfig(Icons.search, 'search'),
    _ButtonConfig(Icons.exit_to_app, 'leave'),
    _ButtonConfig(Icons.more_horiz, 'more'),
  ];

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    final t = shrinkProgress.clamp(0.0, 1.0);

    final height = _lerp(_ProfileConstants.buttonHeight, 0.0, t);
    final paddingV = _lerp(10.0, 0.0, t);
    final iconSize = _lerp(25.0, 0.0, t);
    final fontSize = _lerp(10.0, 0.0, t);
    final radius = _lerp(_ProfileConstants.buttonRadius, 0.0, t);

    return ClipRect(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _ProfileConstants.horizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buttons
                .map(
                  (config) => _ActionButton(
                    icon: config.icon,
                    label: config.label,
                    iconSize: iconSize,
                    fontSize: fontSize,
                    paddingV: paddingV,
                    radius: radius,
                    isExpandedState: isExpandedState,
                  ),
                )
                .expand(
                  (widget) => [
                    widget,
                    const SizedBox(width: _ProfileConstants.buttonSpacing),
                  ],
                )
                .take(_buttons.length * 2 - 1)
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ButtonConfig {
  final IconData icon;
  final String label;

  const _ButtonConfig(this.icon, this.label);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;
  final double paddingV;
  final double radius;
  final bool isExpandedState;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.fontSize,
    required this.paddingV,
    required this.radius,
    required this.isExpandedState,
  });

  @override
  Widget build(BuildContext context) {
    final color = isExpandedState ? Colors.white : Colors.blue;

    final child = Container(
      width: _ProfileConstants.buttonWidth,
      height: _ProfileConstants.buttonInnerHeight,
      decoration: BoxDecoration(
        color: isExpandedState
            ? Colors.white.withOpacity(0.10)
            : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconSize > 0) Icon(icon, size: iconSize, color: color),
            if (fontSize > 0)
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                  fontWeight: isExpandedState
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(_ProfileConstants.buttonClipRadius),
      child: isExpandedState
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _ProfileConstants.buttonBlurSigma,
                sigmaY: _ProfileConstants.buttonBlurSigma,
              ),
              child: child,
            )
          : child,
    );
  }
}

// ============================================================
// CONTENT SECTIONS
// ============================================================

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'description',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'For Promo ONLY: DM '),
                  TextSpan(
                    text: '@cassius_clay',
                    style: TextStyle(color: Colors.blue.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'MOVIE DLs, RECOMMENDATIONS &',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                Text('more', style: TextStyle(color: Colors.blue.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsSection extends StatelessWidget {
  const _TabsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Tab(text: 'Gifts 💝💝🎁', isSelected: true),
              _Tab(text: 'Media', isSelected: false),
              _Tab(text: 'Links', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _Tab({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade800 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade400,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _GiftGrid extends StatelessWidget {
  const _GiftGrid();

  static const List<String> _gifts = ['💝', '💝', '🎁'];
  static const List<Map<String, dynamic>> _badges = [
    {'text': 'MM', 'color': Colors.blue},
    {'text': 'BB', 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _GiftItem(
            emoji: _gifts[index % _gifts.length],
            badgeText: _badges[index % _badges.length]['text'] as String,
            badgeColor: _badges[index % _badges.length]['color'] as Color,
          ),
          childCount: 12,
        ),
      ),
    );
  }
}

class _GiftItem extends StatelessWidget {
  final String emoji;
  final String badgeText;
  final Color badgeColor;

  const _GiftItem({
    required this.emoji,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(child: Text(emoji, style: const TextStyle(fontSize: 50))),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

