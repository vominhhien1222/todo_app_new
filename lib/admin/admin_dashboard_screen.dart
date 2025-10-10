import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Thống kê doanh thu"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(
              "Tổng doanh thu",
              "32.500.000 VND",
              Icons.attach_money,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard("Số đơn hàng", "24", Icons.shopping_bag),
            const SizedBox(height: 24),

            const Text(
              "🚘 Top xe bán chạy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 200, child: _BarChartSample()),

            const SizedBox(height: 32),
            const Text(
              "📦 Tỉ lệ trạng thái đơn hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 200, child: _PieChartSample()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.teal),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _BarChartSample extends StatelessWidget {
  const _BarChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                switch (value.toInt()) {
                  case 0:
                    return const Text("BMW");
                  case 1:
                    return const Text("Audi");
                  case 2:
                    return const Text("Honda");
                  default:
                    return const Text("");
                }
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 8, color: Colors.teal)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 5, color: Colors.orange)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 3, color: Colors.blue)],
          ),
        ],
      ),
    );
  }
}

class _PieChartSample extends StatelessWidget {
  const _PieChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 50, color: Colors.teal, title: 'Pending'),
          PieChartSectionData(
            value: 30,
            color: Colors.orange,
            title: 'Confirmed',
          ),
          PieChartSectionData(
            value: 20,
            color: Colors.green,
            title: 'Delivered',
          ),
        ],
      ),
    );
  }
}
