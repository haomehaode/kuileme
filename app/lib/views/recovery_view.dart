import 'package:flutter/material.dart';
import '../theme/text_styles.dart';

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'name': '闪电速贷',
        'sub': '最高3万 | 1分钟审核',
        'icon': Icons.bolt,
        'tags': ['审核快', '无视黑名单'],
      },
      {
        'name': '回血金库',
        'sub': '日利率 0.02% 起',
        'icon': Icons.account_balance_wallet,
        'tags': ['利息低', '大额专享'],
      },
      {
        'name': '紧急救助金',
        'sub': '不看征信 | 全天候审核',
        'icon': Icons.health_and_safety,
        'tags': ['门槛低', '身份证即贷'],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0a0f0b),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: onBack,
        ),
        title: Text(
          '紧急救助站',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildLoanAmount(),
            const SizedBox(height: 32),
            _buildPlanList(plans),
            const SizedBox(height: 32),
            _buildWarningInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0a0f0b),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BEE6C),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF2BEE6C).withOpacity(0.3),
            ),
            child: Text(
              '立即申请回血',
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanAmount() {
    return Column(
      children: [
        Text(
          '亏友专属额度 (元)',
          style: AppTextStyles.bodyBold.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '200,000',
          style: AppTextStyles.displayNumberLarge.copyWith(
            color: Color(0xFF2BEE6C),
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2BEE6C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFF2BEE6C).withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user,
                size: 14,
                color: Color(0xFF2BEE6C),
              ),
              SizedBox(width: 6),
              Text(
                '急速审核 · 凭亏损截图提额',
                style: AppTextStyles.labelBold.copyWith(
                  color: Color(0xFF2BEE6C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanList(List<Map<String, dynamic>> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BEE6C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '精选回血方案',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Text(
              '更多借款',
              style: AppTextStyles.bodyBold.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PlanCard(plan: plan),
            )),
      ],
    );
  }

  Widget _buildWarningInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '理性消费 拒绝盲目借贷',
                  style: AppTextStyles.bodyBold.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '本平台仅提供推荐服务，实际额度以机构审批为准。请根据个人还款能力合理安排，逾期将产生罚息并影响征信。',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final Map<String, dynamic> plan;

  @override
  Widget build(BuildContext context) {
    final tags = plan['tags'] as List<String>;
    final name = plan['name'] as String;
    final sub = plan['sub'] as String;
    final icon = plan['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121813),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2BEE6C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: 9,
                          color: Color(0xFF2BEE6C),
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: AppTextStyles.captionBold.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BEE6C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF2BEE6C).withOpacity(0.2),
                  ),
                  child: Text(
                    '去申请',
                    style: AppTextStyles.captionBold.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF2BEE6C),
            ),
          ),
        ],
      ),
    );
  }
}
