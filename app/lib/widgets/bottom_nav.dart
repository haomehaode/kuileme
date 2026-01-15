import 'package:flutter/material.dart';
import '../app_tab.dart';
import '../theme/text_styles.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  final AppTab activeTab;
  final void Function(AppTab tab) onTabChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xFF050809),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomItem(
              icon: Icons.home_outlined,
              label: '首页',
              selected: activeTab == AppTab.home,
              onTap: () => onTabChange(AppTab.home),
            ),
            _BottomItem(
              icon: Icons.bubble_chart_outlined,
              label: '亏友圈',
              selected: activeTab == AppTab.community,
              onTap: () => onTabChange(AppTab.community),
            ),
            GestureDetector(
              onTap: () => onTabChange(AppTab.post),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2BEE6C),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.add, color: Colors.black, size: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '发泄',
                    style: AppTextStyles.bottomNavLabel.copyWith(
                      color: Color(0xFF2BEE6C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _BottomItem(
              icon: Icons.receipt_long,
              label: '账单',
              selected: activeTab == AppTab.bill,
              onTap: () => onTabChange(AppTab.bill),
            ),
            _BottomItem(
              icon: Icons.person_outline,
              label: '我的',
              selected: activeTab == AppTab.profile,
              onTap: () => onTabChange(AppTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2BEE6C) : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bottomNavLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

