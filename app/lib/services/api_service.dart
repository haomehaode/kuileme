import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/post.dart';
import '../models/notification.dart';
import '../models/recovery.dart';
import '../models/gift.dart';
import '../models/medal.dart';

/// API 基础配置
class ApiConfig {
  // 手动配置服务器地址（用于物理设备测试）
  // 如果设置了此值，将优先使用此地址
  // 例如：'http://192.168.1.100:8000'
  static String? _customBaseUrl;
  
  /// 设置自定义服务器地址（用于物理设备测试）
  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url;
  }
  
  // 根据运行平台自动选择正确的 server 地址
  // iOS 模拟器/Web: localhost
  // iOS 物理设备: 需要使用电脑的实际 IP 地址（通过 setCustomBaseUrl 设置）
  // Android 模拟器: 10.0.2.2 (Android 模拟器的特殊 IP，指向宿主机的 localhost)
  // Android 物理设备: 需要使用电脑的实际 IP 地址（通过 setCustomBaseUrl 设置）
  static String get baseUrl {
    // 如果设置了自定义地址，优先使用
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    
    if (kIsWeb) {
      // Web 平台
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // Android 平台（模拟器使用 10.0.2.2，物理设备需要配置实际 IP）
      // 物理设备运行时，请使用 setCustomBaseUrl('http://你的电脑IP:8000')
      return 'http://10.0.2.2:8000'; // Android 模拟器
    } else if (Platform.isIOS) {
      // iOS 平台
      // 模拟器可以使用 localhost
      // 物理设备需要使用电脑的实际 IP 地址，请使用 setCustomBaseUrl('http://你的电脑IP:8000')
      return 'http://localhost:8000'; // iOS 模拟器
    } else {
      // 其他平台
      return 'http://localhost:8000';
    }
  }
  
  static Map<String, String> getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

/// API 服务类 - 统一处理所有后端接口调用
class ApiService {
  final String? token;
  
  ApiService({this.token});
  
  // ==================== 认证相关 ====================
  
  /// 注册
  Future<Map<String, dynamic>> register(
    String phone,
    String code,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('注册失败: ${response.body}');
    }
  }
  
  /// 登录（验证码方式）
  Future<Map<String, dynamic>> login(String phone, String code) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({
        'phone': phone,
        'code': code,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('登录失败: ${response.body}');
    }
  }
  
  /// 登录（账号密码方式）
  Future<Map<String, dynamic>> loginWithPassword(String phone, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/password'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('登录失败: ${response.body}');
    }
  }
  
  /// 重置密码
  Future<Map<String, dynamic>> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: ApiConfig.getHeaders(null),
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'new_password': newPassword,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('重置密码失败: ${response.body}');
    }
  }
  
  // ==================== 用户相关 ====================
  
  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('获取用户信息失败: ${response.body}');
    }
  }
  
  // ==================== 帖子相关 ====================
  
  /// 获取帖子列表
  Future<List<PostModel>> getPosts({
    String? tag,
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    if (tag != null) {
      queryParams['tag'] = tag;
    }
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/posts/').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('获取帖子列表失败: ${response.body}');
    }
  }
  
  /// 创建帖子
  Future<PostModel> createPost({
    required String content,
    required double amount,
    required String mood,
    required List<String> tags,
    bool isAnonymous = false,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({
        'content': content,
        'amount': amount,
        'mood': mood,
        'tags': tags,  // 直接发送列表
        'is_anonymous': isAnonymous,
      }),
    );
    
    if (response.statusCode == 201) {
      return PostModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('创建帖子失败: ${response.body}');
    }
  }
  
  /// 获取帖子详情
  Future<PostModel> getPostDetail(int postId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return PostModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('获取帖子详情失败: ${response.body}');
    }
  }
  
  // ==================== 评论相关 ====================
  
  /// 获取评论列表
  Future<List<CommentModel>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/comments/?post_id=$postId'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('获取评论列表失败: ${response.body}');
    }
  }
  
  /// 创建评论
  Future<CommentModel> createComment({
    required int postId,
    required String content,
    int? parentId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/comments/'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({
        'post_id': postId,
        'content': content,
        if (parentId != null) 'parent_id': parentId,
      }),
    );
    
    if (response.statusCode == 201) {
      return CommentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('创建评论失败: ${response.body}');
    }
  }
  
  // ==================== 互动相关 ====================
  
  /// 点赞/心碎
  Future<Map<String, dynamic>> toggleInteraction({
    required int postId,
    required String action, // 'like' 或 'heart'
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/interactions/toggle?post_id=$postId&action=$action'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('操作失败: ${response.body}');
    }
  }
  
  // ==================== 通知相关 ====================
  
  /// 获取通知列表
  Future<List<NotificationModel>> getNotifications() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications/'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('获取通知列表失败: ${response.body}');
    }
  }
  
  /// 标记通知已读
  Future<void> markNotificationRead(int notificationId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode != 200) {
      throw Exception('标记已读失败: ${response.body}');
    }
  }
  
  /// 全部标记已读
  Future<void> markAllNotificationsRead() async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode != 200) {
      throw Exception('全部标记已读失败: ${response.body}');
    }
  }
  
  // ==================== 回血系统相关 ====================
  
  /// 获取回血余额
  Future<double> getRecoveryBalance() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/recovery/balance'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['recovery_balance'] as num).toDouble();
    } else {
      throw Exception('获取余额失败: ${response.body}');
    }
  }
  
  /// 抽奖
  Future<LotteryPrize> drawLottery() async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/recovery/lottery/draw'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LotteryPrize.fromJson(data);
    } else {
      throw Exception('抽奖失败: ${response.body}');
    }
  }
  
  /// 获取回血记录
  Future<List<RecoveryRecord>> getRecoveryRecords() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/recovery/records'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RecoveryRecord.fromJson(json)).toList();
    } else {
      throw Exception('获取回血记录失败: ${response.body}');
    }
  }
  
  // ==================== 礼品中心相关 ====================
  
  /// 获取礼品列表
  Future<List<GiftModel>> getGifts({String? type}) async {
    final queryParams = <String, String>{};
    if (type != null) {
      queryParams['type'] = type;
    }
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/gifts').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GiftModel.fromJson(json)).toList();
    } else {
      throw Exception('获取礼品列表失败: ${response.body}');
    }
  }
  
  /// 兑换礼品
  Future<ExchangeRecord> exchangeGift({
    required int giftId,
    required String address,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/gifts/$giftId/exchange'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({
        'address': address,
        if (phone != null) 'phone': phone,
      }),
    );
    
    if (response.statusCode == 200) {
      return ExchangeRecord.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('兑换失败: ${response.body}');
    }
  }
  
  /// 获取兑换记录
  Future<List<ExchangeRecord>> getExchangeRecords() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/gifts/exchange-records'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ExchangeRecord.fromJson(json)).toList();
    } else {
      throw Exception('获取兑换记录失败: ${response.body}');
    }
  }
  
  // ==================== 成长系统相关 ====================
  
  /// 获取成长汇总
  Future<Map<String, dynamic>> getGrowthSummary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/growth/summary'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('获取成长汇总失败: ${response.body}');
    }
  }
  
  // ==================== 勋章相关 ====================
  
  /// 获取勋章列表
  Future<List<MedalModel>> getMedals({String? rarity}) async {
    final queryParams = <String, String>{};
    if (rarity != null) {
      queryParams['rarity'] = rarity;
    }
    
    final uri = Uri.parse('${ApiConfig.baseUrl}/medals').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedalModel.fromJson(json)).toList();
    } else {
      throw Exception('获取勋章列表失败: ${response.body}');
    }
  }
  
  // ==================== 复盘分析相关 ====================
  
  /// 获取复盘汇总
  Future<Map<String, dynamic>> getReviewSummary({String period = 'month'}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/review/summary?period=$period'),
      headers: ApiConfig.getHeaders(token),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('获取复盘汇总失败: ${response.body}');
    }
  }
  
  /// 保存留言
  Future<void> saveReviewMessage(String message) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/review/message'),
      headers: ApiConfig.getHeaders(token),
      body: jsonEncode({
        'message': message,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('保存留言失败: ${response.body}');
    }
  }
}
