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
  });

  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToRegister;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _codeSent = false;
  int _countdown = 0;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
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
      // 这里先模拟发送成功
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _codeSent = true;
        _countdown = 60;
        _isLoading = false;
      });

      // 开始倒计时
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
    final code = _codeController.text.trim();

    if (code.length != 6) {
      setState(() {
        _errorMessage = '请输入6位验证码';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.login(phone, code);
      if (success && mounted) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage = '登录失败，请检查验证码';
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
      backgroundColor: const Color(0xFF050809),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo 或标题
                Text(
                  '亏了么',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: Color(0xFF2BEE6C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '记录每一次亏损，见证每一次成长',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // 手机号输入
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    labelText: '手机号',
                    hintText: '请输入手机号',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF2BEE6C),
                        width: 2,
                      ),
                    ),
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  ),
                  style: const TextStyle(color: Colors.white),
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
                // 验证码输入
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          labelText: '验证码',
                          hintText: '请输入验证码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF2BEE6C),
                              width: 2,
                            ),
                          ),
                          labelStyle: const TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        ),
                        style: const TextStyle(color: Colors.white),
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
                        onPressed: _codeSent && _countdown > 0 ? null : _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _codeSent && _countdown > 0
                              ? Colors.grey.withOpacity(0.2)
                              : const Color(0xFF2BEE6C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _codeSent && _countdown > 0
                              ? '${_countdown}秒'
                              : '发送验证码',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                  ],
                ),
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
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.caption.copyWith(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                // 登录按钮
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BEE6C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Text(
                          '登录',
                          style: AppTextStyles.subtitle,
                        ),
                ),
                const SizedBox(height: 16),
                // 提示信息
                Text(
                  '登录即表示同意《用户协议》和《隐私政策》',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 测试提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BEE6C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2BEE6C).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF2BEE6C), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '测试模式：输入任意手机号，验证码输入 123456 即可登录',
                          style: AppTextStyles.caption.copyWith(
                            color: Color(0xFF2BEE6C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 跳转到注册
                if (widget.onNavigateToRegister != null)
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        children: [
                          const TextSpan(text: '还没有账号？ '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: widget.onNavigateToRegister,
                              child: const Text(
                                '去注册',
                                style: TextStyle(
                                  color: Color(0xFF2BEE6C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
