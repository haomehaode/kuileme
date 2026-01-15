import 'package:flutter/material.dart';
import '../app_tab.dart';
import '../theme/text_styles.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onNavigate,
    this.onNotificationTap,
    this.onRecoveryLotteryTap,
    this.recoveryBalance = 0.0,
  });

  final void Function(AppTab tab) onNavigate;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onRecoveryLotteryTap;
  final double recoveryBalance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildMainStatsCard(),
          const SizedBox(height: 16),
          _buildRecoveryLotteryCard(),
          const SizedBox(height: 16),
          _buildRooftopIndex(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 16),
          _buildTrendingTopics(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '亏了么',
          style: AppTextStyles.cardTitle,
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日总亏损 (CNY)',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-12,480.00',
                style: AppTextStyles.numberLarge.copyWith(
                  color: Color(0xFF2BEE6C),
                ),
              ),
              SizedBox(width: 8),
              Chip(
                label: Text('-4.2%'),
                backgroundColor: Color(0x33F97373),
                labelStyle: AppTextStyles.labelBold.copyWith(
                  color: Color(0xFFF97373),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _StatItem(
                  title: '账户总回撤比',
                  value: '28.4%',
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatItem(
                  title: '近30日人均亏损',
                  value: '¥45,822',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryLotteryCard() {
    return GestureDetector(
      onTap: onRecoveryLotteryTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2BEE6C).withOpacity(0.2),
              const Color(0xFF2BEE6C).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF2BEE6C).withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2BEE6C).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景装饰
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2BEE6C).withOpacity(0.1),
                ),
              ),
            ),
            // 主要内容
            Row(
              children: [
                // 左侧图标和文字
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF2BEE6C).withOpacity(0.3),
                                  const Color(0xFF2BEE6C).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2BEE6C).withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volunteer_activism,
                              color: Color(0xFF2BEE6C),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '存钱抽奖回血',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '存钱即可抽奖\n有机会获得回血金',
                                  style: AppTextStyles.caption.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 回血金余额显示
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2BEE6C).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2BEE6C).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                size: 16,
                                color: Color(0xFF2BEE6C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '回血金余额: ¥${recoveryBalance.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyBold.copyWith(
                                color: Color(0xFF2BEE6C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧抽奖按钮
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2BEE6C),
                            const Color(0xFF2BEE6C).withOpacity(0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2BEE6C).withOpacity(0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2BEE6C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2BEE6C).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Color(0xFF2BEE6C),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '立即抽奖',
                            style: AppTextStyles.captionBold.copyWith(
                              color: Color(0xFF2BEE6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRooftopIndex() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.stairs_outlined,
            color: Colors.redAccent,
            size: 32,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '天台指数：极其拥挤',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '今日亏损已达上限，天台风大，关灯吃面，不要冲动。',
                  style: AppTextStyles.caption.copyWith(
                    color: Color(0xFFFCA5A5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.medical_services_outlined,
            title: '紧急救助站',
            subtitle: '凭截图快速提额',
            onTap: () => onNavigate(AppTab.recovery),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.analytics_outlined,
            title: '痛定思痛',
            subtitle: '大数据深度复盘',
            onTap: () => onNavigate(AppTab.analysis),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTopics() {
    const tags = ['深度套牢', '抄底失败', '机构受害者', 'ST自救指南'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '热门吐槽',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '查看全部',
              style: AppTextStyles.captionBold.copyWith(
                color: Color(0xFF2BEE6C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tag = tags[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111318),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  '#$tag',
                  style: AppTextStyles.caption,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelBold.copyWith(
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.number.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2BEE6C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2BEE6C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyBold,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

