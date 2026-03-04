import 'package:flutter/material.dart';
import 'package:flutter_animation_showcase/blinkit/blinkit_page.dart';
import 'package:flutter_animation_showcase/telegram/telegram_profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Animation Showcase')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Telegram Profile Animation'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TelegramProfile(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Blinkit Product Card Animation'),
            subtitle: Text(
              'Hero transition · Shimmer · Collapsing header · PageView swipe',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlinkitPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
