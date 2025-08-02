import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity_list.dart';
import '../widgets/optimized_dashboard.dart';
import '../../ai_assistant/pages/ai_assistant_page.dart';
import '../../projects/pages/project_center_page.dart';
import '../../papers/pages/paper_library_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 加载仪表板数据
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      // TODO: 处理错误
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 打开设置页面
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProjectsPage();
      case 2:
        return _buildPapersPage();
      case 3:
        return _buildNotesPage();
      case 4:
        return _buildAIAssistantPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return const OptimizedDashboard();
  }

  Widget _buildWelcomeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '欢迎回来！',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今天是个适合专注工作的好日子',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.code,
                    label: '活跃项目',
                    value: '3',
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.article,
                    label: '待读论文',
                    value: '12',
                    color: AppTheme.accentColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.event,
                    label: '今日会议',
                    value: '2',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            QuickActionButton(
              icon: Icons.code,
              label: '开始编码',
              color: AppTheme.primaryColor,
              onTap: () {
                // TODO: 打开项目选择
              },
            ),
            QuickActionButton(
              icon: Icons.article,
              label: '阅读论文',
              color: AppTheme.accentColor,
              onTap: () {
                // TODO: 打开论文列表
              },
            ),
            QuickActionButton(
              icon: Icons.edit_note,
              label: '记录想法',
              color: AppTheme.successColor,
              onTap: () {
                // TODO: 打开笔记编辑器
              },
            ),
            QuickActionButton(
              icon: Icons.smart_toy,
              label: 'AI助手',
              color: AppTheme.warningColor,
              onTap: () {
                // TODO: 打开AI助手
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '最近活动',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
        const RecentActivityList(),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '项目统计',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          childAspectRatio: 1.2,
          children: [
            DashboardCard(
              title: '代码提交',
              value: '24',
              subtitle: '本周提交次数',
              icon: Icons.commit,
              color: AppTheme.primaryColor,
            ),
            DashboardCard(
              title: '论文阅读',
              value: '8',
              subtitle: '本月阅读数量',
              icon: Icons.book,
              color: AppTheme.accentColor,
            ),
            DashboardCard(
              title: '笔记数量',
              value: '156',
              subtitle: '总笔记数量',
              icon: Icons.note,
              color: AppTheme.successColor,
            ),
            DashboardCard(
              title: '会议记录',
              value: '12',
              subtitle: '本月会议数量',
              icon: Icons.video_call,
              color: AppTheme.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectsPage() {
    return const ProjectCenterPage();
  }

  Widget _buildPapersPage() {
    return const PaperLibraryPage();
  }

  Widget _buildNotesPage() {
    return const Center(
      child: Text('笔记页面 - 开发中'),
    );
  }

  Widget _buildAIAssistantPage() {
    return const AIAssistantPage();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: '仪表板',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.code),
          label: '项目',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article),
          label: '论文',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: '笔记',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'AI助手',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          _showQuickActionDialog();
        },
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox.shrink();
  }

  void _showQuickActionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionItem(
                    icon: Icons.add_task,
                    label: '新建任务',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: 创建新任务
                    },
                  ),
                ),
                Expanded(
                  child: _buildQuickActionItem(
                    icon: Icons.note_add,
                    label: '新建笔记',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: 创建新笔记
                    },
                  ),
                ),
                Expanded(
                  child: _buildQuickActionItem(
                    icon: Icons.video_call,
                    label: '开始会议',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: 开始会议
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
} 