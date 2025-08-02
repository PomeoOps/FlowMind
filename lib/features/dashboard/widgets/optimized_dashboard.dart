import 'package:flutter/material.dart';
import '../../../presentation/themes/app_theme.dart';
import 'dashboard_card.dart';
import 'quick_action_button.dart';
import 'recent_activity_list.dart';

class OptimizedDashboard extends StatefulWidget {
  const OptimizedDashboard({super.key});

  @override
  State<OptimizedDashboard> createState() => _OptimizedDashboardState();
}

class _OptimizedDashboardState extends State<OptimizedDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'FlowMind',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.primaryLightColor.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: 实现通知功能
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // TODO: 实现设置功能
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildStatisticsSection(),
                const SizedBox(height: 24),
                _buildQuickActionsSection(),
                const SizedBox(height: 24),
                _buildRecentActivitiesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLightColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting，开发者！',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '准备好开始今天的工作了吗？',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今日概览',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: '活跃项目',
              value: '12',
              subtitle: '本周新增 3 个',
              icon: Icons.folder_outlined,
              color: AppTheme.primaryColor,
            ),
            DashboardCard(
              title: '待读论文',
              value: '8',
              subtitle: '需要总结 2 篇',
              icon: Icons.article_outlined,
              color: AppTheme.accentColor,
            ),
            DashboardCard(
              title: '今日笔记',
              value: '5',
              subtitle: '已同步到思源',
              icon: Icons.note_outlined,
              color: AppTheme.accentColor,
            ),
            DashboardCard(
              title: '会议安排',
              value: '2',
              subtitle: '下午 3 点开始',
              icon: Icons.video_call_outlined,
              color: AppTheme.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              QuickActionButton(
                icon: Icons.add,
                label: '新建项目',
                color: AppTheme.primaryColor,
                onTap: () {
                  // TODO: 实现新建项目
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.search,
                label: '搜索论文',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: 实现搜索论文
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.edit_note,
                label: '写笔记',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: 实现写笔记
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.smart_toy,
                label: 'AI助手',
                color: AppTheme.successColor,
                onTap: () {
                  // TODO: 打开AI助手
                },
              ),
              const SizedBox(width: 12),
              QuickActionButton(
                icon: Icons.video_call,
                label: '加入会议',
                color: AppTheme.warningColor,
                onTap: () {
                  // TODO: 实现加入会议
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近活动',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 查看所有活动
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const RecentActivityList(),
        ),
      ],
    );
  }
} 