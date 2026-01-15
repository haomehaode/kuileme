import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class PostLossView extends StatefulWidget {
  const PostLossView({
    super.key,
    required this.onBack,
    required this.onPublish,
  });

  final VoidCallback onBack;
  final void Function(PostModel post) onPublish;

  @override
  State<PostLossView> createState() => _PostLossViewState();
}

class _PostLossViewState extends State<PostLossView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = 'soul';
  bool _isAnonymous = false;
  final Set<String> _selectedTags = {};

    final List<Map<String, dynamic>> _moods = [
    {'id': 'mild', 'label': '微痛', 'icon': Icons.favorite},
    {'id': 'heavy', 'label': '大出血', 'icon': Icons.sentiment_very_dissatisfied},
    {'id': 'bankrupt', 'label': '原地破产', 'icon': Icons.warning_amber_rounded},
    {'id': 'soul', 'label': '灵魂出窍', 'icon': Icons.water_drop},
  ];

  final List<String> _tags = [
    '大盘A股',
    '纳斯达克',
    '币圈',
    '末日期权',
    '基金经理死对头',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _contentController.dispose();
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
          icon: const Icon(Icons.close, size: 28),
          onPressed: widget.onBack,
        ),
        title: Text(
          '今天亏了多少？',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _handlePublish,
            child: Text(
              '发布',
              style: AppTextStyles.subtitle.copyWith(
                color: Color(0xFF2BEE6C),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountInput(),
            const SizedBox(height: 32),
            _buildMoodSelection(),
            const SizedBox(height: 32),
            _buildContentField(),
            const SizedBox(height: 32),
            _buildTagSelection(),
            const SizedBox(height: 32),
            _buildAnonymousToggle(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF050809),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _handlePublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BEE6C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '发布日记并宣泄',
              style: AppTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      children: [
        Text(
          '输入亏损金额 (CNY)',
          style: AppTextStyles.captionBold.copyWith(
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¥',
              style: AppTextStyles.numberLarge.copyWith(
                color: Color(0xFF2BEE6C),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.center,
                style: AppTextStyles.displayNumberLarge.copyWith(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: AppTextStyles.displayNumberLarge.copyWith(
                    color: Colors.white10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodSelection() {
    return Column(
      children: [
        Text(
          '现在的心理状态',
          style: AppTextStyles.captionBold.copyWith(
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _moods.length,
          itemBuilder: (context, index) {
            final mood = _moods[index];
            final isSelected = _selectedMood == mood['id'];
            return InkWell(
              onTap: () => setState(() => _selectedMood = mood['id'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2BEE6C).withOpacity(0.1)
                      : const Color(0xFF111318),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2BEE6C)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mood['icon'] as IconData,
                      size: 28,
                      color: isSelected
                          ? const Color(0xFF2BEE6C)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood['label'] as String,
                      style: AppTextStyles.labelBold.copyWith(
                        color: isSelected
                            ? const Color(0xFF2BEE6C)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自嘲或吐槽',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          maxLines: 5,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: '在这里写下你的亏钱故事，让大家开心一下...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF111318),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2BEE6C)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关联标的',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => _buildTagChip(tag)),
            _buildCustomTagChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2BEE6C).withOpacity(0.1)
              : const Color(0xFF111318),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2BEE6C)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          tag,
          style: AppTextStyles.captionBold.copyWith(
            color: isSelected ? const Color(0xFF2BEE6C) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTagChip() {
    return InkWell(
      onTap: () {
        // TODO: 显示自定义标签输入对话框
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              '自定义',
              style: AppTextStyles.captionBold.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_off, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                '匿名发布（更少尴尬）',
                style: AppTextStyles.bodyBold.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            activeColor: const Color(0xFF2BEE6C),
          ),
        ],
      ),
    );
  }

  void _handlePublish() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      _showError('请输入大于 0 的亏损金额');
      return;
    }
    if (_selectedMood.isEmpty) {
      _showError('请选择当前的心理状态');
      return;
    }
    if (_selectedTags.isEmpty) {
      _showError('请至少选择一个关联标的');
      return;
    }

    final now = DateTime.now();
    final post = PostModel(
      id: now.millisecondsSinceEpoch.toString(),
      user: const PostUser(
        name: '匿名亏友',
        avatar: 'https://picsum.photos/100/100?random=999',
        level: 1,
      ),
      content: _contentController.text.trim().isEmpty
          ? '今天又亏了，先发条日记冷静一下。'
          : _contentController.text.trim(),
      amount: -amount,
      percentage: -5.0,
      tags: _selectedTags.toList(),
      likes: 0,
      comments: 0,
      time: '刚刚',
      location: null,
      image: null,
      mood: _selectedMood,
      isAnonymous: _isAnonymous,
    );

    widget.onPublish(post);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('发布成功，已为你发放 5 元回血金示例奖励')),
    );

    _amountController.clear();
    _contentController.clear();
    _selectedTags.clear();
    _selectedMood = 'soul';
    _isAnonymous = false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
