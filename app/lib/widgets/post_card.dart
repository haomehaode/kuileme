import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/text_styles.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  final PostModel post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111318),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: (post.user.avatar.isNotEmpty)
                    ? NetworkImage(post.user.avatar)
                    : null,
                child: (post.user.avatar.isEmpty)
                    ? Icon(Icons.person, color: Colors.grey, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user.name,
                      style: AppTextStyles.bodyBold,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _metaText,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  '\$ ${post.tags.isNotEmpty ? post.tags.first : ''} (${post.percentage > 0 ? '+' : ''}${post.percentage.toStringAsFixed(2)}%)',
                  style: AppTextStyles.labelBold.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
              color: Color(0xFFe5e7eb),
            ),
          ),
          if (post.image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  (post.image!.isNotEmpty)
                      ? Image.network(
                          post.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey.withOpacity(0.2),
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.withOpacity(0.2),
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        '持仓截图 · 亏损 ${post.amount.abs().toStringAsFixed(0)}',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _iconText(Icons.chat_bubble_outline, post.comments.toString(),
                      colorScheme),
                  const SizedBox(width: 20),
                  _iconText(
                      Icons.favorite_border, post.likes.toString(), colorScheme,
                      highlight: true),
                  const SizedBox(width: 20),
                  _iconText(Icons.ios_share, '', colorScheme),
                ],
              ),
              Row(
                children: [
                  _chip('🍜 关灯吃面'),
                  const SizedBox(width: 8),
                  _chip('🛵 送外卖'),
                ],
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  String get _metaText {
    final parts = <String>[];
    parts.add(post.time);
    if (post.location != null && post.location!.isNotEmpty) {
      parts.add(post.location!);
    }
    if (post.user.device != null && post.user.device!.isNotEmpty) {
      parts.add(post.user.device!);
    }
    return parts.join(' · ');
  }

  Widget _iconText(
    IconData icon,
    String text,
    ColorScheme colorScheme, {
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight ? Colors.redAccent : colorScheme.outline,
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: highlight ? Colors.redAccent : colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF050509),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white70,
        ),
      ),
    );
  }
}

