import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.onBack,
    required this.onLogout,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: onBack,
        ),
        title: Text(
          '设置',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('账户设置'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: '修改昵称',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.image_outlined,
            title: '修改头像',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.edit_note,
            title: '修改签名',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: '修改密码',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('隐私设置'),
          _buildSettingItem(
            icon: Icons.visibility_outlined,
            title: '谁可以看我的日记',
            subtitle: '公开',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.search,
            title: '是否允许被搜索',
            subtitle: '开启',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: '是否允许收到通知',
            subtitle: '开启',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('其他设置'),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: '清除缓存',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于我们',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF111318),
                  title: const Text(
                    '关于亏了么',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    '亏了么 v1.0.0\n\n一款面向股票投资亏损用户的社交社区应用',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: '用户协议',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          _buildSettingItem(
            icon: Icons.feedback_outlined,
            title: '意见反馈',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF111318),
                  title: const Text(
                    '确认退出',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    '确定要退出登录吗？',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text('退出'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '退出登录',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: AppTextStyles.captionBold.copyWith(
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2BEE6C), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyBold,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
