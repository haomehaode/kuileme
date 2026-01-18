import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/text_styles.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({
    super.key,
    this.onBack,
    this.onSave,
    this.initialData,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final Map<String, dynamic>? initialData;

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _apiService = ApiService();
  
  bool _isLoading = false;
  String? _avatarUrl;
  File? _selectedImageFile;  // 本地选择的图片文件
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedTags = [];
  bool _hideTotalLoss = false;
  bool _hideMedals = false;
  
  // 可用的投资领域标签
  final List<String> _availableTags = [
    'A股',
    '美股',
    '数字货币',
    '港股',
    '期货',
    '基金',
    '债券',
    '外汇',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _nicknameController.text = data['nickname'] ?? '';
      _bioController.text = data['bio'] ?? '';
      _avatarUrl = data['avatar'];
      _selectedTags = List<String>.from(data['tags'] ?? []);
      _hideTotalLoss = (data['hide_total_loss'] ?? 0) == 1;
      _hideMedals = (data['hide_medals'] ?? 0) == 1;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('昵称不能为空'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalAvatarUrl = _avatarUrl;
      
      // 如果有新选择的图片，先上传
      if (_selectedImageFile != null) {
        finalAvatarUrl = await _apiService.uploadAvatar(_selectedImageFile!);
        setState(() {
          _avatarUrl = finalAvatarUrl;
          _selectedImageFile = null;  // 上传成功后清除本地文件引用
        });
      }
      
      // 更新用户信息
      await _apiService.updateUser(
        nickname: _nicknameController.text.trim(),
        avatar: finalAvatarUrl,
        bio: _bioController.text.trim(),
        tags: _selectedTags,
        hideTotalLoss: _hideTotalLoss,
        hideMedals: _hideMedals,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('资料保存成功'),
            backgroundColor: Color(0xFF00E677),
            duration: Duration(seconds: 2),
          ),
        );
        
        if (widget.onSave != null) {
          widget.onSave!();
        }
        
        if (widget.onBack != null) {
          widget.onBack!();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _pickAvatar() async {
    // 显示选择对话框
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('从相册选择', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('拍照', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (_avatarUrl != null || _selectedImageFile != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('删除头像', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _avatarUrl = null;
                    _selectedImageFile = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
    
    if (source == null) return;
    
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _avatarUrl = null;  // 清除旧的URL，使用新选择的文件
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050809),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildNavBar(),
            
            // 主内容
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // 头像区域
                    _buildAvatarSection(),
                    
                    const SizedBox(height: 32),
                    
                    // 表单区域
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 昵称
                          _buildLabel('昵称'),
                          const SizedBox(height: 6),
                          _buildGlassInput(
                            controller: _nicknameController,
                            hintText: '请输入昵称',
                            maxLength: 50,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 亏损宣言
                          _buildLabel('亏损宣言'),
                          const SizedBox(height: 6),
                          _buildGlassInput(
                            controller: _bioController,
                            hintText: '请输入你的亏损宣言',
                            maxLines: 2,
                            maxLength: 200,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 当前亏损等级（只读）
                          _buildLabel('当前亏损等级'),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '极度深寒',
                                  style: AppTextStyles.bodyBold.copyWith(
                                    color: const Color(0xFF00E677),
                                  ),
                                ),
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF00E677),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '该头衔根据历史账单自动计算，不可手动修改',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 常用投资领域
                          _buildLabel('常用投资领域'),
                          const SizedBox(height: 12),
                          _buildTagsSection(),
                          
                          const SizedBox(height: 24),
                          
                          // 隐私设置
                          _buildLabel('隐私设置'),
                          const SizedBox(height: 12),
                          _buildPrivacySettings(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: widget.onBack,
            child: Text(
              '取消',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            '编辑资料',
            style: AppTextStyles.sectionTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: Text(
              '保存',
              style: AppTextStyles.bodyBold.copyWith(
                color: _isLoading 
                    ? Colors.grey 
                    : const Color(0xFF00E677),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00E677),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E677).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                        )
                      : _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? Image.network(
                              _avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.withOpacity(0.2),
                              child: const Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.grey,
                              ),
                            ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E677),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'Lv.1',
                    style: AppTextStyles.labelBold.copyWith(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '点击更换头像',
          style: AppTextStyles.caption.copyWith(
            color: const Color(0xFF00E677).withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: const Color(0xFF00E677).withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.5),
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._availableTags.map((tag) {
          final isSelected = _selectedTags.contains(tag);
          return GestureDetector(
            onTap: () => _toggleTag(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00E677)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E677).withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                tag,
                style: AppTextStyles.body.copyWith(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: () {
            // TODO: 添加自定义标签功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('添加自定义标签功能开发中...')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPrivacySwitch(
            title: '隐藏总亏损额',
            value: _hideTotalLoss,
            onChanged: (value) {
              setState(() {
                _hideTotalLoss = value;
              });
            },
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
          _buildPrivacySwitch(
            title: '隐藏成就勋章',
            value: _hideMedals,
            onChanged: (value) {
              setState(() {
                _hideMedals = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00E677),
            activeTrackColor: const Color(0xFF00E677).withOpacity(0.5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
