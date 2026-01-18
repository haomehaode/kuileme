import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

enum TimeFilter { week, month, year, custom }

class BillView extends StatefulWidget {
  const BillView({
    super.key,
    required this.posts,
    this.isLoggedIn = false,
    this.onLoginRequest,
  });

  final List<PostModel> posts;
  final bool isLoggedIn;
  final VoidCallback? onLoginRequest;

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  TimeFilter _selectedFilter = TimeFilter.month;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // 根据时间筛选获取帖子列表
  List<PostModel> get _filteredPosts {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedFilter) {
      case TimeFilter.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case TimeFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimeFilter.year:
        startDate = DateTime(now.year, 1, 1);
        break;
      case TimeFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return widget.posts.where((post) {
            final postDate = _parsePostDate(post.time);
            return postDate != null &&
                postDate.isAfter(_customStartDate!.subtract(const Duration(days: 1))) &&
                postDate.isBefore(_customEndDate!.add(const Duration(days: 1)));
          }).toList();
        }
        return widget.posts;
    }

    return widget.posts.where((post) {
      final postDate = _parsePostDate(post.time);
      return postDate != null && postDate.isAfter(startDate);
    }).toList();
  }

  // 解析帖子时间字符串为DateTime
  DateTime? _parsePostDate(String timeStr) {
    // 处理相对时间
    if (timeStr.contains('刚刚') || timeStr.contains('Just now')) {
      return DateTime.now();
    }
    if (timeStr.contains('Today') || timeStr.contains('今天')) {
      return DateTime.now();
    }
    if (timeStr.contains('Yesterday') || timeStr.contains('昨天')) {
      return DateTime.now().subtract(const Duration(days: 1));
    }
    
    // 尝试解析绝对时间（如果有的话）
    // 这里简化处理，实际应该从PostModel获取真实的创建时间
    return DateTime.now();
  }

  // 计算当前周期亏损汇总
  double get _currentPeriodLoss {
    return _filteredPosts.fold(0.0, (sum, post) => sum + post.amount.abs());
  }

  // 计算新增痛点次数
  int get _newPainPoints {
    return _filteredPosts.length;
  }

  // 计算对比同期增长率（简化：假设对比上个月）
  double get _growthRate {
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    
    final lastMonthPosts = widget.posts.where((post) {
      final postDate = _parsePostDate(post.time);
      return postDate != null &&
          postDate.isAfter(lastMonthStart) &&
          postDate.isBefore(lastMonthEnd.add(const Duration(days: 1)));
    }).toList();
    
    final lastMonthLoss = lastMonthPosts.fold(0.0, (sum, post) => sum + post.amount.abs());
    
    if (lastMonthLoss == 0) return 0;
    return ((_currentPeriodLoss - lastMonthLoss) / lastMonthLoss * 100);
  }

  // 计算分布数据
  Map<String, double> get _distribution {
    double aStock = 0;
    double usStock = 0;
    double crypto = 0;
    double fund = 0;

    for (final post in _filteredPosts) {
      final content = post.content.toLowerCase();
      final tags = post.tags.map((t) => t.toLowerCase()).toList();
      
      if (tags.contains('a股') || tags.contains('股票') || 
          content.contains('600') || content.contains('000') ||
          content.contains('sh') || content.contains('sz')) {
        aStock += post.amount.abs();
      } else if (tags.contains('美股') || tags.contains('nasdaq') || 
                 tags.contains('sp500') || tags.contains('nyse')) {
        usStock += post.amount.abs();
      } else if (tags.contains('币圈') || tags.contains('crypto') || 
                 tags.contains('btc') || tags.contains('eth') ||
                 tags.contains('比特币') || tags.contains('以太坊')) {
        crypto += post.amount.abs();
      } else {
        fund += post.amount.abs();
      }
    }

    final total = aStock + usStock + crypto + fund;
    if (total == 0) {
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
    final sorted = List<PostModel>.from(_filteredPosts);
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
    
    if (tags.contains('a股') || tags.contains('股票') || 
        content.contains('600') || content.contains('000') ||
        content.contains('sh') || content.contains('sz')) {
      return {
        'icon': Icons.trending_down,
        'color': const Color(0xFF00E677),
      };
    } else if (tags.contains('币圈') || tags.contains('crypto') || 
               tags.contains('btc') || tags.contains('eth') ||
               tags.contains('比特币') || tags.contains('以太坊')) {
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
        'icon': Icons.trending_down,
        'color': const Color(0xFF00E677),
      };
    }
  }

  // 格式化时间显示
  String _formatTime(String timeStr) {
    if (timeStr.contains('Today') || timeStr.contains('今天')) {
      return 'Today';
    }
    if (timeStr.contains('Yesterday') || timeStr.contains('昨天')) {
      return 'Yesterday';
    }
    if (timeStr.contains('刚刚') || timeStr.contains('Just now')) {
      return 'Just now';
    }
    return timeStr;
  }

  // 格式化货币
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }

  // 分享账单
  Future<void> _shareBill() async {
    final dist = _distribution;
    final shareText = '''
扎心亏损总账单

当前周期亏损汇总: -${_formatCurrency(_currentPeriodLoss)} CNY
新增痛点: $_newPainPoints次

分布情况:
A股: ${(dist['aStock']! * 100).toStringAsFixed(0)}%
美股: ${(dist['usStock']! * 100).toStringAsFixed(0)}%
币圈: ${(dist['crypto']! * 100).toStringAsFixed(0)}%
基金: ${(dist['fund']! * 100).toStringAsFixed(0)}%

来自"亏了么"App
''';
    
    try {
      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('账单已复制到剪贴板，可以分享给好友了！'),
            backgroundColor: Color(0xFF00E677),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // 如果未登录，显示登录提示
    if (!widget.isLoggedIn) {
      return _buildLoginPrompt(context);
    }

    final dist = _distribution;
    final sortedPosts = _sortedPosts.take(20).toList(); // 显示前20条

    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: Column(
          children: [
            // 头部
            Builder(
              builder: (context) => _buildHeader(context),
            ),
            
            // 时间筛选器
            _buildTimeFilters(),
            
            // 主内容区域
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 亏损汇总
                    _buildTotalLossSection(),
                    
                    const SizedBox(height: 16),
                    
                    // 分布图表
                    _buildDistributionChart(dist),
                    
                    const SizedBox(height: 24),
                    
                    // 账单列表标题
                    _buildBillListHeader(),
                    
                    const SizedBox(height: 12),
                    
                    // 账单列表
                    _buildBillList(sortedPosts),
                    
                    const SizedBox(height: 100), // 为底部导航栏留空间
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }


  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E677).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E677).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 60,
                  color: Color(0xFF00E677),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '查看账单需要登录',
                style: AppTextStyles.pageTitle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '登录后可以查看您的完整亏损账单\n包括累计亏损、分布图表和详细记录',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF9ABCAB),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: widget.onLoginRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E677),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '立即登录',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '扎心亏损总账单',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: _shareBill,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTimeFilterCapsule('周', TimeFilter.week),
            const SizedBox(width: 8),
            _buildTimeFilterCapsule('月', TimeFilter.month),
            const SizedBox(width: 8),
            _buildTimeFilterCapsule('年', TimeFilter.year),
            const SizedBox(width: 8),
            _buildCustomDateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterCapsule(String label, TimeFilter filter) {
    final isActive = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00E677).withOpacity(0.12)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00E677).withOpacity(0.8)
                : const Color(0xFF00E677).withOpacity(0.15),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E677).withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isActive
                ? const Color(0xFF00E677)
                : Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateButton() {
    final isActive = _selectedFilter == TimeFilter.custom;
    return GestureDetector(
      onTap: _selectCustomDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00E677).withOpacity(0.12)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00E677).withOpacity(0.8)
                : const Color(0xFF00E677).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month,
              size: 18,
              color: isActive
                  ? const Color(0xFF00E677)
                  : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              '自定义范围',
              style: AppTextStyles.body.copyWith(
                color: isActive
                    ? const Color(0xFF00E677)
                    : Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 选择自定义日期范围
  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E677),
              onPrimary: Colors.black,
              surface: Color(0xFF050809),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedFilter = TimeFilter.custom;
      });
    }
  }

  Widget _buildTotalLossSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            '当前周期亏损汇总 (CNY)',
            style: AppTextStyles.body.copyWith(
              color: const Color(0xFF9E9E9E),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '-${_formatCurrency(_currentPeriodLoss)}',
            style: AppTextStyles.displayNumber.copyWith(
              color: const Color(0xFF00E677),
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '新增痛点: $_newPainPoints次 ↑',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.redAccent,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '对比同期 ${_growthRate >= 0 ? '+' : ''}${_growthRate.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart(Map<String, double> dist) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
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
                      'STATUS',
                      style: AppTextStyles.label.copyWith(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '全线飘绿',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: Colors.white,
                        fontSize: 18,
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
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('A股', (dist['aStock']! * 100).toStringAsFixed(0), 1.0),
              _buildLegendItem('美股', (dist['usStock']! * 100).toStringAsFixed(0), 0.7),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('币圈', (dist['crypto']! * 100).toStringAsFixed(0), 0.4),
              _buildLegendItem('基金', (dist['fund']! * 100).toStringAsFixed(0), 0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, double opacity) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF00E677).withOpacity(opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($percent%)',
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF9E9E9E),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBillListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '扎心账单单条',
            style: AppTextStyles.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '按损失额倒序',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF9E9E9E),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillList(List<PostModel> posts) {
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            '暂无账单记录',
            style: AppTextStyles.body.copyWith(
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: posts.map((post) {
          final style = _getItemStyle(post);
          final heartBreakLevel = _getHeartBreakLevel(post.amount);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
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
                        post.content.length > 25 
                            ? '${post.content.substring(0, 25)}...' 
                            : post.content,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '心碎指数',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ...List.generate(5, (i) {
                            return Icon(
                              Icons.favorite,
                              size: 12,
                              color: i < heartBreakLevel
                                  ? const Color(0xFF00E677)
                                  : const Color(0xFF9E9E9E).withOpacity(0.3),
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
                        color: const Color(0xFF00E677),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(post.time).toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
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
      const Color(0xFF00E677),
      const Color(0xFF00E677).withOpacity(0.7),
      const Color(0xFF00E677).withOpacity(0.4),
      const Color(0xFF00E677).withOpacity(0.2),
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
