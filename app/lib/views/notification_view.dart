import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../theme/text_styles.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({
    super.key,
    required this.onBack,
    required this.notifications,
    required this.onUpdateNotification,
    required this.onMarkAllRead,
    required this.onNotificationTap,
  });

  final VoidCallback onBack;
  final List<NotificationModel> notifications;
  final void Function(NotificationModel) onUpdateNotification;
  final VoidCallback onMarkAllRead;
  final void Function(NotificationModel) onNotificationTap;

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  NotificationType? _selectedType;

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

  List<NotificationModel> get _filteredNotifications {
    if (_selectedType == null) {
      return widget.notifications;
    }
    return widget.notifications
        .where((n) => n.type == _selectedType)
        .toList();
  }

  int get _unreadCount {
    return widget.notifications.where((n) => !n.isRead).length;
  }

  void _handleTabChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _selectedType = null;
          break;
        case 1:
          _selectedType = NotificationType.like;
          break;
        case 2:
          _selectedType = NotificationType.comment;
          break;
        case 3:
          _selectedType = NotificationType.system;
          break;
      }
    });
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
          '通知',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: widget.onMarkAllRead,
              child: Text(
                '全部已读',
                style: AppTextStyles.captionBold.copyWith(
                  color: Color(0xFF2BEE6C),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _NotificationItem(
                        notification: notification,
                        onTap: () {
                          widget.onNotificationTap(notification);
                          if (!notification.isRead) {
                            widget.onUpdateNotification(
                              notification.copyWith(isRead: true),
                            );
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
        onTap: _handleTabChange,
        indicatorColor: const Color(0xFF2BEE6C),
        labelColor: const Color(0xFF2BEE6C),
        unselectedLabelColor: Colors.grey,
        labelStyle: AppTextStyles.bodyBold,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '互动'),
          Tab(text: '评论'),
          Tab(text: '系统'),
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
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无通知',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '有新的互动时会在这里通知你',
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

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
      case NotificationType.reply:
        return Icons.chat_bubble;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.follow:
        return Icons.person_add;
    }
  }

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.redAccent;
      case NotificationType.comment:
      case NotificationType.reply:
        return const Color(0xFF2BEE6C);
      case NotificationType.system:
        return Colors.blueAccent;
      case NotificationType.follow:
        return Colors.purpleAccent;
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
          color: notification.isRead
              ? const Color(0xFF111318)
              : const Color(0xFF111318).withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.white.withOpacity(0.05)
                : _typeColor.withOpacity(0.3),
            width: notification.isRead ? 1 : 1.5,
          ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: notification.isRead
                              ? AppTextStyles.body
                              : AppTextStyles.bodyBold,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: AppTextStyles.caption.copyWith(
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (notification.fromUser != null) ...[
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundImage: (notification.fromUser!.avatar.isNotEmpty)
                    ? NetworkImage(notification.fromUser!.avatar)
                    : null,
                child: (notification.fromUser!.avatar.isEmpty)
                    ? Icon(Icons.person, color: Colors.grey, size: 20)
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
