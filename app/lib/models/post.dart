class PostUser {
  final String name;
  final String avatar;
  final int level;
  final String? device;

  const PostUser({
    required this.name,
    required this.avatar,
    required this.level,
    this.device,
  });
}

class PostModel {
  final String id;
  final PostUser user;
  final String content;
  final double amount;
  final double percentage;
  final List<String> tags;
  int likes;
  int comments;
  final String time;
  final String? location;
  final String? image;
  final String? mood; // 心理状态
  final bool isAnonymous; // 是否匿名
  bool isLiked; // 当前用户是否已点赞
  bool isHeartbroken; // 当前用户是否已心碎

  PostModel({
    required this.id,
    required this.user,
    required this.content,
    required this.amount,
    required this.percentage,
    required this.tags,
    this.likes = 0,
    this.comments = 0,
    required this.time,
    this.location,
    this.image,
    this.mood,
    this.isAnonymous = false,
    this.isLiked = false,
    this.isHeartbroken = false,
  });

  PostModel copyWith({
    String? id,
    PostUser? user,
    String? content,
    double? amount,
    double? percentage,
    List<String>? tags,
    int? likes,
    int? comments,
    String? time,
    String? location,
    String? image,
    String? mood,
    bool? isAnonymous,
    bool? isLiked,
    bool? isHeartbroken,
  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      time: time ?? this.time,
      location: location ?? this.location,
      image: image ?? this.image,
      mood: mood ?? this.mood,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isLiked: isLiked ?? this.isLiked,
      isHeartbroken: isHeartbroken ?? this.isHeartbroken,
    );
  }
  
  /// 从 JSON 解析（后端 API 返回格式）
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // 后端返回的格式：id, user_id, content, amount, mood, tags, likes, comments_count, created_at
    // 需要转换为前端模型格式
    final tagsStr = json['tags'] as String? ?? '';
    final tagsList = tagsStr.isNotEmpty 
        ? tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    
    // 计算百分比（假设基于 amount，实际可能需要其他逻辑）
    final amount = (json['amount'] as num).toDouble();
    final percentage = amount > 0 ? (amount / 10000 * 100).clamp(0.0, 100.0) : 0.0;
    
    // 格式化时间
    final createdAt = json['created_at'] as String? ?? '';
    final time = _formatTime(createdAt);
    
    // 用户信息（后端可能返回 user 对象，这里简化处理）
    final user = PostUser(
      name: json['user']?['nickname'] as String? ?? '匿名用户',
      avatar: json['user']?['avatar'] as String? ?? '',
      level: json['user']?['level'] as int? ?? 1,
    );
    
    return PostModel(
      id: json['id'].toString(),
      user: user,
      content: json['content'] as String? ?? '',
      amount: amount,
      percentage: percentage,
      tags: tagsList,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments_count'] as int? ?? 0,
      time: time,
      mood: json['mood'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
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

class CommentModel {
  final String id;
  final PostUser user;
  final String content;
  final String time;
  final int likes;
  final String? parentId; // 父评论ID（回复时）
  final String? parentUserName; // 父评论用户名
  bool isLiked; // 当前用户是否已点赞

  CommentModel({
    required this.id,
    required this.user,
    required this.content,
    required this.time,
    this.likes = 0,
    this.parentId,
    this.parentUserName,
    this.isLiked = false,
  });

  CommentModel copyWith({
    String? id,
    PostUser? user,
    String? content,
    String? time,
    int? likes,
    String? parentId,
    String? parentUserName,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      time: time ?? this.time,
      likes: likes ?? this.likes,
      parentId: parentId ?? this.parentId,
      parentUserName: parentUserName ?? this.parentUserName,
      isLiked: isLiked ?? this.isLiked,
    );
  }
  
  /// 从 JSON 解析
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = PostUser(
      name: json['user']?['nickname'] as String? ?? '匿名用户',
      avatar: json['user']?['avatar'] as String? ?? '',
      level: json['user']?['level'] as int? ?? 1,
    );
    
    final createdAt = json['created_at'] as String? ?? '';
    final time = PostModel._formatTime(createdAt);
    
    return CommentModel(
      id: json['id'].toString(),
      user: user,
      content: json['content'] as String? ?? '',
      time: time,
      likes: json['likes'] as int? ?? 0,
      parentId: json['parent_id']?.toString(),
      parentUserName: json['parent']?['user']?['nickname'] as String?,
    );
  }
}

