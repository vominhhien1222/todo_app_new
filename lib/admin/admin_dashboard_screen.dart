import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// 📦 Các màn hình admin con
import 'admin_users_screen.dart';
import 'admin_cars_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_todos_screen.dart';
import 'admin_announcements_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;
  bool _isHoveringAvatar = false;

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.dashboard, 'title': 'Dashboard'},
    {'icon': Icons.people_alt, 'title': 'Users'},
    {'icon': Icons.directions_car, 'title': 'Cars'},
    {'icon': Icons.receipt_long, 'title': 'Orders'},
    {'icon': Icons.check_circle, 'title': 'Todos'},
    {'icon': Icons.campaign, 'title': 'Announcements'},
    {'icon': Icons.account_balance_wallet, 'title': 'Finance'},
    {'icon': Icons.bar_chart, 'title': 'Statistic'},
  ];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // 🟩 SIDEBAR
          Container(
            width: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.primaryColor.shade50,
                  themeProvider.primaryColor.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                MouseRegion(
                  onEnter: (_) => setState(() => _isHoveringAvatar = true),
                  onExit: (_) => setState(() => _isHoveringAvatar = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..scale(_isHoveringAvatar ? 1.1 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: _isHoveringAvatar
                          ? [
                              BoxShadow(
                                color: themeProvider.primaryColor.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ]
                          : [],
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/150?img=47",
                      ),
                      backgroundColor: Color(0xFFE0F2F1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? "Admin",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 0.5),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return _buildMenuItem(
                        icon: item['icon'],
                        title: item['title'],
                        index: index,
                        themeColor: themeProvider.primaryColor,
                      );
                    },
                  ),
                ),
                const Divider(thickness: 0.5),
                ExpansionTile(
                  leading: Icon(
                    Icons.palette,
                    color: themeProvider.primaryColor,
                  ),
                  title: const Text(
                    "Giao diện",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    SwitchListTile(
                      title: const Text("Chế độ tối"),
                      value: themeProvider.currentTheme == ThemeMode.dark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      secondary: const Icon(Icons.brightness_6),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Màu chủ đạo:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ThemeProvider.colorOptions.map((opt) {
                        final isSelected =
                            themeProvider.primaryColor == opt.color;
                        return GestureDetector(
                          onTap: () => themeProvider.setPrimaryColor(opt.color),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: isSelected ? 24 : 22,
                                backgroundColor: opt.color,
                                child: Icon(
                                  opt.icon,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 26,
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: themeProvider.primaryColor,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _logout(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 🟦 MAIN CONTENT
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _getPage(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required MaterialColor themeColor,
  }) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.15) : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? themeColor : Colors.grey.shade700),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? themeColor : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const _DashboardPage(key: ValueKey("Dashboard"));
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminCarsScreen();
      case 3:
        return const AdminOrdersScreen();
      case 4:
        return const AdminTodosScreen();
      case 5:
        return const AdminAnnouncementsScreen();
      case 6:
        return const Center(child: Text("💰 Finance Page (Coming soon...)"));
      case 7:
        return const Center(child: Text("📈 Statistic Page (Coming soon...)"));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ================= DASHBOARD PAGE =================
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

    // thêm dữ liệu test để dễ thấy hiệu ứng
    if (brands.length < 3) {
      brands.addAll({"Vespa": 5, "Audi": 3, "BMW": 2});
      statuses.addAll({"pending": 3, "delivered": 4, "cancelled": 1});
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
    if (loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard(
                Icons.attach_money,
                "Tổng doanh thu",
                "${totalRevenue.toStringAsFixed(0)} VND",
                const Color(0xFF3AB0A2),
              ),
              _buildSummaryCard(
                Icons.shopping_bag,
                "Số đơn hàng",
                "$totalOrders",
                const Color(0xFFFFC371),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "🚘 Top xe bán chạy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: _BarChartDynamic(data: topBrands)),
          const SizedBox(height: 32),
          const Text(
            "📦 Tỉ lệ trạng thái đơn hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(height: 250, child: _PieChartDynamic(data: statusCount)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
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

// ============== BAR CHART (Tap + Glow) ==============
class _BarChartDynamic extends StatefulWidget {
  final Map<String, int> data;
  const _BarChartDynamic({required this.data});
  @override
  State<_BarChartDynamic> createState() => _BarChartDynamicState();
}

class _BarChartDynamicState extends State<_BarChartDynamic> {
  int? touchedIndex;
  @override
  Widget build(BuildContext context) {
    final entries = widget.data.entries.toList();
    if (entries.isEmpty) return const Center(child: Text("Không có dữ liệu."));
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      entries[value.toInt()].key,
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, _, rod, __) {
              final item = entries[group.x.toInt()];
              return BarTooltipItem(
                "${item.key}\n",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "${rod.toY.toInt()} xe",
                    style: const TextStyle(color: Colors.amberAccent),
                  ),
                ],
              );
            },
          ),
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.spot == null) {
              setState(() => touchedIndex = -1);
              return;
            }
            setState(() => touchedIndex = response.spot!.touchedBarGroupIndex);
          },
        ),
        barGroups: List.generate(entries.length, (i) {
          final isTapped = i == touchedIndex;
          final y = entries[i].value.toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: isTapped ? y * 1.2 : y,
                width: 24,
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: isTapped
                      ? [const Color(0xFF3AB0A2), const Color(0xFFB2EBF2)]
                      : [const Color(0xFFB2EBF2), const Color(0xFF3AB0A2)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                rodStackItems: isTapped
                    ? [
                        BarChartRodStackItem(
                          0,
                          y,
                          const Color(0x66FFFFFF),
                        ), // glow overlay
                      ]
                    : [],
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 700),
    );
  }
}

// ============== PIE CHART (Tap + Glow) ==============
class _PieChartDynamic extends StatefulWidget {
  final Map<String, int> data;
  const _PieChartDynamic({required this.data});
  @override
  State<_PieChartDynamic> createState() => _PieChartDynamicState();
}

class _PieChartDynamicState extends State<_PieChartDynamic> {
  int? touchedIndex;
  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold<int>(0, (a, b) => a + b);
    final entries = widget.data.entries.toList();
    if (total == 0) return const Center(child: Text("Không có dữ liệu."));
    final colors = [
      const Color(0xFF3AB0A2),
      const Color(0xFFFFC371),
      const Color(0xFF6AD7E5),
      const Color(0xFFB388FF),
      const Color(0xFFFF6F61),
    ];
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 45,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.touchedSection == null) {
              setState(() => touchedIndex = -1);
              return;
            }
            setState(
              () => touchedIndex = response.touchedSection!.touchedSectionIndex,
            );
          },
        ),
        sections: List.generate(entries.length, (i) {
          final e = entries[i];
          final isTapped = i == touchedIndex;
          final percent = (e.value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            value: e.value.toDouble(),
            color: colors[i % colors.length],
            radius: isTapped ? 85 : 65,
            title: "${e.key}\n$percent%",
            titleStyle: TextStyle(
              fontSize: isTapped ? 15 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            borderSide: isTapped
                ? BorderSide(color: Colors.white.withOpacity(0.9), width: 4)
                : BorderSide.none,
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 700),
    );
  }
}
