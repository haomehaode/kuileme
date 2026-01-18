import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class TrendingDetailView extends StatefulWidget {
  const TrendingDetailView({
    super.key,
    required this.topic,
    required this.description,
    required this.onBack,
  });

  final String topic;
  final String description;
  final VoidCallback onBack;

  @override
  State<TrendingDetailView> createState() => _TrendingDetailViewState();
}

class _TrendingDetailViewState extends State<TrendingDetailView> {
  String _selectedFilter = '最新';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: Column(
          children: [
            // 头部
            _buildHeader(),
            // 话题信息卡片
            _buildTopicCard(),
            // 筛选标签
            _buildFilterTabs(),
            // 帖子列表
            Expanded(
              child: _buildPostList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.white.withOpacity(0.8),
            onPressed: widget.onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Text(
            '话题详情',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2320).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.topic,
            style: AppTextStyles.displayNumber.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2BEE6C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '1.2w',
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '吐槽',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                '8.5w',
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '围观',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['最新', '最惨', '我的吐槽'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 32),
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? const Color(0xFF2BEE6C) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                filter,
                style: AppTextStyles.body.copyWith(
                  color: isSelected
                      ? const Color(0xFF2BEE6C)
                      : Colors.white.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostList() {
    // 模拟数据，实际应该从API获取
    final mockPosts = [
      {
        'user': '绿光侠007',
        'avatar': 'pink',
        'time': '2分钟前',
        'location': '来自地下三层',
        'heartBreak': 99,
        'content': '第三次补仓了，本以为双底已经形成，没想到这是个通往地心的滑梯。现在已经不是抄底了，是自首。',
        'hasImages': true,
        'comments': 24,
        'likes': 521,
        'isLiked': true,
      },
      {
        'user': '天台常驻课代表',
        'avatar': 'blue',
        'time': '15分钟前',
        'location': '来自关灯面馆',
        'heartBreak': 85,
        'content': '如果上天能给我再来一次的机会，我一定不去抄那个"黄金坑"。那哪是坑啊，那是万人坑。',
        'hasImages': false,
        'comments': 12,
        'likes': 89,
        'isLiked': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: mockPosts.length,
      itemBuilder: (context, index) {
        final post = mockPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final avatarColor = post['avatar'] == 'pink'
        ? [Colors.pink, Colors.orange]
        : [Colors.blue, Colors.purple];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2320).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和心碎指数
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: avatarColor,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['user'] as String,
                        style: AppTextStyles.bodyBold.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${post['time']} · ${post['location']}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '心碎指数 ${post['heartBreak']}%',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 内容
          Text(
            post['content'] as String,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              height: 1.6,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          // 图片（如果有）
          if (post['hasImages'] == true) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://picsum.photos/400/300?random=1',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '-45.2%',
                            style: AppTextStyles.displayNumber.copyWith(
                              fontSize: 20,
                              color: Colors.redAccent,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Text(
                            '持仓截图',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // 互动按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${post['comments']}',
                    onTap: () {},
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.volunteer_activism,
                    label: '${post['likes']}',
                    isLiked: post['isLiked'] as bool,
                    onTap: () {},
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.share),
                color: Colors.white.withOpacity(0.6),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLiked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isLiked ? const Color(0xFF2BEE6C) : Colors.white.withOpacity(0.6),
            fill: isLiked ? 1.0 : 0.0,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
