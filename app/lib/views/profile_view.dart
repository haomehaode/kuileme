import 'package:flutter/material.dart';
import '../app_tab.dart';
import '../theme/text_styles.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.onNavigate,
    required this.lossPostCount,
    required this.recordDays,
    required this.recoveryBalance,
    this.userLevel,
    this.onNotificationTap,
    this.onRecoveryTap,
    this.onMedalWallTap,
    this.onMyDiaryTap,
    this.onMyActivityTap,
    this.onSettingsTap,
  });

  final void Function(AppTab tab) onNavigate;
  final int lossPostCount;
  final int recordDays;
  final double recoveryBalance;
  final int? userLevel;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onRecoveryTap;
  final VoidCallback? onMedalWallTap;
  final VoidCallback? onMyDiaryTap;
  final VoidCallback? onMyActivityTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.grey),
          onPressed: onSettingsTap,
        ),
        title: Text(
          '个人中心',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: onNotificationTap,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildAnnualReport(),
            const SizedBox(height: 24),
            _buildGridMenus(),
            const SizedBox(height: 24),
            _buildMedals(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2BEE6C), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/200/200?random=100',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2BEE6C),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF050809), width: 2),
                ),
                child: Text(
                  'Lv.${userLevel ?? 1}',
                  style: AppTextStyles.labelBold.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '资深韭皇',
              style: AppTextStyles.pageTitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.verified, color: Color(0xFF2BEE6C), size: 24),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'ID: 9527 | 亏损等级: 极度深寒',
          style: AppTextStyles.caption.copyWith(
            color: Color(0xFF2BEE6C),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '"只要我不卖，我就没亏。"',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            side: const BorderSide(color: Colors.white10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            '编辑资料',
            style: AppTextStyles.captionBold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '记录天数',
            value: '$recordDays',
            icon: Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: '亏损动态',
            value: '$lossPostCount',
            icon: Icons.forum,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: '回血金',
            value: '¥${recoveryBalance.toStringAsFixed(2)}',
            icon: Icons.volunteer_activism,
            highlight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualReport() {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/800/400?random=200'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2023年度亏损报告',
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '回顾你这一年跌宕起伏的韭菜生涯',
              style: AppTextStyles.captionBold.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BEE6C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '立即查看',
                style: AppTextStyles.captionBold.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMenus() {
    final menus = [
      {'label': '我的日记', 'sub': '记录心碎瞬间', 'icon': Icons.book, 'onTap': () {}},
      {
        'label': '我的动态',
        'sub': '围观与互勉',
        'icon': Icons.history_edu,
        'onTap': () {},
      },
      {
        'label': '回血中心',
        'sub': '积分兑换好礼',
        'icon': Icons.payments,
        'onTap': onRecoveryTap,
      },
      {
        'label': '勋章墙',
        'sub': '已解锁 12 枚',
        'icon': Icons.stars,
        'onTap': onMedalWallTap,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final menu = menus[index];
        return _MenuCard(
          label: menu['label'] as String,
          subtitle: menu['sub'] as String,
          icon: menu['icon'] as IconData,
          onTap: menu['onTap'] as VoidCallback?,
        );
      },
    );
  }

  Widget _buildMedals() {
    final medals = [
      {'label': '资深嫩韭', 'icon': Icons.eco, 'active': true},
      {'label': '抄底失败', 'icon': Icons.trending_down, 'active': true},
      {'label': '钻石手(碎)', 'icon': Icons.diamond, 'active': true, 'glow': true},
      {'label': '百倍梦碎', 'icon': Icons.rocket_launch, 'active': false},
      {'label': '反向指标', 'icon': Icons.psychology, 'active': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '我的勋章',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '查看全部',
              style: AppTextStyles.captionBold.copyWith(
                color: Color(0xFF2BEE6C),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: medals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final medal = medals[index];
              final isActive = medal['active'] as bool;
              final hasGlow = medal['glow'] as bool? ?? false;
              return _MedalItem(
                label: medal['label'] as String,
                icon: medal['icon'] as IconData,
                isActive: isActive,
                hasGlow: hasGlow,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.pageTitle.copyWith(
              color: highlight ? const Color(0xFF2BEE6C) : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: const Color(0xFF2BEE6C)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelBold.copyWith(
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2BEE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2BEE6C), size: 24),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyBold.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelBold.copyWith(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _MedalItem extends StatelessWidget {
  const _MedalItem({
    required this.label,
    required this.icon,
    required this.isActive,
    this.hasGlow = false,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool hasGlow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? const Color(0xFF2BEE6C).withOpacity(0.1)
                    : const Color(0xFF111318),
            border: Border.all(
              color:
                  isActive
                      ? const Color(0xFF2BEE6C).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
            ),
            boxShadow:
                hasGlow
                    ? [
                      BoxShadow(
                        color: const Color(0xFF2BEE6C).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            icon,
            size: 32,
            color: isActive ? const Color(0xFF2BEE6C) : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelBold.copyWith(
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ],
    );
  }
}
