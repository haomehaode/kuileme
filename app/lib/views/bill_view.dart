import 'dart:math';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class BillView extends StatelessWidget {
  const BillView({
    super.key,
    required this.posts,
    this.isLoggedIn = false,
    this.onLoginRequest,
  });

  final List<PostModel> posts;
  final bool isLoggedIn;
  final VoidCallback? onLoginRequest;

  // 计算累计总亏损
  double get _totalLoss {
    return posts.fold(0.0, (sum, post) => sum + post.amount.abs());
  }

  // 计算本月新增亏损（简化：假设所有帖子都是本月的）
  double get _monthlyLoss {
    return posts.fold(0.0, (sum, post) => sum + post.amount.abs());
  }

  // 计算分布数据
  Map<String, double> get _distribution {
    // 简化：根据标签或内容分类
    double aStock = 0;
    double usStock = 0;
    double crypto = 0;
    double fund = 0;

    for (final post in posts) {
      final content = post.content.toLowerCase();
      final tags = post.tags.map((t) => t.toLowerCase()).toList();
      
      if (tags.contains('a股') || tags.contains('股票') || content.contains('600') || content.contains('000')) {
        aStock += post.amount.abs();
      } else if (tags.contains('美股') || tags.contains('nasdaq') || tags.contains('sp500')) {
        usStock += post.amount.abs();
      } else if (tags.contains('币圈') || tags.contains('crypto') || tags.contains('btc') || tags.contains('eth')) {
        crypto += post.amount.abs();
      } else {
        fund += post.amount.abs();
      }
    }

    final total = aStock + usStock + crypto + fund;
    if (total == 0) {
      // 默认分布
      return {
        'aStock': 0.45,
        'usStock': 0.30,
        'crypto': 0.20,
        'fund': 0.05,
      };
    }

    return {
      'aStock': aStock / total,
      'usStock': usStock / total,
      'crypto': crypto / total,
      'fund': fund / total,
    };
  }

  // 获取账单列表（按损失额倒序）
  List<PostModel> get _sortedPosts {
    final sorted = List<PostModel>.from(posts);
    sorted.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    return sorted;
  }

  // 获取心碎指数（基于亏损金额）
  int _getHeartBreakLevel(double amount) {
    final absAmount = amount.abs();
    if (absAmount >= 10000) return 5;
    if (absAmount >= 5000) return 4;
    if (absAmount >= 2000) return 3;
    if (absAmount >= 1000) return 2;
    return 1;
  }

  // 获取图标和颜色
  Map<String, dynamic> _getItemStyle(PostModel post) {
    final content = post.content.toLowerCase();
    final tags = post.tags.map((t) => t.toLowerCase()).toList();
    
    if (tags.contains('a股') || tags.contains('股票') || content.contains('600') || content.contains('000')) {
      return {
        'icon': Icons.trending_down,
        'color': const Color(0xFF2BEE6C),
      };
    } else if (tags.contains('币圈') || tags.contains('crypto') || tags.contains('btc') || tags.contains('eth')) {
      return {
        'icon': Icons.currency_bitcoin,
        'color': Colors.orange,
      };
    } else if (tags.contains('基金') || tags.contains('fund')) {
      return {
        'icon': Icons.show_chart,
        'color': Colors.blue,
      };
    } else {
      return {
        'icon': Icons.close,
        'color': Colors.grey,
      };
    }
  }

  // 格式化时间（从PostModel的time字符串解析）
  String _formatTime(String timeStr) {
    // PostModel的time已经是格式化后的字符串，直接返回
    // 如果需要更详细的格式，可以解析time字符串
    if (timeStr == '刚刚' || timeStr == 'Just now') {
      return 'Just now';
    }
    // 尝试解析包含时间的字符串
    if (timeStr.contains('Yesterday')) {
      return timeStr;
    }
    if (timeStr.contains('Today')) {
      return timeStr;
    }
    // 其他情况直接返回
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    // 如果未登录，显示登录提示
    if (!isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    final dist = _distribution;
    final sortedPosts = _sortedPosts.take(10).toList(); // 只显示前10条

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTotalLossSection(),
          const SizedBox(height: 32),
          _buildDistributionChart(dist),
          const SizedBox(height: 32),
          _buildBillListHeader(),
          const SizedBox(height: 12),
          _buildBillList(sortedPosts),
          const SizedBox(height: 100), // 为底部导航栏留空间
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF2BEE6C).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2BEE6C).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 60,
              color: Color(0xFF2BEE6C),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '查看账单需要登录',
            style: AppTextStyles.pageTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '登录后可以查看您的完整亏损账单\n包括累计亏损、分布图表和详细记录',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onLoginRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BEE6C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              '立即登录',
              style: AppTextStyles.subtitle,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onLoginRequest,
            child: Text(
              '使用手机号登录',
              style: AppTextStyles.body.copyWith(
                color: Color(0xFF2BEE6C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '扎心亏损总账单',
          style: AppTextStyles.cardTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLossSection() {
    return Column(
      children: [
        Text(
          '累计总亏损 (CNY)',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '-${_formatCurrency(_totalLoss)}',
          style: AppTextStyles.displayNumber.copyWith(
            color: Color(0xFF2BEE6C),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '本月新增: ¥${_formatCurrency(_monthlyLoss)} ↑',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '对比上月 +12.5%',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistributionChart(Map<String, double> dist) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
              child: CustomPaint(
              painter: _DonutChartPainter(dist),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DISTRIBUTION',
                      style: AppTextStyles.label.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '全线飘绿',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDistributionLegend(dist),
        ],
      ),
    );
  }

  Widget _buildDistributionLegend(Map<String, double> dist) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('A股', (dist['aStock']! * 100).toStringAsFixed(0), 1.0),
            const SizedBox(width: 32),
            _buildLegendItem('美股', (dist['usStock']! * 100).toStringAsFixed(0), 0.7),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('币圈', (dist['crypto']! * 100).toStringAsFixed(0), 0.4),
            const SizedBox(width: 32),
            _buildLegendItem('基金', (dist['fund']! * 100).toStringAsFixed(0), 0.2),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String percent, double opacity) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF2BEE6C).withOpacity(opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($percent%)',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBillListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '扎心账单单条',
          style: AppTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '按损失额倒序',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBillList(List<PostModel> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '暂无账单记录',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: posts.map((post) {
        final style = _getItemStyle(post);
        final heartBreakLevel = _getHeartBreakLevel(post.amount);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (style['color'] as Color).withOpacity(0.1),
                  border: Border.all(
                    color: (style['color'] as Color).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  style['icon'] as IconData,
                  color: style['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.content.length > 20 
                          ? '${post.content.substring(0, 20)}...' 
                          : post.content,
                      style: AppTextStyles.bodyBold,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '心碎指数',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ...List.generate(5, (i) {
                          return Icon(
                            Icons.favorite,
                            size: 12,
                            color: i < heartBreakLevel
                                ? const Color(0xFF2BEE6C)
                                : Colors.grey.withOpacity(0.3),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${_formatCurrency(post.amount.abs())}',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Color(0xFF2BEE6C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(post.time),
                    style: AppTextStyles.label.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    }
    return amount.toStringAsFixed(2);
  }
}

// 环形图绘制器
class _DonutChartPainter extends CustomPainter {
  final Map<String, double> distribution;

  _DonutChartPainter(this.distribution);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 70.0;
    final strokeWidth = 14.0;

    // 背景圆
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 计算各部分的起始角度和扫过角度
    double startAngle = -pi / 2; // 从顶部开始

    final colors = [
      const Color(0xFF2BEE6C),
      const Color(0xFF2BEE6C).withOpacity(0.7),
      const Color(0xFF2BEE6C).withOpacity(0.4),
      const Color(0xFF2BEE6C).withOpacity(0.2),
    ];

    final values = [
      distribution['aStock']!,
      distribution['usStock']!,
      distribution['crypto']!,
      distribution['fund']!,
    ];

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * pi * values[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
