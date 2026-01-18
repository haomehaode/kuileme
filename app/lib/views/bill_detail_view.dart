import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';
import '../services/api_service.dart';

class BillDetailView extends StatefulWidget {
  const BillDetailView({
    super.key,
    required this.post,
    required this.onBack,
    required this.apiService,
    this.onDelete,
    this.onUpdate,
  });

  final PostModel post;
  final VoidCallback onBack;
  final ApiService apiService;
  final VoidCallback? onDelete;
  final ValueChanged<PostModel>? onUpdate;

  @override
  State<BillDetailView> createState() => _BillDetailViewState();
}

class _BillDetailViewState extends State<BillDetailView> {
  late PostModel _currentPost;
  bool _isLoading = false;
  bool _isEditing = false;
  
  // 交易详情字段（从content中解析或使用默认值）
  String _stockName = '';
  String _stockCode = '600XXX';
  String _transactionType = '卖出平仓';
  double _tradePrice = 0.0;
  double _holdingCost = 0.0;
  
  // 编辑控制器
  late TextEditingController _contentController;
  late TextEditingController _amountController;
  late TextEditingController _stockNameController;
  late TextEditingController _stockCodeController;
  late TextEditingController _tradePriceController;
  late TextEditingController _holdingCostController;
  
  String _selectedMood = 'soul';
  String _selectedTransactionType = '卖出平仓';
  List<String> _selectedTags = [];
  DateTime? _tradeDateTime; // 成交时间
  int _heartBreakLevel = 1; // 心碎指数（1-5）

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    // 初始化交易详情字段
    _initializeTransactionDetails();
    // 初始化控制器
    _initializeControllers();
  }
  
  void _initializeTransactionDetails() {
    // 从content中提取标的名称（取第一个词）
    final contentParts = _currentPost.content.split(' ');
    _stockName = contentParts.isNotEmpty ? contentParts.first : '某某股份';
    
    // 计算成交单价和持仓成本（基于amount）
    _tradePrice = _currentPost.amount.abs() / 100;
    _holdingCost = _currentPost.amount.abs() / 100 * 1.2;
    
    // 初始化其他字段
    _selectedMood = _currentPost.mood ?? 'soul';
    _selectedTransactionType = _transactionType;
    _selectedTags = List.from(_currentPost.tags);
    
    // 初始化成交时间（默认使用当前时间，实际应该从后端获取）
    _tradeDateTime = DateTime.now();
    
    // 初始化心碎指数（基于当前金额计算）
    _heartBreakLevel = _getHeartBreakLevel(_currentPost.amount);
  }
  
  void _initializeControllers() {
    _contentController = TextEditingController(text: _currentPost.content);
    _amountController = TextEditingController(text: _currentPost.amount.abs().toStringAsFixed(2));
    _stockNameController = TextEditingController(text: _stockName);
    _stockCodeController = TextEditingController(text: _stockCode);
    _tradePriceController = TextEditingController(text: _tradePrice.toStringAsFixed(2));
    _holdingCostController = TextEditingController(text: _holdingCost.toStringAsFixed(2));
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    _amountController.dispose();
    _stockNameController.dispose();
    _stockCodeController.dispose();
    _tradePriceController.dispose();
    _holdingCostController.dispose();
    super.dispose();
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

  // 格式化金额
  String _formatCurrency(double amount) {
    final absAmount = amount.abs();
    if (absAmount >= 10000) {
      return '${(absAmount / 10000).toStringAsFixed(2)}万';
    }
    return absAmount.toStringAsFixed(2);
  }

  // 格式化百分比
  String _formatPercentage(double percentage) {
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    final heartBreakLevel = _getHeartBreakLevel(_currentPost.amount);
    final amount = _currentPost.amount.abs();
    final percentage = _currentPost.percentage;

    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: Column(
          children: [
            // 头部
            _buildHeader(context),
            
            // 主内容
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 亏损金额展示区域
                    _buildAmountSection(amount, percentage),
                    
                    const SizedBox(height: 32),
                    
                    // 交易详情卡片
                    _buildTransactionDetails(),
                    
                    const SizedBox(height: 32),
                    
                    // 扎心时刻
                    _buildHeartBreakSection(heartBreakLevel),
                    
                    // 编辑模式下的额外字段
                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      _buildEditableMoodSection(),
                      const SizedBox(height: 32),
                      _buildEditableTagsSection(),
                    ],
                    
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
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, size: 24),
              color: Colors.white70,
              onPressed: _handleCancelEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 24),
              color: Colors.white70,
              onPressed: widget.onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          Text(
            '单笔亏损扎心详情',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2BEE6C)),
                      ),
                    )
                  : const Icon(Icons.check, size: 24),
              color: _isLoading ? Colors.transparent : const Color(0xFF2BEE6C),
              onPressed: _isLoading ? null : _handleSaveEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_horiz,
                  size: 24,
                  color: Colors.white70,
                ),
              ),
              color: const Color(0xFF111318),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    // 一键比惨 - 生成分享海报
                    _handleShare(context);
                    break;
                  case 'review':
                    // 痛定思痛 - 深度复盘记录
                    _handleReview(context);
                    break;
                  case 'edit':
                    // 编辑
                    setState(() {
                      _isEditing = true;
                    });
                    break;
                  case 'delete':
                    // 删除
                    _handleDelete(context);
                    break;
                }
              },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(
                      Icons.share,
                      size: 20,
                      color: Color(0xFF2BEE6C),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '一键比惨',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'review',
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 20,
                      color: Color(0xFF2BEE6C),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '痛定思痛',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '编辑',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '删除',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(double amount, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(
            '亏损金额 (CNY)',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayNumber.copyWith(
                    color: const Color(0xFF2BEE6C),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: AppTextStyles.displayNumber.copyWith(
                      color: const Color(0xFF2BEE6C).withOpacity(0.5),
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  '-${_formatCurrency(amount)}',
                  style: AppTextStyles.displayNumber.copyWith(
                    color: const Color(0xFF2BEE6C),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_down,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPercentage(-percentage),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2BEE6C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _isEditing
              ? _buildEditableDetailRow(
                  '标的名称',
                  _stockNameController,
                  codeController: _stockCodeController,
                )
              : _buildDetailRow('标的名称', _stockName, showCode: true, code: _stockCode),
          Divider(
            height: 24,
            thickness: 0.5,
            color: Colors.white.withOpacity(0.08),
            indent: 0,
            endIndent: 0,
          ),
          _isEditing
              ? _buildEditableTransactionTypeRow()
              : _buildDetailRow('交易类型', _transactionType),
          _isEditing
              ? _buildEditableDetailRow('成交单价', _tradePriceController, prefix: '¥')
              : _buildDetailRow('成交单价', '¥${_tradePrice.toStringAsFixed(2)}'),
          _isEditing
              ? _buildEditableDetailRow('持仓成本', _holdingCostController, prefix: '¥')
              : _buildDetailRow('持仓成本', '¥${_holdingCost.toStringAsFixed(2)}'),
          _isEditing
              ? _buildEditableDateTimeRow()
              : _buildDetailRow('成交时间', _formatDateTime(_tradeDateTime ?? DateTime.now())),
        ],
      ),
    );
  }
  
  Widget _buildEditableDetailRow(
    String label,
    TextEditingController controller, {
    TextEditingController? codeController,
    String? prefix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (codeController != null)
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2BEE6C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: label.contains('单价') || label.contains('成本')
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  inputFormatters: (label.contains('单价') || label.contains('成本'))
                      ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
                      : null,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: label == '成交单价' || label == '持仓成本'
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixText: prefix,
                    prefixStyle: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2BEE6C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (codeController != null) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: codeController,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2BEE6C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildEditableDateTimeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '成交时间',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _tradeDateTime ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF2BEE6C),
                          onPrimary: Colors.black,
                          surface: Color(0xFF111318),
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: const Color(0xFF111318),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_tradeDateTime ?? DateTime.now()),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF2BEE6C),
                            onPrimary: Colors.black,
                            surface: Color(0xFF111318),
                            onSurface: Colors.white,
                          ),
                          dialogBackgroundColor: const Color(0xFF111318),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _tradeDateTime = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateTime(_tradeDateTime ?? DateTime.now()),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF2BEE6C),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEditableTransactionTypeRow() {
    final List<String> transactionTypes = [
      '买入开仓',
      '卖出平仓',
      '买入平仓',
      '卖出开仓',
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '交易类型',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: DropdownButton<String>(
                  value: _selectedTransactionType,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF2BEE6C),
                      size: 20,
                    ),
                  ),
                  dropdownColor: const Color(0xFF111318),
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                items: transactionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        type,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTransactionType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showCode = false, String? code}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (showCode)
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  code ?? '600XXX',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                ],
              ),
            )
          else if (label == '交易类型')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: label == '成交单价' || label == '持仓成本' 
                      ? FontWeight.w500 
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeartBreakSection(int heartBreakLevel) {
    // 使用状态变量而不是参数
    final displayLevel = _isEditing ? _heartBreakLevel : heartBreakLevel;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFF2BEE6C),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '扎心时刻',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2BEE6C).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '心碎指数',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _isEditing
                        ? Row(
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _heartBreakLevel = index + 1;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: index < displayLevel
                                        ? const Color(0xFF2BEE6C)
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              );
                            }),
                          )
                        : Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.favorite,
                                size: 16,
                                color: index < displayLevel
                                    ? const Color(0xFF2BEE6C)
                                    : Colors.grey.withOpacity(0.3),
                              );
                            }),
                          ),
                  ],
                ),
                const SizedBox(height: 20),
                _isEditing
                    ? TextField(
                        controller: _contentController,
                        maxLines: 5,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: '记录你的扎心时刻...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2BEE6C),
                              width: 1.5,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        _currentPost.content.isNotEmpty
                            ? '"${_currentPost.content}"'
                            : '"当时觉得是抄底，结果是抄在了山腰上。看着那根长阴线跌下来的时候，心跳直接漏了一拍。这就是所谓的贪婪的代价吧..."',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '记录于 ${_currentPost.time}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    // TODO: 实现分享功能 - 生成分享海报
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能开发中...'),
        backgroundColor: Color(0xFF2BEE6C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleReview(BuildContext context) {
    // TODO: 实现复盘功能 - 深度复盘记录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('复盘功能开发中...'),
        backgroundColor: Color(0xFF2BEE6C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCancelEdit() {
    setState(() {
      _isEditing = false;
      // 恢复原始值
      _contentController.text = _currentPost.content;
      _amountController.text = _currentPost.amount.abs().toStringAsFixed(2);
      _stockNameController.text = _stockName;
      _stockCodeController.text = _stockCode;
      _tradePriceController.text = _tradePrice.toStringAsFixed(2);
      _holdingCostController.text = _holdingCost.toStringAsFixed(2);
      _selectedMood = _currentPost.mood ?? 'soul';
      _selectedTransactionType = _transactionType;
      _selectedTags = List.from(_currentPost.tags);
      _tradeDateTime = DateTime.now(); // 恢复默认时间
      _heartBreakLevel = _getHeartBreakLevel(_currentPost.amount); // 恢复心碎指数
    });
  }

  Future<void> _handleSaveEdit() async {
    // 验证输入
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效的亏损金额'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入内容'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_stockNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入标的名称'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    final tradePrice = double.tryParse(_tradePriceController.text) ?? 0.0;
    final holdingCost = double.tryParse(_holdingCostController.text) ?? 0.0;

    setState(() => _isLoading = true);
    try {
      // 构建包含交易详情的content
      final transactionInfo = '${_stockNameController.text.trim()} ${_stockCodeController.text.trim()}';
      final fullContent = '$transactionInfo ${_contentController.text.trim()}';
      
      final updatedPost = await widget.apiService.updatePost(
        postId: int.parse(_currentPost.id),
        content: fullContent,
        amount: -amount, // 亏损金额为负数
        mood: _selectedMood,
        tags: _selectedTags,
        isAnonymous: false,
      );
      
      // 更新本地状态
      setState(() {
        _currentPost = updatedPost;
        _stockName = _stockNameController.text.trim();
        _stockCode = _stockCodeController.text.trim();
        _transactionType = _selectedTransactionType;
        _tradePrice = tradePrice;
        _holdingCost = holdingCost;
        _isLoading = false;
        _isEditing = false;
      });
      
      if (widget.onUpdate != null) {
        widget.onUpdate!(updatedPost);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('更新成功'),
          backgroundColor: Color(0xFF2BEE6C),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  Widget _buildEditableMoodSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2BEE6C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '心理状态',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMoodChip(
                  'mild',
                  '微痛',
                  Icons.favorite,
                  _selectedMood,
                  () {
                    setState(() => _selectedMood = 'mild');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMoodChip(
                  'heavy',
                  '大出血',
                  Icons.sentiment_very_dissatisfied,
                  _selectedMood,
                  () {
                    setState(() => _selectedMood = 'heavy');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMoodChip(
                  'bankrupt',
                  '原地破产',
                  Icons.warning_amber_rounded,
                  _selectedMood,
                  () {
                    setState(() => _selectedMood = 'bankrupt');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMoodChip(
                  'soul',
                  '灵魂出窍',
                  Icons.water_drop,
                  _selectedMood,
                  () {
                    setState(() => _selectedMood = 'soul');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTagsSection() {
    final List<String> availableTags = [
      '大盘A股',
      '纳斯达克',
      '币圈',
      '末日期权',
      '基金经理死对头',
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2BEE6C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '标签',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 预设标签
              ...availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF2BEE6C).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF2BEE6C),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF2BEE6C) : Colors.white70,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF2BEE6C) : Colors.white.withOpacity(0.1),
                  ),
                );
              }),
              // 自定义标签按钮
              GestureDetector(
                onTap: () {
                  _showCustomTagDialog(context, _selectedTags);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '自定义',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 已选择的自定义标签
              ..._selectedTags.where((tag) => !availableTags.contains(tag)).map((tag) {
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF2BEE6C),
                        ),
                      ),
                    ],
                  ),
                  selected: true,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTags.remove(tag);
                    });
                  },
                  selectedColor: const Color(0xFF2BEE6C).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF2BEE6C),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2BEE6C),
                  ),
                  side: const BorderSide(
                    color: Color(0xFF2BEE6C),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip(
    String moodId,
    String label,
    IconData icon,
    String currentMood,
    VoidCallback onTap,
  ) {
    final isSelected = currentMood == moodId;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2BEE6C).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2BEE6C)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2BEE6C) : Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? const Color(0xFF2BEE6C) : Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomTagDialog(
    BuildContext context,
    List<String> selectedTags,
  ) {
    final tagController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111318),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          title: Text(
            '添加自定义标签',
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: tagController,
            autofocus: true,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: '请输入标签名称',
              hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
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
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty && !selectedTags.contains(value.trim())) {
                setState(() {
                  selectedTags.add(value.trim());
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final tag = tagController.text.trim();
                if (tag.isNotEmpty && !selectedTags.contains(tag)) {
                  setState(() {
                    selectedTags.add(tag);
                  });
                  Navigator.of(context).pop();
                } else if (selectedTags.contains(tag)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('标签已存在'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(
                '添加',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF2BEE6C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111318),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          title: Text(
            '确认删除',
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white,
            ),
          ),
          content: Text(
            '确定要删除这条亏损记录吗？删除后无法恢复。',
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                try {
                  await widget.apiService.deletePost(int.parse(_currentPost.id));
                  if (widget.onDelete != null) {
                    widget.onDelete!();
                  }
                  widget.onBack(); // 删除后返回上一页
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('删除失败: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: Text(
                '删除',
                style: AppTextStyles.body.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
