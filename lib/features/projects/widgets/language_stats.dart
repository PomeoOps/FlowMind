import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/project_bloc.dart';

class LanguageStats extends StatelessWidget {
  const LanguageStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoaded) {
          return _buildLanguageStats(context, state.projects);
        }
        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildLanguageStats(BuildContext context, projects) {
    // 统计语言使用情况
    final languageStats = <String, int>{};
    for (final project in projects) {
      if (project.language?.isNotEmpty == true) {
        languageStats[project.language!] = (languageStats[project.language!] ?? 0) + 1;
      }
    }

    if (languageStats.isEmpty) {
      return const Center(
        child: Text('暂无语言数据'),
      );
    }

    // 转换为饼图数据
    final pieData = languageStats.entries.map((entry) {
      return PieChartSectionData(
        color: _getLanguageColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '编程语言分布',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 饼图
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: pieData,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 图例
              Expanded(
                flex: 1,
                child: _buildLegend(languageStats),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLanguageList(languageStats),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, int> languageStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languageStats.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getLanguageColor(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageList(Map<String, int> languageStats) {
    final sortedLanguages = languageStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '语言排行',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedLanguages.asMap().entries.map((entry) {
          final index = entry.key;
          final language = entry.value;
          final percentage = (language.value / languageStats.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getLanguageColor(language.key),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${language.value} 个项目',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getLanguageColor(language.key),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getLanguageColor(String language) {
    final colors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow[700]!,
      'TypeScript': Colors.blue[700]!,
      'Python': Colors.green[600]!,
      'Java': Colors.orange[600]!,
      'C++': Colors.pink[600]!,
      'C#': Colors.purple[600]!,
      'Go': Colors.cyan[600]!,
      'Rust': Colors.orange[800]!,
      'Swift': Colors.orange[500]!,
      'Kotlin': Colors.purple[500]!,
      'PHP': Colors.purple[400]!,
      'Ruby': Colors.red[600]!,
      'HTML': Colors.orange[400]!,
      'CSS': Colors.blue[400]!,
      'Shell': Colors.green[800]!,
      'Vue': Colors.green[500]!,
      'React': Colors.blue[500]!,
      'Angular': Colors.red[500]!,
      'Node.js': Colors.green[700]!,
    };

    return colors[language] ?? Colors.grey[600]!;
  }
} 