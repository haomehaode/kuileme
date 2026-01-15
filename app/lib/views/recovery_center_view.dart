import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../theme/text_styles.dart';

class RecoveryCenterView extends StatefulWidget {
  const RecoveryCenterView({
    super.key,
    required this.onBack,
    required this.points,
    required this.recoveryBalance,
    required this.onPointsChange,
    required this.onRecoveryChange,
    required this.onAddExchange,
  });

  final VoidCallback onBack;
  final int points;
  final double recoveryBalance;
  final void Function(int) onPointsChange;
  final void Function(double) onRecoveryChange;
  final void Function(ExchangeRecord) onAddExchange;

  @override
  State<RecoveryCenterView> createState() => _RecoveryCenterViewState();
}

class _RecoveryCenterViewState extends State<RecoveryCenterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GiftType? _selectedType;

  final List<GiftModel> _gifts = [
    const GiftModel(
      id: 'g1',
      name: '亏友专属T恤',
      description: '印有"只要我不卖，我就没亏"的经典T恤',
      imageUrl: 'https://picsum.photos/300/300?random=50',
      pointsRequired: 500,
      recoveryRequired: 0,
      type: GiftType.physical,
      stock: 100,
    ),
    const GiftModel(
      id: 'g2',
      name: '关灯吃面套餐券',
      description: '价值50元的外卖优惠券',
      imageUrl: 'https://picsum.photos/300/300?random=51',
      pointsRequired: 200,
      recoveryRequired: 0,
      type: GiftType.virtual,
    ),
    const GiftModel(
      id: 'g3',
      name: '回血金大礼包',
      description: '直接兑换100元回血金',
      imageUrl: 'https://picsum.photos/300/300?random=52',
      pointsRequired: 0,
      recoveryRequired: 80,
      type: GiftType.virtual,
    ),
    const GiftModel(
      id: 'g4',
      name: 'VIP会员月卡',
      description: '享受更多特权，查看详细数据',
      imageUrl: 'https://picsum.photos/300/300?random=53',
      pointsRequired: 1000,
      recoveryRequired: 0,
      type: GiftType.virtual,
      isLimited: true,
    ),
  ];

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

  List<GiftModel> get _filteredGifts {
    if (_selectedType == null) {
      return _gifts;
    }
    return _gifts.where((g) => g.type == _selectedType).toList();
  }

  void _handleExchange(GiftModel gift) {
    if (gift.pointsRequired > widget.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('积分不足，还需要${gift.pointsRequired - widget.points}积分')),
      );
      return;
    }

    if (gift.recoveryRequired > widget.recoveryBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('回血金不足，还需要${(gift.recoveryRequired - widget.recoveryBalance).toStringAsFixed(2)}元')),
      );
      return;
    }

    if (gift.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该礼品已售罄')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111318),
        title: const Text(
          '确认兑换',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gift.name,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            if (gift.pointsRequired > 0)
              Text(
                '消耗积分：${gift.pointsRequired}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (gift.recoveryRequired > 0)
              Text(
                '消耗回血金：¥${gift.recoveryRequired.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmExchange(gift);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BEE6C),
              foregroundColor: Colors.black,
            ),
            child: const Text('确认兑换'),
          ),
        ],
      ),
    );
  }

  void _confirmExchange(GiftModel gift) {
    widget.onPointsChange(widget.points - gift.pointsRequired);
    widget.onRecoveryChange(widget.recoveryBalance - gift.recoveryRequired);

    final record = ExchangeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      giftId: gift.id,
      giftName: gift.name,
      pointsUsed: gift.pointsRequired,
      recoveryUsed: gift.recoveryRequired,
      createdAt: DateTime.now(),
      shippingAddress: gift.type == GiftType.physical ? '待填写' : null,
    );

    widget.onAddExchange(record);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('兑换成功！${gift.type == GiftType.physical ? "请填写收货地址" : "已自动到账"}'),
        backgroundColor: const Color(0xFF2BEE6C),
      ),
    );
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
          '回血中心',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedType = null;
                  break;
                case 1:
                  _selectedType = GiftType.physical;
                  break;
                case 2:
                  _selectedType = GiftType.virtual;
                  break;
                case 3:
                  _selectedType = GiftType.limited;
                  break;
              }
            });
          },
          indicatorColor: const Color(0xFF2BEE6C),
          labelColor: const Color(0xFF2BEE6C),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '实物'),
            Tab(text: '虚拟'),
            Tab(text: '限时'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          Expanded(
            child: _filteredGifts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredGifts.length,
                    itemBuilder: (context, index) {
                      return _GiftCard(
                        gift: _filteredGifts[index],
                        onExchange: _handleExchange,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
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
        border: Border.all(
          color: const Color(0xFF2BEE6C).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '积分余额',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.points}',
                style: AppTextStyles.pageTitle.copyWith(
                  color: Color(0xFF2BEE6C),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          Column(
            children: [
              Text(
                '回血金余额',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '¥${widget.recoveryBalance.toStringAsFixed(2)}',
                style: AppTextStyles.pageTitle.copyWith(
                  color: Color(0xFF2BEE6C),
                ),
              ),
            ],
          ),
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
              Icons.card_giftcard_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无礼品',
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

class _GiftCard extends StatelessWidget {
  const _GiftCard({
    required this.gift,
    required this.onExchange,
  });

  final GiftModel gift;
  final void Function(GiftModel) onExchange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gift.isLimited
              ? Colors.orange.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  gift.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (gift.isLimited)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '限时',
                      style: AppTextStyles.labelBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.name,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  gift.description,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (gift.pointsRequired > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.stars,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${gift.pointsRequired}',
                                style: AppTextStyles.captionBold,
                              ),
                            ],
                          ),
                        if (gift.recoveryRequired > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.volunteer_activism,
                                size: 14,
                                color: Color(0xFF2BEE6C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '¥${gift.recoveryRequired.toStringAsFixed(0)}',
                                style: AppTextStyles.captionBold.copyWith(
                                  color: Color(0xFF2BEE6C),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => onExchange(gift),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2BEE6C),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '兑换',
                        style: AppTextStyles.captionBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
