import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

enum TimeFilter { week, month, year, custom }

enum SortOrder { amount, time }

class BillView extends StatefulWidget {
  const BillView({
    super.key,
    required this.posts,
    this.isLoggedIn = false,
    this.onLoginRequest,
    this.onPostTap,
  });

  final List<PostModel> posts;
  final bool isLoggedIn;
  final VoidCallback? onLoginRequest;
  final ValueChanged<PostModel>? onPostTap;

  @override
  State<BillView> createState() => _BillViewState();
}

class _BillViewState extends State<BillView> {
  TimeFilter _selectedFilter = TimeFilter.month;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  SortOrder _sortOrder = SortOrder.amount;
  
  // 初始化当前时间范围
  late DateTime _currentWeekStart;
  late DateTime _currentMonth;
  late int _currentYear;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentWeekStart = _getWeekStart(now);
    _currentMonth = DateTime(now.year, now.month, 1);
    _currentYear = now.year;
  }
  
  // 静态方法：获取一周的开始（周一）
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // 获取当前筛选的日期范围
  DateTimeRange get _currentDateRange {
    switch (_selectedFilter) {
      case TimeFilter.week:
        final weekEnd = _currentWeekStart.add(const Duration(days: 6));
        return DateTimeRange(start: _currentWeekStart, end: weekEnd);
      case TimeFilter.month:
        final monthEnd = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
        return DateTimeRange(start: _currentMonth, end: monthEnd);
      case TimeFilter.year:
        final yearStart = DateTime(_currentYear, 1, 1);
        final yearEnd = DateTime(_currentYear, 12, 31);
        return DateTimeRange(start: yearStart, end: yearEnd);
      case TimeFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return DateTimeRange(start: _customStartDate!, end: _customEndDate!);
        }
        final now = DateTime.now();
        return DateTimeRange(start: now, end: now);
    }
  }

  // 根据时间筛选获取帖子列表
  List<PostModel> get _filteredPosts {
    final dateRange = _currentDateRange;
    final startDate = dateRange.start;
    final endDate = dateRange.end;

    return widget.posts.where((post) {
      final postDate = _parsePostDate(post.time);
      if (postDate == null) return false;
      return postDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          postDate.isBefore(endDate.add(const Duration(days: 1)));
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

  // 解析帖子时间字符串为DateTime（用于排序）
  DateTime _parsePostDateForSort(PostModel post) {
    // 尝试从 time 字符串解析
    final timeStr = post.time;
    if (timeStr.contains('刚刚') || timeStr.contains('Just now')) {
      return DateTime.now();
    }
    if (timeStr.contains('分钟前')) {
      final minutes = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return DateTime.now().subtract(Duration(minutes: minutes));
    }
    if (timeStr.contains('小时前')) {
      final hours = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return DateTime.now().subtract(Duration(hours: hours));
    }
    if (timeStr.contains('天前')) {
      final days = int.tryParse(timeStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return DateTime.now().subtract(Duration(days: days));
    }
    // 尝试解析绝对日期格式 YYYY-MM-DD
    try {
      final parts = timeStr.split('-');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]) ?? DateTime.now().year;
        final month = int.tryParse(parts[1]) ?? DateTime.now().month;
        final day = int.tryParse(parts[2]) ?? DateTime.now().day;
        return DateTime(year, month, day);
      }
    } catch (e) {
      // 解析失败，返回当前时间
    }
    return DateTime.now();
  }

  // 获取账单列表（支持按损失额或时间排序）
  List<PostModel> get _sortedPosts {
    final sorted = List<PostModel>.from(_filteredPosts);
    if (_sortOrder == SortOrder.amount) {
      // 按损失额倒序
      sorted.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    } else {
      // 按时间倒序（最新的在前）
      sorted.sort((a, b) {
        final dateA = _parsePostDateForSort(a);
        final dateB = _parsePostDateForSort(b);
        return dateB.compareTo(dateA);
      });
    }
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
        'color': const Color(0xFF2BEE6C),
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
        'color': const Color(0xFF2BEE6C),
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
    final periodText = _getPeriodText();
    final shareText = '''
扎心亏损总账单

$periodText亏损汇总: -${_formatCurrency(_currentPeriodLoss)} CNY
新增痛点: $_newPainPoints次
对比同期: ${_growthRate >= 0 ? '+' : ''}${_growthRate.toStringAsFixed(1)}%

分布情况:
A股: ${(dist['aStock']! * 100).toStringAsFixed(0)}%
美股: ${(dist['usStock']! * 100).toStringAsFixed(0)}%
币圈: ${(dist['crypto']! * 100).toStringAsFixed(0)}%
基金: ${(dist['fund']! * 100).toStringAsFixed(0)}%

来自"亏了么"App
''';
    
    try {
      await Share.share(shareText);
    } catch (e) {
      // 如果分享失败，尝试复制到剪贴板
      try {
        await Clipboard.setData(ClipboardData(text: shareText));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('账单已复制到剪贴板'),
              backgroundColor: Color(0xFF2BEE6C),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('分享失败: $e2')),
          );
        }
      }
    }
  }

  String _getPeriodText() {
    switch (_selectedFilter) {
      case TimeFilter.week:
        final range = _currentDateRange;
        final start = range.start;
        final end = range.end;
        // 如果同一个月，只显示一次月份
        if (start.year == end.year && start.month == end.month) {
          return '${start.year}/${start.month}/${start.day}-${end.day}';
        } else {
          return '${start.year}/${start.month}/${start.day}-${end.year}/${end.month}/${end.day}';
        }
      case TimeFilter.month:
        return '${_currentMonth.year}/${_currentMonth.month}';
      case TimeFilter.year:
        return '$_currentYear';
      case TimeFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          final start = _customStartDate!;
          final end = _customEndDate!;
          if (start.year == end.year && start.month == end.month && start.day == end.day) {
            return '${start.year}/${start.month}/${start.day}';
          }
          return '${start.year}/${start.month}/${start.day}-${end.year}/${end.month}/${end.day}';
        }
        return '自定义范围';
    }
  }

  // 切换到上一周/下一周
  void _navigateWeek(int direction) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: direction * 7));
    });
  }

  // 切换到上一月/下一月
  void _navigateMonth(int direction) {
    setState(() {
      if (direction > 0) {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      }
    });
  }

  // 切换到上一年/下一年
  void _navigateYear(int direction) {
    setState(() {
      _currentYear += direction;
    });
  }

  // 切换时间范围
  void _navigateTimeRange(int direction) {
    switch (_selectedFilter) {
      case TimeFilter.week:
        _navigateWeek(direction);
        break;
      case TimeFilter.month:
        _navigateMonth(direction);
        break;
      case TimeFilter.year:
        _navigateYear(direction);
        break;
      case TimeFilter.custom:
        // 自定义范围不支持切换
        break;
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
                    
                    const SizedBox(height: 12),
                    
                    // 分布图表
                    _buildDistributionChart(dist),
                    
                    const SizedBox(height: 12),
                    
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '扎心亏损总账单',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: _shareBill,
            icon: const Icon(Icons.share_outlined, size: 20),
            color: Colors.white,
            tooltip: '分享账单',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          // 切换到当前时间范围
          final now = DateTime.now();
          if (filter == TimeFilter.week) {
            _currentWeekStart = _getWeekStart(now);
          } else if (filter == TimeFilter.month) {
            _currentMonth = DateTime(now.year, now.month, 1);
          } else if (filter == TimeFilter.year) {
            _currentYear = now.year;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2BEE6C).withOpacity(0.12)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF2BEE6C).withOpacity(0.8)
                : const Color(0xFF2BEE6C).withOpacity(0.15),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2BEE6C).withOpacity(0.35),
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
                ? const Color(0xFF2BEE6C)
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
              ? const Color(0xFF2BEE6C).withOpacity(0.12)
              : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF2BEE6C).withOpacity(0.8)
                : const Color(0xFF2BEE6C).withOpacity(0.15),
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2BEE6C).withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          '自定义',
          style: AppTextStyles.body.copyWith(
            color: isActive
                ? const Color(0xFF2BEE6C)
                : Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 选择自定义日期范围（点击自定义按钮时）
  Future<void> _selectCustomDateRange() async {
    setState(() {
      _selectedFilter = TimeFilter.custom;
      // 如果没有设置日期，默认使用最近一周
      if (_customStartDate == null || _customEndDate == null) {
        final now = DateTime.now();
        _customEndDate = now;
        _customStartDate = now.subtract(const Duration(days: 6));
      }
    });
  }

  // 选择开始日期
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? DateTime.now().subtract(const Duration(days: 6)),
      firstDate: DateTime(2020),
      lastDate: _customEndDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2BEE6C),
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
        _customStartDate = picked;
        // 如果开始日期晚于结束日期，调整结束日期
        if (_customEndDate != null && picked.isAfter(_customEndDate!)) {
          _customEndDate = picked;
        }
      });
    }
  }

  // 选择结束日期
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _customEndDate ?? DateTime.now(),
      firstDate: _customStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2BEE6C),
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
        _customEndDate = picked;
        // 如果结束日期早于开始日期，调整开始日期
        if (_customStartDate != null && picked.isBefore(_customStartDate!)) {
          _customStartDate = picked;
        }
      });
    }
  }

  Widget _buildTotalLossSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // 统一的时间显示布局：左右箭头占位，中间显示时间
          SizedBox(
            height: 24, // 固定高度，确保所有模式下高度一致
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧箭头（自定义模式下不显示，但保留占位空间）
                if (_selectedFilter != TimeFilter.custom)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    color: Colors.white,
                    onPressed: () => _navigateTimeRange(-1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  const SizedBox(width: 24, height: 24), // 占位空间，保持对齐
                const SizedBox(width: 8),
                
                // 中间时间显示区域
                if (_selectedFilter == TimeFilter.custom)
                  // 自定义模式：显示开始和结束日期，每个都有向下箭头
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 开始日期
                      GestureDetector(
                        onTap: _selectStartDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _customStartDate != null
                                  ? '${_customStartDate!.year}/${_customStartDate!.month}/${_customStartDate!.day}'
                                  : '开始日期',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '-',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 结束日期
                      GestureDetector(
                        onTap: _selectEndDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _customEndDate != null
                                  ? '${_customEndDate!.year}/${_customEndDate!.month}/${_customEndDate!.day}'
                                  : '结束日期',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  // 非自定义模式：显示时间范围文本
                  Text(
                    _getPeriodText(),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                
                const SizedBox(width: 8),
                // 右侧箭头（自定义模式下不显示，但保留占位空间）
                if (_selectedFilter != TimeFilter.custom)
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    color: Colors.white,
                    onPressed: () => _navigateTimeRange(1),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  const SizedBox(width: 24, height: 24), // 占位空间，保持对齐
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '-${_formatCurrency(_currentPeriodLoss)}',
            style: AppTextStyles.displayNumber.copyWith(
              color: const Color(0xFF2BEE6C),
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Text(
                      '新增痛点: $_newPainPoints次',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '对比同期 ${_growthRate >= 0 ? '+' : ''}${_growthRate.toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
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
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
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
            color: const Color(0xFF2BEE6C).withOpacity(opacity),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          GestureDetector(
            onTap: () {
              // 切换排序方式
              setState(() {
                _sortOrder = _sortOrder == SortOrder.amount 
                    ? SortOrder.time 
                    : SortOrder.amount;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sortOrder == SortOrder.amount 
                      ? '按损失额倒序' 
                      : '按时间倒序',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF2BEE6C),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.swap_vert,
                  size: 16,
                  color: Color(0xFF2BEE6C),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: posts.map((post) {
          final style = _getItemStyle(post);
          final heartBreakLevel = _getHeartBreakLevel(post.amount);
          
          return GestureDetector(
            onTap: () {
              if (widget.onPostTap != null) {
                widget.onPostTap!(post);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111318),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
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
                        color: const Color(0xFF2BEE6C),
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
    // 根据容器宽度动态计算半径，留出足够的边距
    final availableWidth = size.width;
    final maxRadius = (availableWidth / 2) - 20; // 留出20px边距
    final radius = maxRadius.clamp(70.0, 90.0); // 最小70，最大90
    final strokeWidth = 16.0;

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
