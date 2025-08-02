import 'package:flutter/material.dart';

class ProjectFilter extends StatelessWidget {
  final String selectedLanguage;
  final String selectedSort;
  final Function(String) onLanguageChanged;
  final Function(String) onSortChanged;

  const ProjectFilter({
    super.key,
    required this.selectedLanguage,
    required this.selectedSort,
    required this.onLanguageChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 语言过滤器
        Expanded(
          child: _buildFilterDropdown(
            value: selectedLanguage,
            items: const [
              '全部',
              'Dart',
              'JavaScript',
              'TypeScript',
              'Python',
              'Java',
              'C++',
              'C#',
              'Go',
              'Rust',
              'Swift',
              'Kotlin',
              'PHP',
              'Ruby',
              'HTML',
              'CSS',
            ],
            onChanged: onLanguageChanged,
            label: '语言',
          ),
        ),
        const SizedBox(width: 12),
        // 排序方式
        Expanded(
          child: _buildFilterDropdown(
            value: selectedSort,
            items: const [
              '最近更新',
              '名称',
              '星标数',
              '复刻数',
              '创建时间',
            ],
            onChanged: onSortChanged,
            label: '排序',
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
                item,
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
} 