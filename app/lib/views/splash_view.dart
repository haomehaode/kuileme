import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class SplashView extends StatefulWidget {
  const SplashView({
    super.key,
    required this.onAnimationComplete,
  });

  final VoidCallback onAnimationComplete;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 波形动画 - 从左到右绘制
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // 淡入动画
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
      ),
    );

    // 缩放动画
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      // 动画完成后等待一小段时间再回调
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景装饰
          _buildBackground(),
          // 主要内容
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // 波形动画区域
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: _buildWaveform(),
                    ),
                  ),
                  // 品牌区域
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildBrandSection(),
                      ),
                    ),
                  ),
                  // 底部信息
                  Expanded(
                    flex: 1,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFooter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // 顶部渐变
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0DF259).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // 底部渐变
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),
        ),
        // 网格图案
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      width: double.infinity,
      height: 160,
      child: Stack(
        children: [
          // 背景扫描线
          _buildScanLines(),
          // 波形路径
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _WaveformPainter(
                  progress: _waveAnimation.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanLines() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (index) => Container(
            height: 1,
            color: const Color(0xFF0DF259).withOpacity(0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 标题
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFF0DF259),
              ],
            ).createShader(bounds);
          },
          child: Text(
            '亏了么',
            style: AppTextStyles.displayLarge.copyWith(
              letterSpacing: -2,
              shadows: [
                Shadow(
                  color: const Color(0xFF0DF259).withOpacity(0.6),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 副标题
        Text(
          '记录每一次心碎的回响',
          style: AppTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0DF259).withOpacity(0.8),
            letterSpacing: 3.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 18,
              color: const Color(0xFF0DF259).withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              '由亏友社区联合出品',
              style: AppTextStyles.body.copyWith(
                color: const Color(0xFF0DF259).withOpacity(0.6),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// 波形绘制器
class _WaveformPainter extends CustomPainter {
  final double progress;

  _WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0DF259)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 添加发光效果
    final glowPaint = Paint()
      ..color = const Color(0xFF0DF259).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // 定义波形点（从K线到心跳到平线）
    final points = [
      Offset(0, centerY),
      Offset(width * 0.1, centerY),
      Offset(width * 0.125, centerY - height * 0.3),
      Offset(width * 0.1625, centerY + height * 0.3),
      Offset(width * 0.1875, centerY - height * 0.1),
      Offset(width * 0.225, centerY + height * 0.1),
      Offset(width * 0.275, centerY - height * 0.4),
      Offset(width * 0.3125, centerY + height * 0.4),
      Offset(width * 0.35, centerY),
      Offset(width * 0.45, centerY),
      Offset(width * 0.475, centerY - height * 0.4),
      Offset(width * 0.5125, centerY + height * 0.4),
      Offset(width * 0.5375, centerY),
      Offset(width * 0.625, centerY),
      Offset(width * 0.75, centerY),
      Offset(width, centerY),
    ];

    // 计算当前应该绘制的点
    final currentProgress = progress;
    final totalLength = points.length - 1;
    final currentIndex = (currentProgress * totalLength).floor();
    final segmentProgress = (currentProgress * totalLength) - currentIndex;

    path.moveTo(points[0].dx, points[0].dy);

    // 绘制已完成的段
    for (int i = 0; i < currentIndex && i < points.length - 1; i++) {
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
    }

    // 绘制当前正在绘制的段
    if (currentIndex < points.length - 1) {
      final start = points[currentIndex];
      final end = points[currentIndex + 1];
      final current = Offset(
        start.dx + (end.dx - start.dx) * segmentProgress,
        start.dy + (end.dy - start.dy) * segmentProgress,
      );
      path.lineTo(current.dx, current.dy);
    }

    // 绘制发光效果
    canvas.drawPath(path, glowPaint);
    // 绘制主路径
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// 网格绘制器
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0DF259).withOpacity(0.03)
      ..strokeWidth = 1;

    const gridSize = 40.0;

    // 绘制垂直线
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
