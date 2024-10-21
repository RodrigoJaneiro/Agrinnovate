import 'package:agrinnovate/lineChart/line_titels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  final List<FlSpot> dataPoints; // Lista de pontos (double, double)
  final double minX; // Valor mínimo do eixo X
  final double maxX; // Valor máximo do eixo X
  final double minY; // Valor mínimo do eixo Y
  final double maxY; // Valor máximo do eixo Y

  // Construtor que recebe os pontos e os limites dos eixos
  LineChartWidget({
    required this.dataPoints,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) => LineChart(
        LineChartData(
          minX: minX, // Limite mínimo do eixo X
          maxX: maxX, // Limite máximo do eixo X
          minY: minY, // Limite mínimo do eixo Y
          maxY: maxY, // Limite máximo do eixo Y
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xff37434d),
                strokeWidth: 0.1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints, // Usa a lista de pontos fornecida
              isCurved: true, // Faz a curva suave
              barWidth: 5,
              dotData: const FlDotData(
                show: true, // Mostra os pontos no gráfico
              ),
            ),
          ],
        ),
      );
}
