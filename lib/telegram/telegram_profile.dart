import 'package:flutter/material.dart';
import 'package:flutter_animation_showcase/telegram/sliver_telegram_app_bar.dart';

class TelegramProfile extends StatefulWidget {
  const TelegramProfile({super.key});

  @override
  State<TelegramProfile> createState() => _TelegramProfileState();
}

class _TelegramProfileState extends State<TelegramProfile> {
  final controller = TelegramAppBarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverTelegramAppBar(
            controller: controller,
            config: TelegramAppBarConfig(

            ),
            title: 'Channel',
            subtitle: '974,652 subscribers',
            imageUrl: 'https://picsum.photos/800/800',
            isNetworkImage: true,
            collapsedHeight: 56.0,
            expandedHeight: 185.0,
            expandedStateHeightRatio: 0.5,
            actions: [
              TelegramActionButton(
                icon: Icons.notifications_off_outlined,
                label: 'unmute',
              ),
              TelegramActionButton(icon: Icons.search, label: 'search'),
              TelegramActionButton(icon: Icons.exit_to_app, label: 'leave'),
              TelegramActionButton(icon: Icons.more_horiz, label: 'more'),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverTelegramActionButtons(
            controller: controller,
            actions: [
              TelegramActionButton(
                icon: Icons.notifications_off_outlined,
                label: 'unmute',
              ),
              TelegramActionButton(icon: Icons.search, label: 'search'),
              TelegramActionButton(icon: Icons.exit_to_app, label: 'leave'),
              TelegramActionButton(icon: Icons.more_horiz, label: 'more'),
            ],
          ),

          SliverToBoxAdapter(child: descriptionCard()),

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

  Widget descriptionCard() {
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
              _tap(text: 'Gifts 💝💝🎁', isSelected: true),
              _tap(text: 'Media', isSelected: false),
              _tap(text: 'Links', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tap({required String text, required bool isSelected}) {
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
