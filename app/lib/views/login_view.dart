import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/text_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
    required this.onLoginSuccess,
    this.onBack,
    this.onNavigateToRegister,
    this.onNavigateToResetPassword,
  });

  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToResetPassword;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _codeSent = false;
  int _countdown = 0;
  String? _errorMessage;
  bool _isPasswordLogin = true; // 默认使用密码登录
  bool _obscurePassword = true; // 密码是否隐藏

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success;
      if (_isPasswordLogin) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          setState(() {
            _errorMessage = '请输入密码';
            _isLoading = false;
          });
          return;
        }
        success = await _authService.loginWithPassword(phone, password);
      } else {
        final code = _codeController.text.trim();
        if (code.length != 6) {
          setState(() {
            _errorMessage = '请输入6位验证码';
            _isLoading = false;
          });
          return;
        }
        success = await _authService.login(phone, code);
      }
      
      if (success && mounted) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = _isPasswordLogin 
              ? '登录失败，请检查账号和密码' 
              : '登录失败，请检查验证码';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: $e';
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
                // 顶部关闭按钮
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.onBack != null
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Color(0xFF9ABCAB)),
                              onPressed: widget.onBack,
                            )
                          : const SizedBox(width: 48),
                      const SizedBox(width: 48), // 占位，保持居中
                    ],
                  ),
                ),
                
                // Logo 区域（带动画效果）
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 脉冲动画背景
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Container(
                            width: 96 + (value * 20),
                            height: 96 + (value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF00E677).withOpacity(0.2 * (1 - value)),
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                      // 图标
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00E677).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.trending_down,
                          color: Color(0xFF00E677),
                          size: 64,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 标题和副标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        '欢迎回到亏友圈',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '在这里，你从不是一个人在战斗',
                        style: AppTextStyles.body.copyWith(
                          color: const Color(0xFF9ABCAB),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 登录方式切换标签
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordLogin = true;
                              _errorMessage = null;
                              _codeController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isPasswordLogin 
                                      ? const Color(0xFF00E677) 
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '密码登录',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: _isPasswordLogin 
                                    ? const Color(0xFF00E677) 
                                    : const Color(0xFF9ABCAB),
                                fontWeight: _isPasswordLogin 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordLogin = false;
                              _errorMessage = null;
                              _codeController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !_isPasswordLogin 
                                      ? const Color(0xFF00E677) 
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              '验证码登录',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: !_isPasswordLogin 
                                    ? const Color(0xFF00E677) 
                                    : const Color(0xFF9ABCAB),
                                fontWeight: !_isPasswordLogin 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 输入框区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // 手机号输入
                      _buildGlassInput(
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        hintText: '请输入手机号',
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
                      
                      const SizedBox(height: 16),
                      
                      // 密码或验证码输入
                      if (_isPasswordLogin) ...[
                        _buildGlassInput(
                          controller: _passwordController,
                          icon: Icons.lock,
                          hintText: '请输入您的密码',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                              color: const Color(0xFF9ABCAB),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码至少6位';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onNavigateToResetPassword,
                            child: Text(
                              '忘记密码？',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF9ABCAB),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildGlassInput(
                                controller: _codeController,
                                icon: Icons.lock,
                                hintText: '请输入验证码',
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
                                  backgroundColor: const Color(0xFF00E677),
                                  foregroundColor: const Color(0xFF0F2319),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _codeSent && _countdown > 0
                                      ? '${_countdown}秒'
                                      : '发送验证码',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
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
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 登录按钮（带发光效果）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E677).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E677),
                        foregroundColor: const Color(0xFF0F2319),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              '立即登录',
                              style: AppTextStyles.subtitle.copyWith(
                                color: const Color(0xFF0F2319),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 注册链接
                if (widget.onNavigateToRegister != null)
                  TextButton(
                    onPressed: widget.onNavigateToRegister,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: const Color(0xFF9ABCAB),
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: '还没有账号？'),
                          TextSpan(
                            text: '立即注册',
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
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
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
          hintStyle: const TextStyle(
            color: Color(0xFF9ABCAB),
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
