import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_theme.dart';
import '../blocs/paper_bloc.dart';
import '../widgets/paper_card.dart';
import '../widgets/paper_filter.dart';
import '../widgets/reading_progress.dart';

class PaperLibraryPage extends StatefulWidget {
  const PaperLibraryPage({super.key});

  @override
  State<PaperLibraryPage> createState() => _PaperLibraryPageState();
}

class _PaperLibraryPageState extends State<PaperLibraryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedItemType = '全部';
  String _selectedCollection = '全部';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadPapers() {
    context.read<PaperBloc>().add(LoadPapers(
          searchQuery: _searchQuery,
          itemType: _selectedItemType == '全部' ? null : _selectedItemType,
          collection: _selectedCollection == '全部' ? null : _selectedCollection,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('论文库'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? '列表视图' : '网格视图',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPapers,
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
            Tab(text: '论文列表'),
            Tab(text: '阅读统计'),
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
                _buildPaperList(),
                _buildReadingStats(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPaperDialog,
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
              hintText: '搜索论文...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _loadPapers();
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
              _loadPapers();
            },
          ),
          const SizedBox(height: 12),
          // 过滤器
          Row(
            children: [
              Expanded(
                child: PaperFilter(
                  selectedItemType: _selectedItemType,
                  selectedCollection: _selectedCollection,
                  onItemTypeChanged: (itemType) {
                    setState(() => _selectedItemType = itemType);
                    _loadPapers();
                  },
                  onCollectionChanged: (collection) {
                    setState(() => _selectedCollection = collection);
                    _loadPapers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaperList() {
    return BlocBuilder<PaperBloc, PaperState>(
      builder: (context, state) {
        if (state is PaperLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaperError) {
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
                  onPressed: _loadPapers,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        } else if (state is PaperLoaded) {
          if (state.papers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无论文',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右上角按钮添加论文',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadPapers(),
            child: _isGridView ? _buildGridView(state.papers) : _buildListView(state.papers),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildListView(papers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PaperCard(paper: paper),
        );
      },
    );
  }

  Widget _buildGridView(papers) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return PaperCard(paper: paper, isCompact: true);
      },
    );
  }

  Widget _buildReadingStats() {
    return BlocBuilder<PaperBloc, PaperState>(
      builder: (context, state) {
        if (state is PaperLoaded && state.papers.isNotEmpty) {
          return const ReadingProgress();
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
        title: const Text('论文库设置'),
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

  void _showAddPaperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加论文'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('添加论文功能开发中...'),
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