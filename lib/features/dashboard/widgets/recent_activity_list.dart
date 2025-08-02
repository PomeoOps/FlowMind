import 'package:flutter/material.dart';
import '../../../presentation/themes/app_theme.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟数据
    final activities = [
      ActivityItem(
        icon: Icons.commit,
        title: '提交代码到 FlowMind 项目',
        subtitle: '修复了GitHub认证问题',
        time: '2小时前',
        color: AppTheme.primaryColor,
      ),
      ActivityItem(
        icon: Icons.article,
        title: '阅读论文：深度学习在自然语言处理中的应用',
        subtitle: '标记为已读',
        time: '4小时前',
        color: AppTheme.accentColor,
      ),
      ActivityItem(
        icon: Icons.note,
        title: '创建笔记：项目架构设计思路',
        subtitle: '新增了500字内容',
        time: '6小时前',
        color: AppTheme.successColor,
      ),
      ActivityItem(
        icon: Icons.video_call,
        title: '参加团队会议：项目进度讨论',
        subtitle: '会议时长：45分钟',
        time: '昨天',
        color: AppTheme.warningColor,
      ),
      ActivityItem(
        icon: Icons.smart_toy,
        title: '使用AI助手分析代码性能',
        subtitle: '生成了优化建议',
        time: '昨天',
        color: AppTheme.errorColor,
      ),
    ];

    return Column(
      children: activities.map((activity) => _buildActivityItem(activity)).toList(),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            activity.icon,
            color: activity.color,
            size: 20,
          ),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              activity.subtitle,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              activity.time,
              style: TextStyle(
                color: AppTheme.textHintColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textHintColor,
          size: 16,
        ),
        onTap: () {
          // TODO: 处理活动项点击
        },
      ),
    );
  }
}

class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
} 