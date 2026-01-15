import 'package:flutter/material.dart';

enum RecoveryRecordType {
  lotteryWin, // 抽中回血金
  lotteryCost, // 参与投入
  recharge, // 充值
  withdraw, // 提现
  reward, // 奖励（首次发布、连续发布等）
}

class RecoveryRecord {
  final String id;
  final RecoveryRecordType type;
  final double amount;
  final String description;
  final DateTime createdAt;

  RecoveryRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });
  
  /// 从 JSON 解析
  factory RecoveryRecord.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'reward';
    RecoveryRecordType type;
    switch (typeStr) {
      case 'lottery_win':
        type = RecoveryRecordType.lotteryWin;
        break;
      case 'lottery_cost':
        type = RecoveryRecordType.lotteryCost;
        break;
      case 'recharge':
        type = RecoveryRecordType.recharge;
        break;
      case 'withdraw':
        type = RecoveryRecordType.withdraw;
        break;
      default:
        type = RecoveryRecordType.reward;
    }
    
    return RecoveryRecord(
      id: json['id'].toString(),
      type: type,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class LotteryPrize {
  final String id;
  final String name;
  final double amount;
  final double probability; // 概率（0-1）
  final Color color;

  const LotteryPrize({
    required this.id,
    required this.name,
    required this.amount,
    required this.probability,
    required this.color,
  });
  
  /// 从 JSON 解析
  factory LotteryPrize.fromJson(Map<String, dynamic> json) {
    return LotteryPrize(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '谢谢参与',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      color: _getColorForAmount((json['amount'] as num?)?.toDouble() ?? 0.0),
    );
  }
  
  static Color _getColorForAmount(double amount) {
    if (amount >= 100) return Colors.orange;
    if (amount >= 50) return Colors.purple;
    if (amount >= 10) return Colors.blue;
    if (amount > 0) return Colors.green;
    return Colors.grey;
  }
}
