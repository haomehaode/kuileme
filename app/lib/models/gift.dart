enum GiftType {
  physical, // 实物礼品
  virtual, // 虚拟礼品（优惠券、会员等）
  limited, // 限时特惠
}

class GiftModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired; // 所需积分
  final double recoveryRequired; // 所需回血金
  final GiftType type;
  final int stock; // 库存
  final bool isLimited; // 是否限时

  const GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.recoveryRequired,
    required this.type,
    this.stock = 999,
    this.isLimited = false,
  });
  
  /// 从 JSON 解析
  factory GiftModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'physical';
    GiftType type;
    switch (typeStr) {
      case 'virtual':
        type = GiftType.virtual;
        break;
      case 'limited':
        type = GiftType.limited;
        break;
      default:
        type = GiftType.physical;
    }
    
    return GiftModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      pointsRequired: json['points_required'] as int? ?? 0,
      recoveryRequired: (json['recovery_required'] as num?)?.toDouble() ?? 0.0,
      type: type,
      stock: json['stock'] as int? ?? 999,
      isLimited: json['is_limited'] as bool? ?? false,
    );
  }
}

class ExchangeRecord {
  final String id;
  final String giftId;
  final String giftName;
  final int pointsUsed;
  final double recoveryUsed;
  final DateTime createdAt;
  final String? shippingAddress; // 实物礼品需要
  final String? trackingNumber; // 物流单号
  final String status; // pending, shipped, completed, cancelled

  ExchangeRecord({
    required this.id,
    required this.giftId,
    required this.giftName,
    required this.pointsUsed,
    required this.recoveryUsed,
    required this.createdAt,
    this.shippingAddress,
    this.trackingNumber,
    this.status = 'pending',
  });
  
  /// 从 JSON 解析
  factory ExchangeRecord.fromJson(Map<String, dynamic> json) {
    return ExchangeRecord(
      id: json['id'].toString(),
      giftId: json['gift_id'].toString(),
      giftName: json['gift']?['name'] as String? ?? json['gift_name'] as String? ?? '',
      pointsUsed: json['points_used'] as int? ?? 0,
      recoveryUsed: (json['recovery_used'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      shippingAddress: json['shipping_address'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
