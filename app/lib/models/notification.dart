import 'post.dart';

enum NotificationType {
  like, // 点赞
  comment, // 评论
  reply, // 回复
  system, // 系统通知
  follow, // 关注
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String? relatedId; // 关联的帖子/评论ID
  final String time;
  final bool isRead;
  final PostUser? fromUser; // 发送通知的用户（互动类通知）

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.relatedId,
    required this.time,
    this.isRead = false,
    this.fromUser,
  });

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? content,
    String? relatedId,
    String? time,
    bool? isRead,
    PostUser? fromUser,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      relatedId: relatedId ?? this.relatedId,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      fromUser: fromUser ?? this.fromUser,
    );
  }
  
  /// 从 JSON 解析
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'system';
    NotificationType type;
    switch (typeStr) {
      case 'like':
        type = NotificationType.like;
        break;
      case 'comment':
        type = NotificationType.comment;
        break;
      case 'reply':
        type = NotificationType.reply;
        break;
      case 'follow':
        type = NotificationType.follow;
        break;
      default:
        type = NotificationType.system;
    }
    
    final createdAt = json['created_at'] as String? ?? '';
    final time = _formatTime(createdAt);
    
    PostUser? fromUser;
    if (json['from_user'] != null) {
      final avatarUrl = json['from_user']?['avatar'] as String?;
      fromUser = PostUser(
        name: json['from_user']?['nickname'] as String? ?? '用户',
        avatar: (avatarUrl != null && avatarUrl.isNotEmpty) 
            ? avatarUrl 
            : 'https://picsum.photos/100/100?random=${json['from_user']?['id'] ?? 999}',
        level: json['from_user']?['level'] as int? ?? 1,
      );
    }
    
    return NotificationModel(
      id: json['id'].toString(),
      type: type,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      relatedId: json['related_id']?.toString(),
      time: time,
      isRead: json['is_read'] as bool? ?? false,
      fromUser: fromUser,
    );
  }
  
  static String _formatTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '刚刚';
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) return '刚刚';
      if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
      if (difference.inHours < 24) return '${difference.inHours}小时前';
      if (difference.inDays < 7) return '${difference.inDays}天前';
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '刚刚';
    }
  }
}
