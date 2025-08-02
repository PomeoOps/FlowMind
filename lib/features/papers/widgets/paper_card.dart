import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/paper.dart';
import '../../../presentation/themes/app_theme.dart';

class PaperCard extends StatelessWidget {
  final Paper paper;
  final bool isCompact;

  const PaperCard({
    super.key,
    required this.paper,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildFullCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPaperDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildAuthors(),
              const SizedBox(height: 8),
              _buildAbstract(),
              const SizedBox(height: 12),
              _buildMetadata(),
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showPaperDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactHeader(),
              const SizedBox(height: 8),
              _buildCompactTitle(),
              const SizedBox(height: 4),
              _buildCompactAuthors(),
              const Spacer(),
              _buildCompactMetadata(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 论文图标
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.article,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        // 论文信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paper.itemType ?? '论文',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (paper.year?.isNotEmpty == true)
                Text(
                  paper.year!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ),
        // 阅读状态
        _buildReadingStatus(),
      ],
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      children: [
        Icon(
          Icons.article,
          color: AppTheme.primaryColor,
          size: 16,
        ),
        const Spacer(),
        _buildReadingStatus(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      paper.title ?? '无标题',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompactTitle() {
    return Text(
      paper.title ?? '无标题',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthors() {
    if (paper.authors?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Text(
      paper.authors!,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompactAuthors() {
    if (paper.authors?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Text(
      paper.authors!,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAbstract() {
    if (paper.abstract?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return Text(
      paper.abstract!,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (paper.journal?.isNotEmpty == true)
          _buildMetadataChip(
            icon: Icons.book,
            label: paper.journal!,
            color: Colors.blue,
          ),
        if (paper.doi?.isNotEmpty == true)
          _buildMetadataChip(
            icon: Icons.link,
            label: 'DOI',
            color: Colors.green,
          ),
        if (paper.keywords?.isNotEmpty == true)
          _buildMetadataChip(
            icon: Icons.label,
            label: '关键词',
            color: Colors.orange,
          ),
      ],
    );
  }

  Widget _buildCompactMetadata() {
    return Row(
      children: [
        if (paper.journal?.isNotEmpty == true) ...[
          Icon(
            Icons.book,
            size: 12,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              paper.journal!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (paper.year?.isNotEmpty == true) ...[
          const SizedBox(width: 8),
          Text(
            paper.year!,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStatus() {
    // 模拟阅读状态 - 实际应用中应该从数据库获取
    final isRead = false;
    final progress = 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        isRead ? '已读' : '未读',
        style: TextStyle(
          fontSize: 10,
          color: isRead ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // 添加时间
        if (paper.addedAt != null) ...[
          Icon(
            Icons.access_time,
            size: 12,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(paper.addedAt!),
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

  void _showPaperDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(paper.title ?? '论文详情'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (paper.authors?.isNotEmpty == true) ...[
                const Text('作者：'),
                Text(paper.authors!),
                const SizedBox(height: 16),
              ],
              if (paper.abstract?.isNotEmpty == true) ...[
                const Text('摘要：'),
                Text(paper.abstract!),
                const SizedBox(height: 16),
              ],
              if (paper.journal?.isNotEmpty == true) ...[
                const Text('期刊：'),
                Text(paper.journal!),
                const SizedBox(height: 16),
              ],
              if (paper.year?.isNotEmpty == true) ...[
                const Text('年份：'),
                Text(paper.year!),
                const SizedBox(height: 16),
              ],
              if (paper.doi?.isNotEmpty == true) ...[
                const Text('DOI：'),
                Text(paper.doi!),
                const SizedBox(height: 16),
              ],
              if (paper.url?.isNotEmpty == true) ...[
                const Text('链接：'),
                Text(paper.url!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (paper.url?.isNotEmpty == true)
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
    if (paper.url?.isNotEmpty == true) {
      launchUrl(Uri.parse(paper.url!));
    }
  }

  void _showMoreOptions() {
    // TODO: 实现更多选项菜单
  }
} 