import 'package:flutter/material.dart';

class PaperFilter extends StatelessWidget {
  final String selectedItemType;
  final String selectedCollection;
  final Function(String) onItemTypeChanged;
  final Function(String) onCollectionChanged;

  const PaperFilter({
    super.key,
    required this.selectedItemType,
    required this.selectedCollection,
    required this.onItemTypeChanged,
    required this.onCollectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 论文类型过滤器
        Expanded(
          child: _buildFilterDropdown(
            value: selectedItemType,
            items: const [
              '全部',
              'journalArticle',
              'conferencePaper',
              'book',
              'bookSection',
              'thesis',
              'report',
              'webpage',
              'document',
            ],
            onChanged: onItemTypeChanged,
            label: '类型',
          ),
        ),
        const SizedBox(width: 12),
        // 收藏夹过滤器
        Expanded(
          child: _buildFilterDropdown(
            value: selectedCollection,
            items: const [
              '全部',
              '我的收藏',
              '最近添加',
              '未读论文',
              '已读论文',
            ],
            onChanged: onCollectionChanged,
            label: '收藏夹',
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          dropdownColor: Colors.grey[800],
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                _getDisplayName(item),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _getDisplayName(String item) {
    final displayNames = {
      'journalArticle': '期刊论文',
      'conferencePaper': '会议论文',
      'book': '书籍',
      'bookSection': '书籍章节',
      'thesis': '学位论文',
      'report': '报告',
      'webpage': '网页',
      'document': '文档',
      '我的收藏': '我的收藏',
      '最近添加': '最近添加',
      '未读论文': '未读论文',
      '已读论文': '已读论文',
    };

    return displayNames[item] ?? item;
  }
} 