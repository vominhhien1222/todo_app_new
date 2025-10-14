import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;

  final List<String> menuItems = ["Dashboard", "Statistic", "Finance"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6F5), Color(0xFFDFF3F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // 🔹 SIDEBAR
            Container(
              width: 230,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "🚗 Car Admin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3AB0A2),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // menu items
                  for (int i = 0; i < menuItems.length; i++)
                    _buildMenuItem(
                      i == 0
                          ? Icons.dashboard
                          : i == 1
                          ? Icons.bar_chart
                          : Icons.account_balance_wallet,
                      menuItems[i],
                      i,
                    ),
                ],
              ),
            ),

            // 🔹 MAIN CONTENT
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  final offsetAnimation =
                      Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: _getPage(selectedIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final bool isSelected = selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3AB0A2).withOpacity(0.15)
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF3AB0A2) : Colors.grey[600],
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3AB0A2)
                      : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const _DashboardPage();
      case 1:
        return const Center(
          key: ValueKey("Statistic"),
          child: Text("📈 Statistic Page (Coming soon...)"),
        );
      case 2:
        return const Center(
          key: ValueKey("Finance"),
          child: Text("💰 Finance Page (Coming soon...)"),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ==================== DASHBOARD PAGE =====================

class _DashboardPage extends StatefulWidget {
  const _DashboardPage({super.key});

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  double totalRevenue = 0;
  int totalOrders = 0;
  Map<String, int> topBrands = {};
  Map<String, int> statusCount = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .get();

    double revenue = 0;
    int orders = 0;
    Map<String, int> brands = {};
    Map<String, int> statuses = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      revenue += (data['totalAmount'] ?? 0).toDouble();
      orders++;

      final brand = (data['brand'] ?? 'Khác').toString();
      brands[brand] = (brands[brand] ?? 0) + 1;

      final status = (data['status'] ?? 'pending').toString();
      statuses[status] = (statuses[status] ?? 0) + 1;
    }

    setState(() {
      totalRevenue = revenue;
      totalOrders = orders;
      topBrands = brands;
      statusCount = statuses;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome back 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=47',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard(
                icon: Icons.attach_money,
                title: "Tổng doanh thu",
                value: "${totalRevenue.toStringAsFixed(0)} VND",
                color: const Color(0xFF3AB0A2),
              ),
              _buildSummaryCard(
                icon: Icons.shopping_bag,
                title: "Số đơn hàng",
                value: "$totalOrders",
                color: const Color(0xFFFFC371),
              ),
            ],
          ),
          const SizedBox(height: 30),

          const Text(
            "🚘 Top xe bán chạy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 200, child: _BarChartDynamic(data: topBrands)),

          const SizedBox(height: 32),
          const Text(
            "📦 Tỉ lệ trạng thái đơn hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: _PieChartDynamic(data: statusCount)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ================== BAR CHART ==================

class _BarChartDynamic extends StatelessWidget {
  final Map<String, int> data;
  const _BarChartDynamic({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    if (entries.isEmpty) return const Center(child: Text("Không có dữ liệu."));

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < entries.length) {
                  return Text(
                    entries[value.toInt()].key,
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text("");
              },
            ),
          ),
        ),
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value.toDouble(),
                color: const Color(0xFF3AB0A2),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ================== PIE CHART ==================

class _PieChartDynamic extends StatelessWidget {
  final Map<String, int> data;
  const _PieChartDynamic({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final entries = data.entries.toList();

    if (total == 0) return const Center(child: Text("Không có dữ liệu."));

    final colors = [
      const Color(0xFF3AB0A2),
      const Color(0xFFFFC371),
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(entries.length, (i) {
          final e = entries[i];
          final percent = (e.value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            value: e.value.toDouble(),
            color: colors[i % colors.length],
            title: '${e.key}\n$percent%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ),
    );
  }
}
