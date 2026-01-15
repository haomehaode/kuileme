import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class MyDiaryView extends StatefulWidget {
  const MyDiaryView({
    super.key,
    required this.onBack,
    required this.posts,
  });

  final VoidCallback onBack;
  final List<PostModel> posts;

  @override
  State<MyDiaryView> createState() => _MyDiaryViewState();
}

class _MyDiaryViewState extends State<MyDiaryView> {
  String _sortBy = 'time'; // time, amount, mood

  List<PostModel> get _sortedPosts {
    final posts = List<PostModel>.from(widget.posts);
    switch (_sortBy) {
      case 'amount':
        posts.sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
        break;
      case 'mood':
        // 按心理状态排序（简化）
        break;
      case 'time':
      default:
        // 默认按时间倒序
        break;
    }
    return posts;
  }

  double get _totalLoss {
    return widget.posts.fold(0.0, (sum, post) => sum + post.amount.abs());
  }

  double get _averageLoss {
    if (widget.posts.isEmpty) return 0;
    return _totalLoss / widget.posts.length;
  }

  PostModel? get _maxLossPost {
    if (widget.posts.isEmpty) return null;
    return widget.posts.reduce((a, b) =>
        a.amount.abs() > b.amount.abs() ? a : b);
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
          '我的日记',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'time',
                child: Text('按时间'),
              ),
              const PopupMenuItem(
                value: 'amount',
                child: Text('按金额'),
              ),
              const PopupMenuItem(
                value: 'mood',
                child: Text('按心情'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: widget.posts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortedPosts.length,
                    itemBuilder: (context, index) {
                      return _DiaryItem(post: _sortedPosts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withOpacity(0.2),
            Colors.redAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(
                label: '总发布数',
                value: '${widget.posts.length}',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _StatColumn(
                label: '总亏损',
                value: '¥${_totalLoss.toStringAsFixed(2)}',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _StatColumn(
                label: '平均亏损',
                value: '¥${_averageLoss.toStringAsFixed(2)}',
              ),
            ],
          ),
          if (_maxLossPost != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '最痛的一天',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '¥${_maxLossPost!.amount.abs().toStringAsFixed(2)}',
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '还没有发布日记',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '快去发布第一条亏损日记吧',
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

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.sectionTitle.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _DiaryItem extends StatelessWidget {
  const _DiaryItem({required this.post});

  final PostModel post;

  String _getMoodLabel(String? mood) {
    final moodMap = {
      'mild': '微痛',
      'heavy': '大出血',
      'bankrupt': '原地破产',
      'soul': '灵魂出窍',
    };
    return moodMap[mood] ?? '未知';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                post.time,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '¥${post.amount.abs().toStringAsFixed(2)}',
                  style: AppTextStyles.captionBold.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (post.mood != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _getMoodLabel(post.mood),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.blue,
                ),
              ),
            ),
          Text(
            post.content,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: post.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BEE6C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.label.copyWith(
                      color: Color(0xFF2BEE6C),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${post.likes}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${post.comments}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
