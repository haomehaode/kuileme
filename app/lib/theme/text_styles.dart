import 'package:flutter/material.dart';

/// 统一的文本样式规范
class AppTextStyles {
  AppTextStyles._();

  // 超大标题 - 用于启动页品牌、特殊展示
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 超大数字 - 用于重要数字展示
  static const TextStyle displayNumber = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 超大数字 - 用于特殊展示
  static const TextStyle displayNumberLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 页面主标题
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 卡片/区块标题
  static const TextStyle cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 次要标题
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 正文 - 主要文本内容
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // 正文加粗
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 小文本 - 辅助信息
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // 小文本加粗
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  // 极小文本 - 标签、提示
  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // 极小文本加粗
  static const TextStyle labelBold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );

  // 超大标题（32） - 用于登录/注册页面主标题
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 副标题（16） - 用于次要标题
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 副标题（16）普通
  static const TextStyle subtitleNormal = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // 特殊：底部导航标签
  static const TextStyle bottomNavLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  // 特殊：超大数字（32）用于重要数值
  static const TextStyle numberLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // 特殊：数字（20）用于次要数值
  static const TextStyle number = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // AppBar 标题 - 统一所有页面标题样式
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
}
