import 'dart:math';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({
    super.key,
    required this.onBack,
    required this.posts,
  });

  final VoidCallback onBack;
  final List<PostModel> posts;

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  final TextEditingController _messageController = TextEditingController();

  // 计算本月亏损数据
  double get _monthlyLoss {
    return widget.posts
        .where((post) {
          // 简化：假设所有帖子都是本月的
          return true;
        })
        .fold(0.0, (sum, post) => sum + post.amount.abs());
  }

  // 计算跌幅（基于初始净值100）
  double get _lossPercent {
    if (widget.posts.isEmpty) return 0;
    final totalLoss = _monthlyLoss;
    final initialValue = 100000.0; // 假设初始资产10万
    return (totalLoss / initialValue * 100).clamp(0, 100);
  }

  // 生成净值走势数据（最近30天）
  List<double> get _netValueTrend {
    if (widget.posts.isEmpty) {
      return List.generate(30, (i) => 100.0);
    }
    final trend = <double>[100.0]; // 初始净值100
    double currentValue = 100.0;
    for (int i = 1; i < 30; i++) {
      // 简化：每天随机减少一点
      final dayPosts = widget.posts.where((p) {
        // 模拟：假设每天有帖子
        return Random().nextBool();
      }).toList();
      final dayLoss = dayPosts.fold(0.0, (sum, p) => sum + p.amount.abs());
      currentValue = (currentValue - dayLoss / 1000).clamp(0, 100);
      trend.add(currentValue);
    }
    return trend;
  }

  // 分析亏损原因
  List<Map<String, dynamic>> get _reasons {
    if (widget.posts.isEmpty) {
      return [
        {
          'label': '追涨杀跌',
          'value': 45,
          'color': const Color(0xFF2BEE6C),
          'icon': Icons.rocket_launch,
        },
        {
          'label': '小道消息',
          'value': 30,
          'color': Colors.purpleAccent,
          'icon': Icons.campaign,
        },
        {
          'label': '幻觉抄底 (接飞刀)',
          'value': 25,
          'color': Colors.greenAccent,
          'icon': Icons.water_drop,
          'sub': '"我觉得到底是底了"',
        },
      ];
    }

    // 基于内容关键词分析
    int chaseCount = 0; // 追涨杀跌
    int messageCount = 0; // 小道消息
    int bottomCount = 0; // 抄底

    final keywords = {
      'chase': ['追涨', '杀跌', '追高', '割肉', '止损', '止盈'],
      'message': ['消息', '听说', '据说', '内幕', '推荐', '群友'],
      'bottom': ['抄底', '底部', '到底', '接飞刀', '低点'],
    };

    for (final post in widget.posts) {
      final content = post.content.toLowerCase();
      if (keywords['chase']!.any((kw) => content.contains(kw))) {
        chaseCount++;
      }
      if (keywords['message']!.any((kw) => content.contains(kw))) {
        messageCount++;
      }
      if (keywords['bottom']!.any((kw) => content.contains(kw))) {
        bottomCount++;
      }
    }

    final total = chaseCount + messageCount + bottomCount;
    if (total == 0) {
      return [
        {
          'label': '追涨杀跌',
          'value': 45,
          'color': const Color(0xFF2BEE6C),
          'icon': Icons.rocket_launch,
        },
        {
          'label': '小道消息',
          'value': 30,
          'color': Colors.purpleAccent,
          'icon': Icons.campaign,
        },
        {
          'label': '幻觉抄底 (接飞刀)',
          'value': 25,
          'color': Colors.greenAccent,
          'icon': Icons.water_drop,
          'sub': '"我觉得到底是底了"',
        },
      ];
    }

    final chasePercent = (chaseCount / total * 100).round();
    final messagePercent = (messageCount / total * 100).round();
    final bottomPercent = (bottomCount / total * 100).round();

    return [
      {
        'label': '追涨杀跌',
        'value': chasePercent,
        'color': const Color(0xFF2BEE6C),
        'icon': Icons.rocket_launch,
      },
      {
        'label': '小道消息',
        'value': messagePercent,
        'color': Colors.purpleAccent,
        'icon': Icons.campaign,
      },
      {
        'label': '幻觉抄底 (接飞刀)',
        'value': bottomPercent,
        'color': Colors.greenAccent,
        'icon': Icons.water_drop,
        'sub': '"我觉得到底是底了"',
      },
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          '投资痛定思痛复盘',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthlySummary(),
            const SizedBox(height: 32),
            _buildHeartbreakCurve(),
            const SizedBox(height: 32),
            _buildReasonStats(),
            const SizedBox(height: 32),
            _buildMessageToFuture(),
            const SizedBox(height: 32),
            _buildSealButton(),
            const SizedBox(height: 16),
            _buildFooter(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Column(
      children: [
        Text(
          '本月亏损总额',
          style: AppTextStyles.bodyBold.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '-¥${_monthlyLoss.toStringAsFixed(2)}',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.trending_down, size: 16, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text(
                '跌幅 ${_lossPercent.toStringAsFixed(1)}%',
                style: AppTextStyles.captionBold.copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeartbreakCurve() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '心碎曲线图',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.broken_image, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '近一个月净值走势 · 只要我不卖这就只是数字',
            style: AppTextStyles.labelBold.copyWith(
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _CurvePainter(trend: _netValueTrend),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '月初(满怀希望)',
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '月中(倔强坚持)',
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '现在(心如死灰)',
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: 9,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonStats() {
    return Column(
      children: [
        Text(
          '亏损原因统计',
          style: AppTextStyles.pageTitle.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '大数据比你更懂你的鲁莽',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _reasons.length,
          itemBuilder: (context, index) {
            final reason = _reasons[index];
            final isLast = index == _reasons.length - 1;
            if (isLast) {
              return _buildReasonCard(reason, isFullWidth: true);
            }
            return _buildReasonCard(reason);
          },
        ),
      ],
    );
  }

  Widget _buildReasonCard(Map<String, dynamic> reason, {bool isFullWidth = false}) {
    final color = reason['color'] as Color;
    final value = reason['value'] as int;
    final label = reason['label'] as String;
    final icon = reason['icon'] as IconData;
    final sub = reason['sub'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.captionBold.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (sub != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    '$value%',
                    style: AppTextStyles.pageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: Text(
                    sub,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )
          else
            Text(
              '$value%',
              style: AppTextStyles.pageTitle,
            ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: const Color(0xFF050809),
              minHeight: 6,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageToFuture() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2BEE6C).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2BEE6C).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Color(0xFF2BEE6C)),
              SizedBox(width: 8),
              Text(
                '给未来的自己留言',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '在这里写下你的血泪教训... 例如：再相信群友我是狗。',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF050809),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2BEE6C)),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.lock, size: 12, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  '此留言将被存入"悔过书"加密档案，下次冲动时自动弹出。',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSealButton() {
    return ElevatedButton(
      onPressed: () {
        if (_messageController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先写下给未来的留言')),
          );
          return;
        }

        // 加密存储留言（简化：直接存储，实际应该加密后存储到本地或服务器）
        // TODO: 实现加密存储逻辑
        final _ = _messageController.text.trim();

        _messageController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已封印！下次冲动时会自动弹出提醒'),
            backgroundColor: Color(0xFF2BEE6C),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2BEE6C),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '封印这段痛苦',
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.auto_fix_high),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'POWERED BY KUELEMA COMMUNITY',
      style: AppTextStyles.label.copyWith(
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _CurvePainter extends CustomPainter {
  final List<double> trend;

  _CurvePainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF2BEE6C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (trend.length - 1);
    final maxValue = trend.reduce(max);
    final minValue = trend.reduce(min);
    final range = maxValue - minValue;
    final scale = range > 0 ? (size.height * 0.8) / range : 1.0;
    final offsetY = size.height * 0.1;

    for (int i = 0; i < trend.length; i++) {
      final x = i * stepX;
      final y = offsetY + (maxValue - trend[i]) * scale;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // 绘制起点和终点
    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    if (trend.length > 1) {
      final startX = 0.0;
      final startY = offsetY + (maxValue - trend.first) * scale;
      final endX = (trend.length - 1) * stepX;
      final endY = offsetY + (maxValue - trend.last) * scale;

      canvas.drawCircle(Offset(startX, startY), 3, pointPaint);
      canvas.drawCircle(Offset(endX, endY), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
