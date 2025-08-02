import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/project_bloc.dart';

class CommitChart extends StatelessWidget {
  const CommitChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectLoaded) {
          return _buildChart(context, state.projects);
        }
        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildChart(BuildContext context, projects) {
    // 模拟提交数据 - 实际应用中应该从API获取
    final commitData = [
      {'date': '2024-01-01', 'commits': 5},
      {'date': '2024-01-02', 'commits': 8},
      {'date': '2024-01-03', 'commits': 12},
      {'date': '2024-01-04', 'commits': 6},
      {'date': '2024-01-05', 'commits': 15},
      {'date': '2024-01-06', 'commits': 9},
      {'date': '2024-01-07', 'commits': 11},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近7天提交趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 5,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('1日', style: style);
                            break;
                          case 1:
                            text = const Text('2日', style: style);
                            break;
                          case 2:
                            text = const Text('3日', style: style);
                            break;
                          case 3:
                            text = const Text('4日', style: style);
                            break;
                          case 4:
                            text = const Text('5日', style: style);
                            break;
                          case 5:
                            text = const Text('6日', style: style);
                            break;
                          case 6:
                            text = const Text('7日', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        return Text(
                          value.toInt().toString(),
                          style: style,
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 20,
                lineBarsData: [
                  LineChartBarData(
                    spots: commitData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), (entry.value['commits'] as int).toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.8),
                        Colors.blue.withValues(alpha: 0.3),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.3),
                          Colors.blue.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(commitData),
        ],
      ),
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> commitData) {
    final totalCommits = commitData.fold<int>(0, (sum, item) => sum + (item['commits'] as int));
    final avgCommits = totalCommits / commitData.length;
    final maxCommits = commitData.map((item) => item['commits'] as int).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: '总提交',
            value: totalCommits.toString(),
            icon: Icons.commit,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '平均/天',
            value: avgCommits.toStringAsFixed(1),
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: '最高/天',
            value: maxCommits.toString(),
            icon: Icons.arrow_upward,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 