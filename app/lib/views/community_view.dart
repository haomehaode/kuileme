import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import '../theme/text_styles.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({
    super.key,
    required this.posts,
    required this.onPostTap,
    this.onPostCreate,
  });

  final List<PostModel> posts;
  final void Function(PostModel post) onPostTap;
  final VoidCallback? onPostCreate;

  // 默认数据，供根组件初始化使用
  static final List<PostModel> mockPosts = [
    PostModel(
      id: '1',
      user: const PostUser(
        name: '天台风很大',
        avatar: 'https://picsum.photos/100/100?random=1',
        level: 88,
        device: 'iPhone 15 Pro Max',
      ),
      content:
          '原本以为是抄底，没想到是抄到了半山腰。这波操作我直接反向起飞，还有救吗？兄弟们给个准话，现在去送外卖还来得及吗？',
      amount: 82341,
      percentage: -9.82,
      tags: const ['某科技精选'],
      likes: 128,
      comments: 42,
      time: '10分钟前',
      location: '上海',
      image: 'https://picsum.photos/600/400?random=10',
    ),
    PostModel(
      id: '2',
      user: const PostUser(
        name: '翠花要加杠杆',
        avatar: 'https://picsum.photos/100/100?random=2',
        level: 12,
        device: 'Android 14',
      ),
      content:
          '当初谁跟我说白马股稳如老狗的？现在跌得我心惊肉跳。已经把刚买的小包退了，准备今晚关灯吃面。',
      amount: 15420,
      percentage: -12.4,
      tags: const ['某消费白马'],
      likes: 89,
      comments: 15,
      time: '1小时前',
      location: '深圳',
      image: 'https://picsum.photos/600/400?random=11',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotCards(),
                const SizedBox(height: 16),
                _buildTopicBar(),
                const SizedBox(height: 16),
                ...posts.map((post) => PostCard(
                      post: post,
                      onTap: () => onPostTap(post),
                    )),
              ],
            ),
          ),
        ),
      ],
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
            '亏友圈',
            style: AppTextStyles.cardTitle.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 24),
              ),
              IconButton(
                onPressed: onPostCreate,
                icon: const Icon(Icons.add_circle_outline, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotCards() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _HotCard(
            icon: Icons.trending_down,
            iconColor: Colors.redAccent,
            title: '今日跌幅榜',
            subtitle: '芯片板块 -8.42%',
            footer: '5.2万人在哀嚎',
          ),
          const SizedBox(width: 12),
          _HotCard(
            icon: Icons.local_florist_outlined,
            iconColor: Colors.orange,
            title: '最惨韭菜大本营',
            subtitle: '中概互联交流群',
            footer: '2.1万新入坑',
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '超话',
              style: AppTextStyles.labelBold.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '# 离回本还差100% #',
              style: AppTextStyles.captionBold.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            '立即参与',
            style: AppTextStyles.labelBold.copyWith(
              color: Colors.grey,
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _HotCard extends StatelessWidget {
  const _HotCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.footer,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: AppTextStyles.captionBold.copyWith(
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyBold,
          ),
          const SizedBox(height: 4),
          Text(
            footer,
            style: AppTextStyles.label.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
