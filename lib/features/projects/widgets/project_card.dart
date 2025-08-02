import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/project.dart';
import '../../../presentation/themes/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showProjectDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildStats(),
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 项目图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.folder,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // 项目信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.owner != null)
                Text(
                  project.owner!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        // 私有/公开标识
        if (project.isPrivate == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '私有',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    if (project.description?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Text(
      project.description!,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        if (project.language?.isNotEmpty == true) ...[
          _buildStatItem(
            icon: Icons.circle,
            value: project.language!,
            color: _getLanguageColor(project.language!),
          ),
          const SizedBox(width: 16),
        ],
        if (project.stars != null)
          _buildStatItem(
            icon: Icons.star,
            value: _formatNumber(project.stars!),
            color: Colors.amber,
          ),
        if (project.stars != null) const SizedBox(width: 16),
        if (project.forks != null)
          _buildStatItem(
            icon: Icons.fork_right,
            value: _formatNumber(project.forks!),
            color: Colors.blue,
          ),
        if (project.forks != null) const SizedBox(width: 16),
        if (project.openIssues != null)
          _buildStatItem(
            icon: Icons.bug_report,
            value: _formatNumber(project.openIssues!),
            color: Colors.red,
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // 更新时间
        if (project.updatedAt != null) ...[
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(project.updatedAt!),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
        const Spacer(),
        // 操作按钮
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () => _openInBrowser(),
              tooltip: '在浏览器中打开',
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 16),
              onPressed: () => _showMoreOptions(),
              tooltip: '更多选项',
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  Color _getLanguageColor(String language) {
    final colors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow,
      'TypeScript': Colors.blue,
      'Python': Colors.green,
      'Java': Colors.orange,
      'C++': Colors.pink,
      'C#': Colors.purple,
      'Go': Colors.cyan,
      'Rust': Colors.orange,
      'Swift': Colors.orange,
      'Kotlin': Colors.purple,
      'PHP': Colors.purple,
      'Ruby': Colors.red,
      'HTML': Colors.orange,
      'CSS': Colors.blue,
    };

    return colors[language] ?? Colors.grey;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  void _showProjectDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name ?? '项目详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description?.isNotEmpty == true) ...[
              const Text('描述：'),
              Text(project.description!),
              const SizedBox(height: 16),
            ],
            if (project.language?.isNotEmpty == true) ...[
              const Text('主要语言：'),
              Text(project.language!),
              const SizedBox(height: 16),
            ],
            if (project.createdAt != null) ...[
              const Text('创建时间：'),
              Text(_formatDate(project.createdAt!)),
              const SizedBox(height: 16),
            ],
            if (project.htmlUrl?.isNotEmpty == true) ...[
              const Text('项目地址：'),
              Text(project.htmlUrl!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (project.htmlUrl?.isNotEmpty == true)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openInBrowser();
              },
              child: const Text('打开'),
            ),
        ],
      ),
    );
  }

  void _openInBrowser() {
    if (project.htmlUrl?.isNotEmpty == true) {
      launchUrl(Uri.parse(project.htmlUrl!));
    }
  }

  void _showMoreOptions() {
    // TODO: 实现更多选项菜单
  }
} 