import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/paper_bloc.dart';

class ReadingProgress extends StatelessWidget {
  const ReadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaperBloc, PaperState>(
      builder: (context, state) {
        if (state is PaperLoaded) {
          return _buildReadingStats(context, state.papers);
        }
        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildReadingStats(BuildContext context, papers) {
    // 模拟阅读统计数据
    final totalPapers = papers.length;
    final readPapers = (totalPapers * 0.3).round(); // 30%已读
    final unreadPapers = totalPapers - readPapers;
    final readingPapers = (totalPapers * 0.1).round(); // 10%正在阅读

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '阅读统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // 统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '总论文',
                  value: totalPapers.toString(),
                  icon: Icons.article,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '已读',
                  value: readPapers.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '未读',
                  value: unreadPapers.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 阅读进度图表
          const Text(
            '阅读进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: readPapers.toDouble(),
                    title: '已读\n$readPapers',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: readingPapers.toDouble(),
                    title: '阅读中\n$readingPapers',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.grey[400]!,
                    value: unreadPapers.toDouble(),
                    title: '未读\n$unreadPapers',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 图例
          _buildLegend(readPapers, readingPapers, unreadPapers),
          const SizedBox(height: 24),
          // 阅读趋势
          const Text(
            '阅读趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
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
                            text = const Text('周一', style: style);
                            break;
                          case 1:
                            text = const Text('周二', style: style);
                            break;
                          case 2:
                            text = const Text('周三', style: style);
                            break;
                          case 3:
                            text = const Text('周四', style: style);
                            break;
                          case 4:
                            text = const Text('周五', style: style);
                            break;
                          case 5:
                            text = const Text('周六', style: style);
                            break;
                          case 6:
                            text = const Text('周日', style: style);
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
                      interval: 1,
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
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 2),
                      const FlSpot(1, 3),
                      const FlSpot(2, 1),
                      const FlSpot(3, 4),
                      const FlSpot(4, 2),
                      const FlSpot(5, 3),
                      const FlSpot(6, 1),
                    ],
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
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(int read, int reading, int unread) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('已读', read, Colors.green),
        _buildLegendItem('阅读中', reading, Colors.orange),
        _buildLegendItem('未读', unread, Colors.grey[400]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
} 