import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles {
  static getTitleData() => FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: (value, meta) => Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xff7589a2),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          axisNameSize: BorderSide.strokeAlignCenter),
      leftTitles: AxisTitles(
        axisNameWidget: 
          Text(
            'Value',
            style: const TextStyle(
              color: Color(0xff7589a2),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          drawBelowEverything: true,
          sideTitles: SideTitles(
            getTitlesWidget: (value, meta) => Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xff7589a2),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          axisNameSize: BorderSide.strokeAlignCenter),
      rightTitles: const AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
      )),
      topTitles: const AxisTitles(
          sideTitles: SideTitles(
        showTitles: false,
      )));
}
