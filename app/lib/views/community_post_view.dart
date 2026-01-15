import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class CommunityPostView extends StatefulWidget {
  const CommunityPostView({
    super.key,
    required this.onBack,
    required this.onPublish,
  });

  final VoidCallback onBack;
  final void Function(PostModel post) onPublish;

  @override
  State<CommunityPostView> createState() => _CommunityPostViewState();
}

class _CommunityPostViewState extends State<CommunityPostView> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _images = [];
  String? _selectedStock;
  double _moodLevel = 75.0;
  String? _location;
  String _visibility = '公开';
  final int _maxLength = 1000;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContentCard(),
                    const SizedBox(height: 16),
                    if (_selectedStock != null) _buildStockCard(),
                    if (_selectedStock == null) ...[
                      const SizedBox(height: 16),
                      _buildMoodSlider(),
                    ],
                    if (_selectedStock != null) ...[
                      const SizedBox(height: 16),
                      _buildMoodSlider(),
                    ],
                    const SizedBox(height: 16),
                    _buildSettingsList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          TextButton(
            onPressed: widget.onBack,
            child: Text(
              '取消',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Text(
            '发布动态',
            style: AppTextStyles.appBarTitle,
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2BEE6C),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2BEE6C).withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TextButton(
              onPressed: _handlePublish,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                foregroundColor: Colors.black,
              ),
              child: Text(
                '发布',
                style: AppTextStyles.bodyBold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _contentController,
            maxLines: null,
            minLines: 6,
            maxLength: _maxLength,
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '分享你的扎心瞬间...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 18,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildToolButton(
                    icon: Icons.alternate_email,
                    onTap: () {
                      // TODO: @用户功能
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildToolButton(
                    icon: Icons.tag,
                    onTap: () {
                      // TODO: 标签功能
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildToolButton(
                    icon: Icons.mood,
                    onTap: () {
                      // TODO: 表情功能
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildToolButton(
                    icon: Icons.bar_chart,
                    onTap: () {
                      _showStockSelector();
                    },
                  ),
                ],
              ),
              Text(
                '${_contentController.text.length} / $_maxLength',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.2),
                  fontFeatures: [const FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildImageGrid(),
        ],
      ),
    );
  }

  Widget _buildToolButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 22,
          color: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildAddImageButton();
        }
        return _buildImageItem(_images[index - 1], index - 1);
      },
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: () {
        // TODO: 选择图片
        setState(() {
          // 模拟添加图片
          if (_images.length < 9) {
            _images.add('https://picsum.photos/400/400?random=${_images.length}');
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              '添加截图',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                _images.removeAt(index);
              });
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard() {
    if (_selectedStock == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_down,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedStock ?? '某某科技精选',
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock Code: 002XXX',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              '-9.82%',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSlider() {
    final moodLabels = ['想送外卖了', '心如死灰', '彻底崩溃', '原地爆炸'];
    final currentLabel = moodLabels[
      ((_moodLevel - 1) / 99 * (moodLabels.length - 1)).round().clamp(0, moodLabels.length - 1)
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '此刻心情指数',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2BEE6C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2BEE6C).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  currentLabel,
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF2BEE6C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  '💔',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _moodLevel,
                  min: 1,
                  max: 100,
                  activeColor: const Color(0xFF2BEE6C),
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (value) {
                    setState(() {
                      _moodLevel = value;
                    });
                  },
                ),
              ),
              Opacity(
                opacity: 0.8,
                child: Text(
                  '💥',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '从心碎到炸裂',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.location_on,
          title: '你在哪里？',
          value: _location,
          onTap: () {
            // TODO: 选择位置
            setState(() {
              _location = _location == null ? '上海' : null;
            });
          },
        ),
        Divider(
          color: Colors.white.withOpacity(0.05),
          height: 1,
        ),
        _buildSettingItem(
          icon: Icons.public,
          title: '谁可以看',
          value: _visibility,
          onTap: () {
            _showVisibilitySelector();
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.white.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (value != null)
                  Text(
                    value,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.white.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStockSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111318),
        title: Text(
          '选择股票',
          style: AppTextStyles.bodyBold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStockOption('某某科技精选', '-9.82%'),
            const SizedBox(height: 8),
            _buildStockOption('某消费白马', '-12.4%'),
            const SizedBox(height: 8),
            _buildStockOption('某新能源', '-15.2%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStock = null;
              });
              Navigator.of(context).pop();
            },
            child: Text(
              '清除',
              style: AppTextStyles.body.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockOption(String name, String percentage) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStock = name;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.body,
              ),
            ),
            Text(
              percentage,
              style: AppTextStyles.labelBold.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVisibilitySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111318),
        title: Text(
          '谁可以看',
          style: AppTextStyles.bodyBold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisibilityOption('公开', '所有人可见'),
            const SizedBox(height: 8),
            _buildVisibilityOption('仅好友', '仅好友可见'),
            const SizedBox(height: 8),
            _buildVisibilityOption('私密', '仅自己可见'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption(String title, String subtitle) {
    final isSelected = _visibility == title;
    return InkWell(
      onTap: () {
        setState(() {
          _visibility = title;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2BEE6C).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2BEE6C)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFF2BEE6C),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _handlePublish() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
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
      content: _contentController.text.trim(),
      amount: 0,
      percentage: _selectedStock != null ? -9.82 : 0,
      tags: _selectedStock != null ? [_selectedStock!] : [],
      likes: 0,
      comments: 0,
      time: '刚刚',
      location: _location,
      image: _images.isNotEmpty ? _images.first : null,
      mood: _moodLevel.toString(),
      isAnonymous: false,
    );

    widget.onPublish(post);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发布成功'),
        backgroundColor: Color(0xFF2BEE6C),
      ),
    );
  }
}
