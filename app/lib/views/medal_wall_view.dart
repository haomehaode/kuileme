import 'package:flutter/material.dart';
import '../models/medal.dart';
import '../theme/text_styles.dart';

class MedalWallView extends StatefulWidget {
  const MedalWallView({
    super.key,
    required this.onBack,
    required this.medals,
    required this.onMedalTap,
  });

  final VoidCallback onBack;
  final List<MedalModel> medals;
  final void Function(MedalModel) onMedalTap;

  @override
  State<MedalWallView> createState() => _MedalWallViewState();
}

class _MedalWallViewState extends State<MedalWallView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showUnlockedOnly = false;

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

  List<MedalModel> get _filteredMedals {
    var filtered = widget.medals;
    if (_showUnlockedOnly) {
      filtered = filtered.where((m) => m.isUnlocked).toList();
    }
    return filtered;
  }

  int get _unlockedCount {
    return widget.medals.where((m) => m.isUnlocked).length;
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
          '勋章墙',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showUnlockedOnly = !_showUnlockedOnly;
              });
            },
            child: Text(
              _showUnlockedOnly ? '显示全部' : '仅已解锁',
              style: AppTextStyles.captionBold.copyWith(
                color: Color(0xFF2BEE6C),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          _buildTabBar(),
          Expanded(
            child:
                _filteredMedals.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _filteredMedals.length,
                      itemBuilder: (context, index) {
                        return _MedalCard(
                          medal: _filteredMedals[index],
                          onTap:
                              () => widget.onMedalTap(_filteredMedals[index]),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2BEE6C).withOpacity(0.2),
            const Color(0xFF2BEE6C).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2BEE6C).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '已解锁',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_unlockedCount',
                style: AppTextStyles.pageTitle.copyWith(
                  color: Color(0xFF2BEE6C),
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          Column(
            children: [
              Text(
                '总勋章',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.medals.length}',
                style: AppTextStyles.pageTitle,
              ),
            ],
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
        indicatorColor: const Color(0xFF2BEE6C),
        labelColor: const Color(0xFF2BEE6C),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '普通'),
          Tab(text: '稀有'),
          Tab(text: '史诗'),
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
              Icons.stars_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无勋章',
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

class _MedalCard extends StatelessWidget {
  const _MedalCard({required this.medal, required this.onTap});

  final MedalModel medal;
  final VoidCallback onTap;

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
          border: Border.all(
            color:
                medal.isUnlocked
                    ? medal.rarityColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
            width: medal.isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    medal.isUnlocked
                        ? medal.rarityColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: medal.isUnlocked ? medal.rarityColor : Colors.grey,
                  width: 2,
                ),
                boxShadow:
                    medal.isUnlocked
                        ? [
                          BoxShadow(
                            color: medal.rarityColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Icon(
                medal.icon,
                size: 40,
                color: medal.isUnlocked ? medal.rarityColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              medal.name,
              style: AppTextStyles.bodyBold.copyWith(
                color: medal.isUnlocked ? Colors.white : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (!medal.isUnlocked && medal.target != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: medal.progressPercent,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  minHeight: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(medal.rarityColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${medal.progress ?? 0}/${medal.target}',
                style: AppTextStyles.label.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
