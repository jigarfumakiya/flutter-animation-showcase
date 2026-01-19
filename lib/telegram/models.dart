import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Represents the cover photo data for a user's profile
class CoverPhoto {
  final String color;
  final List<String> gradient;

  CoverPhoto({
    required this.color,
    required this.gradient,
  });

  factory CoverPhoto.fromJson(Map<String, dynamic> json) {
    return CoverPhoto(
      color: json['color'] as String,
      gradient: (json['gradient'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'gradient': gradient,
    };
  }

  /// Convert gradient colors from hex strings to Color objects
  List<Color> get gradientColors {
    return gradient.map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')))).toList();
  }
}

/// Represents a chat user with all their profile information
class ChatUser {
  final String id;
  final String name;
  final String username;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final String? lastSeen;
  final String avatarColor;
  final String initials;
  final String bio;
  final CoverPhoto coverPhoto;
  final String phoneNumber;
  final int photosCount;
  final int videosCount;
  final int filesCount;
  final int linksCount;
  final int voiceCount;

  ChatUser({
    required this.id,
    required this.name,
    required this.username,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    this.lastSeen,
    required this.avatarColor,
    required this.initials,
    required this.bio,
    required this.coverPhoto,
    required this.phoneNumber,
    required this.photosCount,
    required this.videosCount,
    required this.filesCount,
    required this.linksCount,
    required this.voiceCount,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      lastMessage: json['lastMessage'] as String,
      timestamp: json['timestamp'] as String,
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      lastSeen: json['lastSeen'] as String?,
      avatarColor: json['avatarColor'] as String,
      initials: json['initials'] as String,
      bio: json['bio'] as String,
      coverPhoto: CoverPhoto.fromJson(json['coverPhoto'] as Map<String, dynamic>),
      phoneNumber: json['phoneNumber'] as String,
      photosCount: json['photosCount'] as int,
      videosCount: json['videosCount'] as int,
      filesCount: json['filesCount'] as int,
      linksCount: json['linksCount'] as int,
      voiceCount: json['voiceCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'avatarColor': avatarColor,
      'initials': initials,
      'bio': bio,
      'coverPhoto': coverPhoto.toJson(),
      'phoneNumber': phoneNumber,
      'photosCount': photosCount,
      'videosCount': videosCount,
      'filesCount': filesCount,
      'linksCount': linksCount,
      'voiceCount': voiceCount,
    };
  }

  /// Convert hex color to Color object
  Color get avatarColorValue {
    return Color(int.parse(avatarColor.replaceFirst('#', '0xFF')));
  }
}

/// Service class for loading chat data from JSON assets
class ChatDataLoader {
  /// Load chat users from the JSON file
  static Future<List<ChatUser>> loadChats() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/chats.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> chatsJson = jsonMap['chats'] as List<dynamic>;

      return chatsJson.map((json) => ChatUser.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return empty list if there's an error loading the data
      debugPrint('Error loading chats: $e');
      return [];
    }
  }
}
