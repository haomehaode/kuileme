import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/text_styles.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    required this.onRegisterSuccess,
    this.onBack,
    this.onNavigateToLogin,
  });

  final VoidCallback onRegisterSuccess;
  final VoidCallback? onBack;
  final VoidCallback? onNavigateToLogin;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _codeSent = false;
  int _countdown = 0;
  bool _passwordVisible = false;
  bool _agreedToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 11) {
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = '请先同意《亏友互助协议》及《隐私政策》';
      });
      return;
    }

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();

    if (code.length != 6) {
      setState(() {
        _errorMessage = '请输入6位验证码';
      });
      return;
    }

    if (password.length < 8 || password.length > 16) {
      setState(() {
        _errorMessage = '密码长度应为8-16位';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.register(phone, code, password);
      if (success && mounted) {
        widget.onRegisterSuccess();
      } else {
        setState(() {
          _errorMessage = '注册失败，请检查信息';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '注册失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2319),
              Color(0xFF0A0F0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (widget.onBack != null)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: widget.onBack,
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        '注册',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        // Headline Section
                        Text(
                          '加入亏友圈',
                          style: AppTextStyles.headlineLarge.copyWith(
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '记录亏损，找回希望',
                          style: AppTextStyles.subtitleNormal.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Phone Number Field
                        _buildFieldLabel('手机号'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: _buildInputDecoration(
                            hintText: '请输入手机号',
                            prefixIcon: Icons.phone_outlined,
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
                        const SizedBox(height: 16),
                        // Verification Code Field
                        _buildFieldLabel('验证码'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2821),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
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
                                    hintText: '请输入验证码',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 17,
                                    ),
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
                              TextButton(
                                onPressed: _codeSent && _countdown > 0
                                    ? null
                                    : _sendCode,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _codeSent && _countdown > 0
                                      ? '${_countdown}秒'
                                      : '获取验证码',
                                  style: AppTextStyles.bodyBold.copyWith(
                                    color: _codeSent && _countdown > 0
                                        ? Colors.white.withOpacity(0.5)
                                        : const Color(0xFF00E677),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        _buildFieldLabel('设置密码'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2821),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    hintText: '8-16位字母或数字',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 17,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入密码';
                                    }
                                    if (value.length < 8 || value.length > 16) {
                                      return '密码长度应为8-16位';
                                    }
                                    if (!RegExp(r'^[a-zA-Z0-9]+$')
                                        .hasMatch(value)) {
                                      return '密码只能包含字母和数字';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Terms Agreement
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF00E677),
                              checkColor: Colors.black,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    children: [
                                      const TextSpan(text: '我已阅读并同意 '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: 打开协议页面
                                          },
                                          child: const Text(
                                            '《亏友互助协议》',
                                            style: TextStyle(
                                              color: Color(0xFF00E677),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' 及 '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: 打开隐私政策页面
                                          },
                                          child: const Text(
                                            '《隐私政策》',
                                            style: TextStyle(
                                              color: Color(0xFF00E677),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
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
                        const SizedBox(height: 24),
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E677),
                              foregroundColor: const Color(0xFF0A0F0D),
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
                                        Color(0xFF0A0F0D),
                                      ),
                                    ),
                                  )
                                : Text(
                                    '立即注册',
                                    style: AppTextStyles.sectionTitle,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Footer Navigation
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                              children: [
                                const TextSpan(text: '已有账号？ '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: widget.onNavigateToLogin,
                                    child: const Text(
                                      '去登录',
                                      style: TextStyle(
                                        color: Color(0xFF00E677),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.white.withOpacity(0.3))
          : null,
      filled: true,
      fillColor: const Color(0xFF1B2821),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF00E677),
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
    );
  }
}
