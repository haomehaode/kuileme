import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class PostDetailView extends StatefulWidget {
  const PostDetailView({
    super.key,
    required this.post,
    required this.onBack,
    required this.onUpdatePost,
    required this.onAddComment,
  });

  final PostModel post;
  final VoidCallback onBack;
  final void Function(PostModel) onUpdatePost;
  final void Function(String postId, CommentModel comment) onAddComment;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  late PostModel _post;
  final List<CommentModel> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    // 初始化一些示例评论
    _comments.addAll([
      CommentModel(
        id: 'c1',
        user: const PostUser(
          name: '外卖小哥小张',
          avatar: 'https://picsum.photos/100/100?random=20',
          level: 5,
        ),
        content: '兄弟别怕，我已经在美团上线了，跑单其实也没那么苦，起码不用看盘。 #这就去送外卖',
        time: '2小时前',
        likes: 42,
      ),
      CommentModel(
        id: 'c2',
        user: const PostUser(
          name: '半仓大魔王',
          avatar: 'https://picsum.photos/100/100?random=21',
          level: 88,
        ),
        content: '看到你亏这么多，我心里舒服多了。我也干了，晚上一起吃面。 #关灯吃面 #亏友抱抱',
        time: '3小时前',
        likes: 15,
      ),
    ]);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      if (_post.isLiked) {
        _post.isLiked = false;
        _post.likes--;
      } else {
        // 如果已心碎，先取消心碎
        if (_post.isHeartbroken) {
          _post.isHeartbroken = false;
        }
        _post.isLiked = true;
        _post.likes++;
      }
    });
    widget.onUpdatePost(_post);
  }

  void _handleHeartbreak() {
    setState(() {
      if (_post.isHeartbroken) {
        _post.isHeartbroken = false;
      } else {
        // 如果已点赞，先取消点赞
        if (_post.isLiked) {
          _post.isLiked = false;
          _post.likes--;
        }
        _post.isHeartbroken = true;
      }
    });
    widget.onUpdatePost(_post);
  }

  void _handleCommentLike(CommentModel comment) {
    setState(() {
      final index = _comments.indexWhere((c) => c.id == comment.id);
      if (index != -1) {
        if (_comments[index].isLiked) {
          _comments[index] = _comments[index].copyWith(
            isLiked: false,
            likes: _comments[index].likes - 1,
          );
        } else {
          _comments[index] = _comments[index].copyWith(
            isLiked: true,
            likes: _comments[index].likes + 1,
          );
        }
      }
    });
  }

  void _handleSubmitComment() {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    if (_commentController.text.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论不能超过200字')),
      );
      return;
    }

    final newComment = CommentModel(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      user: const PostUser(
        name: '我',
        avatar: 'https://picsum.photos/100/100?random=100',
        level: 1,
      ),
      content: _commentController.text.trim(),
      time: '刚刚',
      likes: 0,
    );

    setState(() {
      _comments.insert(0, newComment);
      _post.comments++;
    });

    widget.onAddComment(_post.id, newComment);
    _commentController.clear();
    FocusScope.of(context).unfocus();

    // 滚动到顶部（因为新评论在顶部）
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0D),
      body: Stack(
        children: [
          Column(
            children: [
              // 顶部导航栏
              _buildTopNavBar(),
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(),
                      const SizedBox(height: 8),
                      _buildStockTags(),
                      const SizedBox(height: 8),
                      _buildPostContent(),
                      const SizedBox(height: 16),
                      _buildHeartbreakSlider(),
                      if (_post.image != null) ...[
                        const SizedBox(height: 16),
                        _buildPositionScreenshot(),
                      ],
                      const SizedBox(height: 24),
                      _buildDivider(),
                      _buildCommentsHeader(),
                      const SizedBox(height: 16),
                      _buildCommentsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 浮动"抱抱"按钮
          _buildHugButton(),
          // 底部输入栏
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F0D).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: widget.onBack,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  '动态详情',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享功能开发中...')),
                  );
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF06E076).withOpacity(0.2),
                      width: 2,
                    ),
                    image: (_post.user.avatar.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(_post.user.avatar),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (_post.user.avatar.isEmpty)
                      ? Icon(Icons.person, color: Colors.grey, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _post.isAnonymous ? '匿名用户' : _post.user.name,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_post.time}${_post.location != null ? ' · ${_post.location}' : ''}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '关注',
              style: AppTextStyles.bodyBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTags() {
    // 从tags中提取股票标签（以$开头的）和其他标签
    final stockTags = _post.tags.where((tag) => tag.startsWith('\$')).toList();
    final otherTags = _post.tags.where((tag) => !tag.startsWith('\$')).toList();

    if (stockTags.isEmpty && otherTags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...stockTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF06E076).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF06E076).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_down,
                      size: 14,
                      color: Color(0xFF06E076),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: AppTextStyles.caption.copyWith(
                        color: Color(0xFF06E076),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
          ...otherTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        _post.content,
        style: AppTextStyles.sectionTitle.copyWith(
          height: 1.6,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHeartbreakSlider() {
    // 计算心碎指数（基于亏损金额，0-100%）
    final heartbreakLevel = (_post.amount.abs() / 10000 * 100).clamp(0.0, 100.0).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '当前心碎指数',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$heartbreakLevel%',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Color(0xFF06E076),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: heartbreakLevel / 100,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06E076)),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '指数越高，亏得越惨',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionScreenshot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: 实现图片查看功能
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (_post.image != null && _post.image!.isNotEmpty)
                  ? Image.network(
                      _post.image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey.withOpacity(0.2),
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.withOpacity(0.2),
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '持仓凭证',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildCommentsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: '亏友评论 ',
              style: AppTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '${_post.comments}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '最热',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFF06E076),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '最新',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTag(String mood) {
    final moodConfig = {
      'mild': {'label': '微痛', 'icon': Icons.favorite, 'color': Colors.pink},
      'heavy': {'label': '大出血', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
      'bankrupt': {'label': '原地破产', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
      'soul': {'label': '灵魂出窍', 'icon': Icons.water_drop, 'color': Colors.blue},
    };

    final config = moodConfig[mood] ?? moodConfig['soul']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (config['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 14,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 6),
          Text(
            config['label'] as String,
            style: AppTextStyles.captionBold.copyWith(
              color: config['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInteractionButton(
          icon: Icons.favorite,
          label: '点赞',
          count: _post.likes,
          isActive: _post.isLiked,
          onTap: _handleLike,
          activeColor: Colors.redAccent,
        ),
        _buildInteractionButton(
          icon: Icons.favorite_border,
          label: '心碎',
          count: 0,
          isActive: _post.isHeartbroken,
          onTap: _handleHeartbreak,
          activeColor: Colors.purpleAccent,
        ),
        _buildInteractionButton(
          icon: Icons.chat_bubble_outline,
          label: '评论',
          count: _post.comments,
          isActive: false,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          },
        ),
        _buildInteractionButton(
          icon: Icons.share_outlined,
          label: '分享',
          count: 0,
          isActive: false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('分享功能开发中...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = isActive
        ? (activeColor ?? const Color(0xFF2BEE6C))
        : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: AppTextStyles.labelBold.copyWith(
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 48,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '还没有评论，快来抢沙发吧！',
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _comments.map((comment) => _buildCommentItem(comment)).toList(),
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    // 从评论内容中提取标签（以#开头的）
    final tagMatches = RegExp(r'#\w+').allMatches(comment.content);
    final tags = tagMatches.map((m) => m.group(0)!).toList();
    final contentWithoutTags = comment.content.replaceAll(RegExp(r'#\w+'), '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: (comment.user.avatar.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(comment.user.avatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (comment.user.avatar.isEmpty)
                ? Icon(Icons.person, color: Colors.grey, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.user.name,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.thumb_up,
                          size: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likes.toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contentWithoutTags,
                  style: AppTextStyles.body.copyWith(
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.label.copyWith(
                            color: Color(0xFF06E076),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHugButton() {
    return Positioned(
      bottom: 100,
      right: 24,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已发送抱抱！'),
              backgroundColor: Color(0xFF06E076),
            ),
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF06E076),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06E076).withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.volunteer_activism,
                size: 28,
                color: Colors.black,
              ),
              SizedBox(height: 2),
              Text(
                '抱抱',
                style: AppTextStyles.labelBold.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F0D).withOpacity(0.95),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              hintText: '安慰一下这位亏友...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (_) => _handleSubmitComment(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.white.withOpacity(0.4),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      onPressed: () {},
                    ),
                    if (_post.comments > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06E076),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _post.comments > 99 ? '99+' : _post.comments.toString(),
                            style: AppTextStyles.labelBold.copyWith(
                              fontSize: 8,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
