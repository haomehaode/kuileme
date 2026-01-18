import 'package:flutter/material.dart';
import 'app_tab.dart';
import 'models/post.dart';
import 'models/notification.dart';
import 'views/home_view.dart';
import 'views/community_view.dart';
import 'views/post_loss_view.dart';
import 'views/community_post_view.dart';
import 'views/post_detail_view.dart';
import 'views/analysis_view.dart';
import 'views/bill_view.dart';
import 'views/bill_detail_view.dart';
import 'views/login_view.dart';
import 'views/reset_password_view.dart';
import 'views/register_view.dart';
import 'views/profile_view.dart';
import 'views/edit_profile_view.dart';
import 'views/splash_view.dart';
import 'views/recovery_view.dart';
import 'views/recovery_lottery_view.dart';
import 'views/recovery_center_view.dart';
import 'views/notification_view.dart';
import 'models/recovery.dart';
import 'models/gift.dart';
import 'models/medal.dart';
import 'views/medal_wall_view.dart';
import 'views/my_diary_view.dart';
import 'views/my_activity_view.dart';
import 'views/settings_view.dart';
import 'widgets/bottom_nav.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'theme/text_styles.dart';

void main() {
  runApp(const KueLeMaApp());
}

/// 顶层应用，负责路由与底部导航
class KueLeMaApp extends StatelessWidget {
  const KueLeMaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '亏了么',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2BEE6C),
          brightness: Brightness.dark,
          background: const Color(0xFF050809),
        ),
        scaffoldBackgroundColor: const Color(0xFF050809),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const _RootScaffold(),
    );
  }
}

/// 与 Web 版的 App.tsx 对应：维护当前 Tab 和路由栈
class _RootScaffold extends StatefulWidget {
  const _RootScaffold();

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  AppTab _activeTab = AppTab.home;
  final List<AppTab> _history = [AppTab.home];

  // API 服务
  final AuthService _authService = AuthService();
  ApiService? _apiService;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _showSplash = true;

  // 简单的全局状态：社区帖子列表 & 基础统计
  final List<PostModel> _posts = [];
  int _lossPostCount = 0;
  int _recordDays = 1;
  double _recoveryBalance = 0;
  int _points = 0; // 积分
  final List<NotificationModel> _notifications = [];
  final List<RecoveryRecord> _recoveryRecords = [];
  final List<ExchangeRecord> _exchangeRecords = [];
  final List<MedalModel> _medals = [];
  int _userLevel = 1;
  int _userExp = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  /// 初始化应用：检查登录状态并加载数据
  Future<void> _initializeApp() async {
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _apiService = await _authService.getApiService();
        await _loadInitialData();
      } else {
        // 未登录，清除所有数据
        setState(() {
          _posts.clear();
          _notifications.clear();
          _recoveryRecords.clear();
          _exchangeRecords.clear();
          _medals.clear();
          _lossPostCount = 0;
          _recordDays = 1;
          _recoveryBalance = 0;
          _points = 0;
          _userLevel = 1;
          _userExp = 0;
        });
      }
    } catch (e) {
      print('初始化失败: $e');
      // 出错时清除数据
      setState(() {
        _isLoggedIn = false;
        _posts.clear();
        _notifications.clear();
        _recoveryRecords.clear();
        _exchangeRecords.clear();
        _medals.clear();
        _lossPostCount = 0;
        _recordDays = 1;
        _recoveryBalance = 0;
        _points = 0;
        _userLevel = 1;
        _userExp = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// 加载初始数据
  Future<void> _loadInitialData() async {
    if (_apiService == null) return;
    
    try {
      // 分别处理每个 API 调用，避免一个失败影响其他
      // 加载帖子列表
      try {
        final posts = await _apiService!.getPosts();
        setState(() {
          _posts.clear();
          _posts.addAll(posts);
          _lossPostCount = _posts.length;
        });
      } catch (e) {
        print('加载帖子失败: $e');
      }
      
      // 加载成长汇总
      try {
        final growthData = await _apiService!.getGrowthSummary();
        setState(() {
          _userLevel = growthData['level'] as int? ?? 1;
          _userExp = growthData['exp'] as int? ?? 0;
          _points = growthData['points'] as int? ?? 0;
          _recoveryBalance = (growthData['recovery_balance'] as num?)?.toDouble() ?? 0.0;
        });
      } catch (e) {
        print('加载成长汇总失败: $e');
      }
      
      // 加载通知
      try {
        final notifications = await _apiService!.getNotifications();
        setState(() {
          _notifications.clear();
          _notifications.addAll(notifications);
        });
      } catch (e) {
        print('加载通知失败: $e');
      }
      
      // 加载勋章
      try {
        final medals = await _apiService!.getMedals();
        setState(() {
          _medals.clear();
          _medals.addAll(medals);
        });
      } catch (e) {
        print('加载勋章失败: $e');
      }
    } catch (e) {
      print('加载数据失败: $e');
    }
  }

  void _navigateTo(AppTab tab) {
    setState(() {
      _activeTab = tab;
      _history.add(tab);
    });
  }

  void _goBack() {
    setState(() {
      if (_history.length > 1) {
        _history.removeLast();
        _activeTab = _history.last;
      } else {
        _activeTab = AppTab.home;
      }
    });
  }

  Future<void> _handleNewPost(PostModel post) async {
    if (_apiService != null) {
      try {
        // 调用 API 创建帖子
        final createdPost = await _apiService!.createPost(
          content: post.content,
          amount: post.amount,
          mood: post.mood ?? '',
          tags: post.tags,
          isAnonymous: post.isAnonymous,
        );
        
        setState(() {
          _posts.insert(0, createdPost);
          _lossPostCount++;
        });
        
        // 刷新成长数据
        await _refreshGrowthData();
      } catch (e) {
        print('发布帖子失败: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e')),
        );
        return;
      }
    } else {
      // 未登录，使用本地状态
      setState(() {
        _posts.insert(0, post);
        _lossPostCount++;
        _recoveryBalance += 5;
        _points += 20;
        _addExp(50);
      });
    }
    // 发布成功后回到社区首页
    _navigateTo(AppTab.community);
  }
  
  /// 刷新成长数据
  Future<void> _refreshGrowthData() async {
    if (_apiService == null) return;
    try {
      final growthData = await _apiService!.getGrowthSummary();
      setState(() {
        _userLevel = growthData['level'] as int? ?? 1;
        _userExp = growthData['exp'] as int? ?? 0;
        _points = growthData['points'] as int? ?? 0;
        _recoveryBalance = (growthData['recovery_balance'] as num?)?.toDouble() ?? 0.0;
      });
    } catch (e) {
      print('刷新成长数据失败: $e');
    }
  }

  void _addExp(int exp) {
    setState(() {
      _userExp += exp;
      // 简单等级计算：每级需要 level * 1000 经验
      final requiredExp = _userLevel * 1000;
      if (_userExp >= requiredExp) {
        _userLevel++;
        _userExp = _userExp - requiredExp;
        // TODO: 显示升级提示（需要context，暂时注释）
      }
    });
  }


  void _handleUpdatePost(PostModel updatedPost) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    });
  }

  void _handleAddComment(String postId, CommentModel comment) {
    setState(() {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index].comments++;
      }
    });
  }

  void _navigateToPostDetail(BuildContext context, PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PostDetailView(
              post: post,
              onBack: () => Navigator.of(context).pop(),
              onUpdatePost: _handleUpdatePost,
              onAddComment: _handleAddComment,
            ),
      ),
    );
  }

  void _navigateToCommunityPost(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommunityPostView(
          onBack: () => Navigator.of(context).pop(),
          onPublish: (post) async {
            Navigator.of(context).pop();
            await _handleNewPost(post);
          },
        ),
      ),
    );
  }

  void _navigateToNotification(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NotificationView(
              onBack: () => Navigator.of(context).pop(),
              notifications: _notifications,
              onUpdateNotification: (notification) {
                setState(() {
                  final index = _notifications.indexWhere(
                    (n) => n.id == notification.id,
                  );
                  if (index != -1) {
                    _notifications[index] = notification;
                  }
                });
              },
              onMarkAllRead: () {
                setState(() {
                  for (var i = 0; i < _notifications.length; i++) {
                    _notifications[i] = _notifications[i].copyWith(
                      isRead: true,
                    );
                  }
                });
              },
              onNotificationTap: (notification) {
                // TODO: 根据通知类型跳转到对应页面
                if (notification.relatedId != null) {
                  final post = _posts.firstWhere(
                    (p) => p.id == notification.relatedId,
                    orElse: () => _posts.first,
                  );
                  _navigateToPostDetail(context, post);
                }
              },
            ),
      ),
    );
  }

  void _navigateToRecoveryLottery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => RecoveryLotteryView(
              onBack: () => Navigator.of(context).pop(),
              balance: _recoveryBalance,
              onBalanceChange: (newBalance) {
                setState(() {
                  _recoveryBalance = newBalance;
                });
              },
              onAddRecord: (record) {
                setState(() {
                  _recoveryRecords.insert(0, record);
                });
              },
            ),
      ),
    );
  }

  void _navigateToRecoveryCenter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => RecoveryCenterView(
              onBack: () => Navigator.of(context).pop(),
              points: _points,
              recoveryBalance: _recoveryBalance,
              onPointsChange: (newPoints) {
                setState(() {
                  _points = newPoints;
                });
              },
              onRecoveryChange: (newBalance) {
                setState(() {
                  _recoveryBalance = newBalance;
                });
              },
              onAddExchange: (record) {
                setState(() {
                  _exchangeRecords.insert(0, record);
                });
              },
            ),
      ),
    );
  }

  void _navigateToMedalWall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => MedalWallView(
              onBack: () => Navigator.of(context).pop(),
              medals: _medals,
              onMedalTap: (medal) {
                // 显示勋章详情
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        backgroundColor: const Color(0xFF111318),
                        title: Text(
                          medal.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              medal.icon,
                              size: 64,
                              color:
                                  medal.isUnlocked
                                      ? medal.rarityColor
                                      : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              medal.description,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '解锁条件：${medal.unlockCondition}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭'),
                          ),
                        ],
                      ),
                );
              },
            ),
      ),
    );
  }

  void _navigateToMyDiary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => MyDiaryView(
              onBack: () => Navigator.of(context).pop(),
              posts: _posts,
            ),
      ),
    );
  }

  void _navigateToMyActivity(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyActivityView(
          onBack: () => Navigator.of(context).pop(),
          onPostTap: (post) {
            // 跳转到帖子详情
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailView(
                  post: post,
                  onBack: () => Navigator.of(context).pop(),
                  onUpdatePost: (updatedPost) {
                    // 更新帖子
                    setState(() {
                      final index = _posts.indexWhere((p) => p.id == updatedPost.id);
                      if (index != -1) {
                        _posts[index] = updatedPost;
                      }
                    });
                  },
                  onAddComment: (postId, comment) {
                    // 添加评论
                    setState(() {
                      final index = _posts.indexWhere((p) => p.id == postId);
                      if (index != -1) {
                        _posts[index] = _posts[index].copyWith(
                          comments: _posts[index].comments + 1,
                        );
                      }
                    });
                  },
                ),
              ),
            );
          },
          apiService: _apiService,
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SettingsView(
              onBack: () => Navigator.of(context).pop(),
              onLogout: () async {
                Navigator.of(context).pop();
                // 退出登录
                await _authService.logout();
                // 清除状态
                setState(() {
                  _isLoggedIn = false;
                  _apiService = null;
                  _posts.clear();
                  _notifications.clear();
                  _recoveryRecords.clear();
                  _exchangeRecords.clear();
                  _medals.clear();
                  _lossPostCount = 0;
                  _recordDays = 1;
                  _recoveryBalance = 0;
                  _points = 0;
                  _userLevel = 1;
                  _userExp = 0;
                  _activeTab = AppTab.home;
                  _history.clear();
                  _history.add(AppTab.home);
                });
              },
            ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginView(
          onLoginSuccess: () async {
            Navigator.of(context).pop();
            // 重新初始化应用状态
            setState(() {
              _isLoading = true;
            });
            await _initializeApp();
          },
          onBack: () => Navigator.of(context).pop(),
          onNavigateToRegister: () {
            Navigator.of(context).pop();
            _navigateToRegister(context);
          },
          onNavigateToResetPassword: () {
            Navigator.of(context).pop();
            _navigateToResetPassword(context);
          },
        ),
      ),
    );
  }

  void _navigateToResetPassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResetPasswordView(
          onBack: () => Navigator.of(context).pop(),
          onNavigateToLogin: () {
            Navigator.of(context).pop();
            _navigateToLogin(context);
          },
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) async {
    // 获取当前用户信息
    Map<String, dynamic>? userData;
    if (_apiService != null) {
      try {
        userData = await _apiService!.getCurrentUser();
      } catch (e) {
        print('获取用户信息失败: $e');
      }
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileView(
          onBack: () => Navigator.of(context).pop(),
          onSave: () async {
            Navigator.of(context).pop();
            // 刷新用户数据
            if (_apiService != null) {
              try {
                await _apiService!.getCurrentUser();
                // 可以在这里更新UI状态
                setState(() {});
              } catch (e) {
                print('刷新用户信息失败: $e');
              }
            }
          },
          initialData: userData,
        ),
      ),
    );
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterView(
          onRegisterSuccess: () async {
            Navigator.of(context).pop();
            // 重新初始化应用状态
            setState(() {
              _isLoading = true;
            });
            await _initializeApp();
          },
          onBack: () => Navigator.of(context).pop(),
          onNavigateToLogin: () {
            Navigator.of(context).pop();
            _navigateToLogin(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 显示启动页
    if (_showSplash) {
      return SplashView(
        onAnimationComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    // 显示加载中
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 如果未登录，显示登录页面
    if (!_isLoggedIn) {
      return LoginView(
        onLoginSuccess: () async {
          // 重新初始化应用状态
          setState(() {
            _isLoading = true;
          });
          await _initializeApp();
        },
        onBack: null, // 登录页面不允许返回
        onNavigateToRegister: () {
          // 显示注册页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RegisterView(
                onRegisterSuccess: () async {
                  Navigator.of(context).pop();
                  // 重新初始化应用状态
                  setState(() {
                    _isLoading = true;
                  });
                  await _initializeApp();
                },
                onBack: () => Navigator.of(context).pop(),
                onNavigateToLogin: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
        onNavigateToResetPassword: () {
          // 显示重置密码页面
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResetPasswordView(
                onBack: () => Navigator.of(context).pop(),
                onNavigateToLogin: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      );
    }
    
    Widget body;
    switch (_activeTab) {
      case AppTab.home:
        body = HomeView(
          onNavigate: _navigateTo,
          onNotificationTap: () => _navigateToNotification(context),
          onRecoveryLotteryTap: () => _navigateToRecoveryLottery(context),
          recoveryBalance: _recoveryBalance,
        );
        break;
      case AppTab.community:
        body = CommunityView(
          posts: _posts,
          onPostTap: (post) => _navigateToPostDetail(context, post),
          onPostCreate: () => _navigateToCommunityPost(context),
        );
        break;
      case AppTab.post:
        body = PostLossView(onBack: _goBack, onPublish: _handleNewPost);
        break;
      case AppTab.analysis:
        body = AnalysisView(onBack: _goBack, posts: _posts);
        break;
      case AppTab.bill:
        body = BillView(
          posts: _posts,
          isLoggedIn: _isLoggedIn,
          onLoginRequest: () => _navigateToLogin(context),
          onPostTap: (post) {
            if (_apiService == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('请先登录'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BillDetailView(
                  post: post,
                  onBack: () => Navigator.of(context).pop(),
                  apiService: _apiService!,
                  onDelete: () {
                    // 删除帖子
                    setState(() {
                      _posts.removeWhere((p) => p.id == post.id);
                    });
                  },
                  onUpdate: (updatedPost) {
                    // 更新帖子
                    setState(() {
                      final index = _posts.indexWhere((p) => p.id == updatedPost.id);
                      if (index != -1) {
                        _posts[index] = updatedPost;
                      }
                    });
                  },
                ),
              ),
            );
          },
        );
        break;
      case AppTab.profile:
        body = ProfileView(
          onNavigate: _navigateTo,
          lossPostCount: _lossPostCount,
          recordDays: _recordDays,
          recoveryBalance: _recoveryBalance,
          userLevel: _userLevel,
          onNotificationTap: () => _navigateToNotification(context),
          onRecoveryTap: () => _navigateToRecoveryCenter(context),
          onMedalWallTap: () => _navigateToMedalWall(context),
          onMyDiaryTap: () => _navigateToMyDiary(context),
          onMyActivityTap: () => _navigateToMyActivity(context),
          onSettingsTap: () => _navigateToSettings(context),
          onEditProfile: () => _navigateToEditProfile(context),
        );
        break;
      case AppTab.recovery:
        body = RecoveryView(onBack: _goBack);
        break;
    }

    final showBottomNav =
        _activeTab != AppTab.post && _activeTab != AppTab.recovery;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (showBottomNav)
              BottomNav(activeTab: _activeTab, onTabChange: _navigateTo),
          ],
        ),
      ),
    );
  }
}
