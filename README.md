# Flutter Animation Showcase

A collection of beautifully crafted animations from popular apps, recreated in Flutter.

---
## Telegram Profile Animation

A pixel-perfect recreation of Telegram's profile header animation featuring smooth transitions between collapsed, expanded, and full-screen states.

<p align="center">
  <img src="previews/telegram_profile.gif" width="300" alt="Telegram Profile Animation"/>
</p>

### Usage

```dart
import 'package:flutter_animation_showcase/telegram/sliver_telegram_app_bar.dart';

CustomScrollView(
  slivers: [
    SliverTelegramAppBar(
      title: 'John Doe',
      subTitle: 'Online',
      imageUrl: 'https://example.com/avatar.jpg',
      actions: [
        TelegramActionButton(icon: Icons.call, label: 'Call'),
        TelegramActionButton(icon: Icons.videocam, label: 'Video'),
        TelegramActionButton(icon: Icons.search, label: 'Search'),
        TelegramActionButton(icon: Icons.more_horiz, label: 'More'),
      ],
    ),
    // Your content slivers here
  ],
)
```

For customization options, check out [`sliver_telegram_app_bar.dart`](lib/telegram/sliver_telegram_app_bar.dart).

---


## Blinkit Product Animation

A recreation of Blinkit's product browsing experience with fluid hero transitions, staggered grid exit animations, and an expandable product detail card.

<p align="center">
  <img src="previews/blinkit_hero.gif" width="300" alt="Blinkit Product Animation"/>
</p>

### What's animated

- **Hero transition** — product image flies from the grid card to the detail page
- **Grid exit** — all cards in the tapped row fly upward together; other rows follow with a staggered delay
- **Detail card expansion** — card grows from partial to full screen as you scroll into the content
- **Overscroll dismiss** — pull down past the top to collapse or dismiss the card with a bouncy curve
- **Page swipe** — swipe between products on the detail page with adjacent cards peeking at the sides

### Key files

| File | Description |
|---|---|
| [`lib/blinkit/blinkit_page.dart`](lib/blinkit/blinkit_page.dart) | Product grid, stagger animation, hero source |
| [`lib/blinkit/product_detail_page.dart`](lib/blinkit/product_detail_page.dart) | Detail card, expansion controller, hero destination |

---


## License

MIT License
