import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_theme.dart';
import '../blocs/project_bloc.dart';
import '../widgets/project_card.dart';
import '../widgets/commit_chart.dart';
import '../widgets/language_stats.dart';
import '../widgets/project_filter.dart';

class ProjectCenterPage extends StatefulWidget {
  const ProjectCenterPage({super.key});

  @override
  State<ProjectCenterPage> createState() => _ProjectCenterPageState();
}

class _ProjectCenterPageState extends State<ProjectCenterPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLanguage = '全部';
  String _selectedSort = '最近更新';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    context.read<ProjectBloc>().add(LoadProjects(
          searchQuery: _searchQuery,
          language: _selectedLanguage == '全部' ? null : _selectedLanguage,
          sortBy: _selectedSort,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目中心'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '设置',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '项目列表'),
            Tab(text: '提交统计'),
            Tab(text: '语言分析'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProjectList(),
                _buildCommitStats(),
                _buildLanguageAnalysis(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 搜索栏
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '搜索项目...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _loadProjects();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _loadProjects();
            },
          ),
          const SizedBox(height: 12),
          // 过滤器
          Row(
            children: [
              Expanded(
                child: ProjectFilter(
                  selectedLanguage: _selectedLanguage,
                  selectedSort: _selectedSort,
                  onLanguageChanged: (language) {
                    setState(() => _selectedLanguage = language);
                    _loadProjects();
                  },
                  onSortChanged: (sort) {
                    setState(() => _selectedSort = sort);
                    _loadProjects();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProjectError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '加载失败',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProjects,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        } else if (state is ProjectLoaded) {
          if (state.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无项目',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右上角按钮添加项目',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProjects(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.projects.length,
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCard(project: project),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCommitStats() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoaded && state.projects.isNotEmpty) {
          return const CommitChart();
        }
        return const Center(
          child: Text('暂无数据'),
        );
      },
    );
  }

  Widget _buildLanguageAnalysis() {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoaded && state.projects.isNotEmpty) {
          return const LanguageStats();
        }
        return const Center(
          child: Text('暂无数据'),
        );
      },
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('项目设置'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('设置功能开发中...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加项目'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('添加项目功能开发中...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
} 