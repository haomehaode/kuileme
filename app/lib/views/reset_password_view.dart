import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/text_styles.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    super.key,
    this.onBack,
    this.onNavigateToLogin,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNavigateToLogin;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  bool _isLoading = false;
  bool _codeSent = false;
  int _countdown = 0;
  String? _errorMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      setState(() {
        _errorMessage = '请输入正确的手机号';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 调用发送验证码API
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _codeSent = true;
        _countdown = 60;
        _isLoading = false;
      });

      _startCountdown();
    } catch (e) {
      setState(() {
        _errorMessage = '发送验证码失败: $e';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 验证两次密码是否一致
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.resetPassword(phone, code, newPassword);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('密码重置成功，请使用新密码登录'),
            backgroundColor: Color(0xFF00E677),
          ),
        );
        
        // 延迟后返回登录页面
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && widget.onNavigateToLogin != null) {
            widget.onNavigateToLogin!();
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '重置密码失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2319),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 顶部导航栏
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.onBack != null
                          ? IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: widget.onBack,
                            )
                          : const SizedBox(width: 48),
                      Text(
                        '找回密码',
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 48), // 占位，保持居中
                    ],
                  ),
                ),
                
                // 内容区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // 标题和副标题
                      Text(
                        '重置您的密码',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '验证身份并设置新密码以继续使用"亏了么"',
                        style: AppTextStyles.body.copyWith(
                          color: const Color(0xFF9ABCAB),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 玻璃态卡片
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF273A31).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 账号信息
                            _buildLabel('账号信息'),
                            const SizedBox(height: 8),
                            _buildGlassInput(
                              controller: _phoneController,
                              icon: Icons.phone_outlined,
                              hintText: '请输入注册手机号',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入手机号';
                                }
                                if (value.length != 11) {
                                  return '请输入正确的手机号';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 身份验证
                            _buildLabel('身份验证'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGlassInput(
                                    controller: _codeController,
                                    icon: Icons.verified_user,
                                    hintText: '验证码',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '请输入验证码';
                                      }
                                      if (value.length != 6) {
                                        return '请输入6位验证码';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: (_codeSent && _countdown > 0) || _isLoading
                                        ? null
                                        : _sendCode,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E677).withOpacity(0.1),
                                      foregroundColor: const Color(0xFF00E677),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: const Color(0xFF00E677).withOpacity(0.2),
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _codeSent && _countdown > 0
                                          ? '${_countdown}秒'
                                          : '获取验证码',
                                      style: AppTextStyles.body.copyWith(
                                        color: const Color(0xFF00E677),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 设置新密码
                            _buildLabel('设置新密码'),
                            const SizedBox(height: 8),
                            _buildGlassInput(
                              controller: _newPasswordController,
                              icon: Icons.lock,
                              hintText: '请输入新密码',
                              obscureText: _obscureNewPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword 
                                      ? Icons.visibility 
                                      : Icons.visibility_off,
                                  color: const Color(0xFF9ABCAB),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入新密码';
                                }
                                if (value.length < 6) {
                                  return '密码至少6位';
                                }
                                if (value.length > 72) {
                                  return '密码不能超过72个字符';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 确认新密码
                            _buildLabel('确认新密码'),
                            const SizedBox(height: 8),
                            _buildGlassInput(
                              controller: _confirmPasswordController,
                              icon: Icons.lock_reset,
                              hintText: '请再次输入新密码',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword 
                                      ? Icons.visibility 
                                      : Icons.visibility_off,
                                  color: const Color(0xFF9ABCAB),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请再次输入密码';
                                }
                                if (value != _newPasswordController.text.trim()) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // 错误提示
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, 
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 40),
                      
                      // 确认重置按钮
                      Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E677).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E677),
                            foregroundColor: const Color(0xFF0F2319),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0F2319),
                                    ),
                                  ),
                                )
                              : Text(
                                  '确认重置',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: const Color(0xFF0F2319),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 返回登录链接
                      if (widget.onNavigateToLogin != null)
                        Center(
                          child: TextButton(
                            onPressed: widget.onNavigateToLogin,
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.body.copyWith(
                                  color: const Color(0xFF9ABCAB),
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: '想起密码了？'),
                                  TextSpan(
                                    text: '返回登录',
                                    style: AppTextStyles.body.copyWith(
                                      color: const Color(0xFF00E677),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 40),
                      
                      // 底部指示器
                      Center(
                        child: Container(
                          width: 128,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: const Color(0xFF9ABCAB),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF273A31).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF9ABCAB).withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF9ABCAB), size: 24),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
