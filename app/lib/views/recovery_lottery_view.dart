import 'dart:math';
import 'package:flutter/material.dart';
import '../models/recovery.dart';
import '../theme/text_styles.dart';

class RecoveryLotteryView extends StatefulWidget {
  const RecoveryLotteryView({
    super.key,
    required this.onBack,
    required this.balance,
    required this.onBalanceChange,
    required this.onAddRecord,
  });

  final VoidCallback onBack;
  final double balance;
  final void Function(double) onBalanceChange;
  final void Function(RecoveryRecord) onAddRecord;

  @override
  State<RecoveryLotteryView> createState() => _RecoveryLotteryViewState();
}

class _RecoveryLotteryViewState extends State<RecoveryLotteryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isSpinning = false;
  double _rotationAngle = 0;

  final List<LotteryPrize> _prizes = const [
    LotteryPrize(
      id: 'thanks',
      name: '谢谢参与',
      amount: 0,
      probability: 0.5,
      color: Colors.grey,
    ),
    LotteryPrize(
      id: 'small',
      name: '小额回血',
      amount: 5,
      probability: 0.3,
      color: Colors.green,
    ),
    LotteryPrize(
      id: 'medium',
      name: '中额回血',
      amount: 20,
      probability: 0.15,
      color: Colors.blue,
    ),
    LotteryPrize(
      id: 'large',
      name: '大额回血',
      amount: 100,
      probability: 0.04,
      color: Colors.orange,
    ),
    LotteryPrize(
      id: 'super',
      name: '超级回血',
      amount: 500,
      probability: 0.009,
      color: Colors.purple,
    ),
    LotteryPrize(
      id: 'mega',
      name: '巨额回血',
      amount: 1000,
      probability: 0.001,
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  LotteryPrize _drawPrize() {
    final random = Random();
    final r = random.nextDouble();
    double cumulative = 0;

    for (final prize in _prizes) {
      cumulative += prize.probability;
      if (r <= cumulative) {
        return prize;
      }
    }
    return _prizes.first;
  }

  void _startLottery() {
    if (_isSpinning) return;
    if (widget.balance < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('余额不足，请先充值')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    // 扣除投入金额
    widget.onBalanceChange(widget.balance - 1);
    widget.onAddRecord(RecoveryRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: RecoveryRecordType.lotteryCost,
      amount: -1,
      description: '参与抽奖投入',
      createdAt: DateTime.now(),
    ));

    // 抽奖
    final prize = _drawPrize();

    // 计算旋转角度（随机多转几圈 + 固定到对应奖品位置）
    final baseRotation = 360 * 5; // 转5圈
    final prizeIndex = _prizes.indexWhere((p) => p.id == prize.id);
    final prizeAngle = (360 / _prizes.length) * prizeIndex;
    final targetAngle = baseRotation + (360 - prizeAngle);

    _animationController.reset();
    final animation = Tween<double>(
      begin: _rotationAngle,
      end: _rotationAngle + targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    animation.addListener(() {
      setState(() {
        _rotationAngle = animation.value % 360;
      });
    });

    _animationController.forward().then((_) {
      setState(() {
        _isSpinning = false;
      });

      if (prize.amount > 0) {
        // 中奖，增加余额
        widget.onBalanceChange(widget.balance + prize.amount);
        widget.onAddRecord(RecoveryRecord(
          id: '${DateTime.now().millisecondsSinceEpoch}_win',
          type: RecoveryRecordType.lotteryWin,
          amount: prize.amount,
          description: '抽中${prize.name}',
          createdAt: DateTime.now(),
        ));

        _showPrizeDialog(prize);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('很遗憾，这次没有中奖，再接再厉！')),
        );
      }
    });
  }

  void _showPrizeDialog(LotteryPrize prize) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111318),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '🎉 恭喜中奖！',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: prize.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: prize.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              prize.name,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¥${prize.amount.toStringAsFixed(2)}',
              style: AppTextStyles.numberLarge.copyWith(
                color: prize.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '回血金已自动到账',
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2BEE6C),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('继续抽奖'),
          ),
        ],
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
          '存钱抽奖回血',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF111318),
                  title: const Text(
                    '抽奖说明',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    '每次抽奖需投入1元\n中奖概率：\n• 谢谢参与：50%\n• 小额回血(5元)：30%\n• 中额回血(20元)：15%\n• 大额回血(100元)：4%\n• 超级回血(500元)：0.9%\n• 巨额回血(1000元)：0.1%',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('知道了'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPoolInfo(),
            const SizedBox(height: 32),
            _buildSlogan(),
            const SizedBox(height: 32),
            _buildLotteryWheel(),
            const SizedBox(height: 32),
            _buildActionButton(),
            const SizedBox(height: 32),
            _buildBalanceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'GRAND RECOVERY POOL',
            style: AppTextStyles.captionBold.copyWith(
              color: Colors.amber,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥10,000',
            style: AppTextStyles.displayNumber.copyWith(
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '今日已送出回血金：¥3,420',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlogan() {
    return Column(
      children: [
        Text(
          '股市绿了，这里是金色的',
          style: AppTextStyles.cardTitle.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '亏友们的最后一道防线',
          style: AppTextStyles.body.copyWith(
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildLotteryWheel() {
    return Column(
      children: [
        Text(
          '回血大转盘',
          style: AppTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '点击中心或下方按钮即可开始抽奖',
          style: AppTextStyles.caption.copyWith(
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _isSpinning ? null : _startLottery,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _rotationAngle * pi / 180,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: _prizes.map((p) => p.color).toList(),
                      stops: List.generate(
                        _prizes.length,
                        (i) => i / _prizes.length,
                      ),
                    ),
                  ),
                  child: CustomPaint(
                    painter: _WheelPainter(prizes: _prizes),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2BEE6C),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2BEE6C).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: _isSpinning ? null : _startLottery,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        elevation: 8,
      ),
      child: Text(
        _isSpinning ? '抽奖中...' : '投入1元 立即回血',
        style: AppTextStyles.sectionTitle.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111318),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            '账户余额',
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${widget.balance.toStringAsFixed(2)}',
            style: AppTextStyles.numberLarge.copyWith(
              color: Color(0xFF2BEE6C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 实现充值
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('充值功能开发中...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2BEE6C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '充值',
                    style: TextStyle(color: Color(0xFF2BEE6C)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 实现提现
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('提现功能开发中...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2BEE6C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '提现',
                    style: TextStyle(color: Color(0xFF2BEE6C)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<LotteryPrize> prizes;

  _WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angleStep = 2 * pi / prizes.length;

    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < prizes.length; i++) {
      final prize = prizes[i];
      final startAngle = i * angleStep - pi / 2;

      paint.color = prize.color.withOpacity(0.3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        angleStep,
        true,
        paint,
      );

      // 绘制文字
      final textAngle = startAngle + angleStep / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + cos(textAngle) * textRadius;
      final textY = center.dy + sin(textAngle) * textRadius;

      textPainter.text = TextSpan(
        text: prize.name,
        style: AppTextStyles.captionBold.copyWith(
          color: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
