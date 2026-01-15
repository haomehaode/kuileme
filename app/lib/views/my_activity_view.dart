import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

enum ActivityType {
  post, // 发布
  comment, // 评论
  like, // 点赞
  share, // 分享
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String content;
  final String time;
  final PostModel? relatedPost;

  ActivityModel({
    required this.id,
    required this.type,
    required this.content,
    required this.time,
    this.relatedPost,
  });
}

class MyActivityView extends StatefulWidget {
  const MyActivityView({
    super.key,
    required this.onBack,
    required this.posts,
  });

  final VoidCallback onBack;
  final List<PostModel> posts;

  @override
  State<MyActivityView> createState() => _MyActivityViewState();
}

class _MyActivityViewState extends State<MyActivityView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ActivityType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ActivityModel> get _activities {
    final activities = <ActivityModel>[];
    
    // 我发布的
    for (final post in widget.posts) {
      activities.add(ActivityModel(
        id: 'post_${post.id}',
        type: ActivityType.post,
        content: '发布了亏损日记：${post.content.substring(0, post.content.length > 20 ? 20 : post.content.length)}...',
        time: post.time,
        relatedPost: post,
      ));
    }

    // 模拟评论和点赞活动
    activities.addAll([
      ActivityModel(
        id: 'comment_1',
        type: ActivityType.comment,
        content: '评论了"天台风很大"的帖子：兄弟，我也亏了...',
        time: '5分钟前',
      ),
      ActivityModel(
        id: 'like_1',
        type: ActivityType.like,
        content: '点赞了"翠花要加杠杆"的帖子',
        time: '1小时前',
      ),
    ]);

    if (_selectedType != null) {
      return activities.where((a) => a.type == _selectedType).toList();
    }
    return activities;
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
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _activities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      return _ActivityItem(
                        activity: _activities[index],
                        onTap: () {
                          if (_activities[index].relatedPost != null) {
                            // TODO: 跳转到帖子详情
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _selectedType = null;
                break;
              case 1:
                _selectedType = ActivityType.post;
                break;
              case 2:
                _selectedType = ActivityType.comment;
                break;
              case 3:
                _selectedType = ActivityType.like;
                break;
            }
          });
        },
        indicatorColor: const Color(0xFF2BEE6C),
        labelColor: const Color(0xFF2BEE6C),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '我发布的'),
          Tab(text: '我评论的'),
          Tab(text: '我点赞的'),
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
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.activity,
    required this.onTap,
  });

  final ActivityModel activity;
  final VoidCallback onTap;

  IconData get _typeIcon {
    switch (activity.type) {
      case ActivityType.post:
        return Icons.edit;
      case ActivityType.comment:
        return Icons.chat_bubble;
      case ActivityType.like:
        return Icons.favorite;
      case ActivityType.share:
        return Icons.share;
    }
  }

  Color get _typeColor {
    switch (activity.type) {
      case ActivityType.post:
        return const Color(0xFF2BEE6C);
      case ActivityType.comment:
        return Colors.blue;
      case ActivityType.like:
        return Colors.redAccent;
      case ActivityType.share:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _typeIcon,
                color: _typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.content,
                    style: AppTextStyles.body.copyWith(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.time,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
