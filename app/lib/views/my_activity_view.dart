import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/text_styles.dart';

class MyActivityView extends StatefulWidget {
  const MyActivityView({
    super.key,
    required this.onBack,
    this.onPostTap,
    this.apiService,
  });

  final VoidCallback onBack;
  final void Function(PostModel)? onPostTap;
  final ApiService? apiService;

  @override
  State<MyActivityView> createState() => _MyActivityViewState();
}

class _MyActivityViewState extends State<MyActivityView> {
  final ApiService _apiService = ApiService();
  List<PostModel> _myPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyPosts();
  }

  Future<void> _loadMyPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = widget.apiService ?? _apiService;
      final posts = await apiService.getMyPosts();
      setState(() {
        _myPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 计算回响评分（基于点赞、评论、时间等因素）
  double _calculateResonance(PostModel post) {
    // 简单计算：点赞数 * 0.5 + 评论数 * 0.3 + 时间衰减因子
    final baseScore = post.likes * 0.5 + post.comments * 0.3;
    // 时间衰减：越新越高的权重
    final hoursAgo = _getHoursAgo(post.time);
    final timeFactor = hoursAgo < 24 ? 1.0 : (hoursAgo < 168 ? 0.7 : 0.5);
    return (baseScore * timeFactor).clamp(0.0, 100.0);
  }

  int _getHoursAgo(String timeStr) {
    // 简单解析时间字符串，实际应该从created_at计算
    if (timeStr.contains('分钟前')) {
      final minutes = int.tryParse(timeStr.replaceAll('分钟前', '').trim()) ?? 0;
      return minutes ~/ 60;
    } else if (timeStr.contains('小时前')) {
      return int.tryParse(timeStr.replaceAll('小时前', '').trim()) ?? 0;
    } else if (timeStr.contains('天前')) {
      final days = int.tryParse(timeStr.replaceAll('天前', '').trim()) ?? 0;
      return days * 24;
    }
    return 24; // 默认1天前
  }

  /// 获取来源文本
  String _getSource(PostModel post) {
    // 根据标签判断来源
    if (post.tags.contains('投资日常') || post.tags.contains('亏损日常')) {
      return '韭菜地';
    } else if (post.tags.contains('情绪宣泄')) {
      return '情绪宣泄区';
    } else if (post.tags.contains('回血')) {
      return '回血中心';
    }
    return '亏友圈';
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
          '我的动态',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 显示帖子数量信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '共发布 ${_myPosts.length} 条吐槽',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '加载失败',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMyPosts,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : _myPosts.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadMyPosts,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _myPosts.length,
                              itemBuilder: (context, index) {
                                return _buildPostCard(_myPosts[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    final resonance = _calculateResonance(post);
    final source = _getSource(post);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：用户信息和回响评分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2BEE6C).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF2BEE6C).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        post.user.name.isNotEmpty
                            ? post.user.name[0]
                            : '我',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: const Color(0xFF2BEE6C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.name.isNotEmpty ? post.user.name : '我',
                        style: AppTextStyles.bodyBold,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${post.time} · 来自 $source',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 回响评分
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2BEE6C).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF2BEE6C).withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.waves,
                      size: 14,
                      color: const Color(0xFF2BEE6C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '回响 ${resonance.toStringAsFixed(1)}',
                      style: AppTextStyles.captionBold.copyWith(
                        color: const Color(0xFF2BEE6C),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 帖子内容
          Text(
            post.content,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          // 图片（如果有）
          if (post.image != null && post.image!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPostImages(post.image!),
          ],
          // 标签
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BEE6C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF2BEE6C),
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          // 分割线
          Divider(
            color: Colors.white.withOpacity(0.05),
            height: 1,
          ),
          const SizedBox(height: 8),
          // 互动按钮
          Row(
            children: [
              _buildInteractionButton(
                icon: Icons.favorite,
                label: '${post.likes} 心疼',
                isActive: post.isLiked,
                onTap: () {
                  // TODO: 实现点赞功能
                },
              ),
              const SizedBox(width: 24),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments} 评论',
                isActive: false,
                onTap: () {
                  if (widget.onPostTap != null) {
                    widget.onPostTap!(post);
                  }
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                color: Colors.grey,
                iconSize: 20,
                onPressed: () {
                  // TODO: 实现分享功能
                  Clipboard.setData(ClipboardData(text: post.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已复制到剪贴板'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostImages(String imageUrl) {
    // 简单处理：如果是多个图片URL（逗号分隔），显示网格
    final images = imageUrl.split(',').where((url) => url.trim().isNotEmpty).toList();
    
    if (images.isEmpty) return const SizedBox.shrink();
    
    if (images.length == 1) {
      // 单张图片，显示为宽屏
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[0].trim(),
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.withOpacity(0.2),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      // 多张图片，显示为网格
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              images[index].trim(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.withOpacity(0.2),
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          );
        },
      );
    }
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? const Color(0xFF2BEE6C)
                  : const Color(0xFF2BEE6C),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF2BEE6C),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无动态',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '快去发布你的第一条亏损记录吧',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
