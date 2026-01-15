import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// 认证服务 - 管理用户登录状态和 token
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _phoneKey = 'user_phone';
  
  final ApiService _apiService = ApiService();
  
  /// 注册
  Future<bool> register(String phone, String code, String password) async {
    try {
      final response = await _apiService.register(phone, code, password);
      final token = response['access_token'] as String? ?? 
                    response['token'] as String?;
      
      if (token == null) {
        print('注册响应中未找到 token');
        return false;
      }
      
      // 保存 token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // 保存用户信息
      if (response['user_id'] != null) {
        await prefs.setString(_userIdKey, response['user_id'].toString());
      }
      if (phone.isNotEmpty) {
        await prefs.setString(_phoneKey, phone);
      }
      
      return true;
    } catch (e) {
      print('注册失败: $e');
      return false;
    }
  }
  
  /// 登录
  Future<bool> login(String phone, String code) async {
    try {
      // 测试模式：使用测试验证码 "123456" 或 "000000" 可以直接登录
      if (code == '123456' || code == '000000') {
        // 测试登录：直接生成一个测试 token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'test_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_userIdKey, 'test_user_${phone}');
        await prefs.setString(_phoneKey, phone);
        print('测试登录成功: $phone');
        return true;
      }
      
      final response = await _apiService.login(phone, code);
      final token = response['access_token'] as String? ?? 
                    response['token'] as String?;
      
      if (token == null) {
        print('登录响应中未找到 token');
        return false;
      }
      
      // 保存 token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // 保存用户信息（从 token 解析或从响应获取）
      if (response['user_id'] != null) {
        await prefs.setString(_userIdKey, response['user_id'].toString());
      }
      if (phone.isNotEmpty) {
        await prefs.setString(_phoneKey, phone);
      }
      
      return true;
    } catch (e) {
      print('登录失败: $e');
      // 如果API调用失败，也允许使用测试验证码登录
      if (code == '123456' || code == '000000') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'test_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_userIdKey, 'test_user_${phone}');
        await prefs.setString(_phoneKey, phone);
        print('测试登录成功（API失败但使用测试码）: $phone');
        return true;
      }
      return false;
    }
  }
  
  /// 获取当前 token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);
  }
  
  /// 获取 API 服务实例（带 token）
  Future<ApiService> getApiService() async {
    final token = await getToken();
    return ApiService(token: token);
  }
}
