import 'package:flutter/material.dart';

enum MedalRarity {
  common, // 普通
  rare, // 稀有
  epic, // 史诗
  legendary, // 传说
}

class MedalModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final MedalRarity rarity;
  final String unlockCondition;
  final int? progress; // 当前进度
  final int? target; // 目标值
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const MedalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.unlockCondition,
    this.progress,
    this.target,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  MedalModel copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    MedalRarity? rarity,
    String? unlockCondition,
    int? progress,
    int? target,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return MedalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      unlockCondition: unlockCondition ?? this.unlockCondition,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  double get progressPercent {
    if (target == null || target == 0) return 0;
    if (progress == null) return 0;
    return (progress! / target!).clamp(0.0, 1.0);
  }

  Color get rarityColor {
    switch (rarity) {
      case MedalRarity.common:
        return Colors.grey;
      case MedalRarity.rare:
        return Colors.blue;
      case MedalRarity.epic:
        return Colors.purple;
      case MedalRarity.legendary:
        return Colors.orange;
    }
  }
  
  /// 从 JSON 解析
  factory MedalModel.fromJson(Map<String, dynamic> json) {
    final rarityStr = json['rarity'] as String? ?? 'common';
    MedalRarity rarity;
    switch (rarityStr) {
      case 'rare':
        rarity = MedalRarity.rare;
        break;
      case 'epic':
        rarity = MedalRarity.epic;
        break;
      case 'legendary':
        rarity = MedalRarity.legendary;
        break;
      default:
        rarity = MedalRarity.common;
    }
    
    // 图标映射（简化处理，实际应该从后端返回图标标识）
    final iconName = json['icon'] as String? ?? 'star';
    IconData icon = _getIconFromName(iconName);
    
    DateTime? unlockedAt;
    if (json['unlocked_at'] != null) {
      unlockedAt = DateTime.parse(json['unlocked_at'] as String);
    }
    
    return MedalModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: icon,
      rarity: rarity,
      unlockCondition: json['unlock_condition'] as String? ?? '',
      progress: json['progress'] as int?,
      target: json['target'] as int?,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: unlockedAt,
    );
  }
  
  static IconData _getIconFromName(String name) {
    // 简单的图标映射
    switch (name.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }
}
