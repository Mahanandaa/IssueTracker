import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:issuetracker/admin/data_admin.dart';
import 'package:issuetracker/admin/kasus_admin.dart';
import 'package:issuetracker/admin/profile_admin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];

  int pendingCount = 0;
  int rejectedCount = 0;
  int resolvedCount = 0;
  int progressCount = 0;

  Map<String, int> categoryCount = {};

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response = await supabase
        .from('issues')
        .select()
        .order('created_at', ascending: false);
    final data = List<Map<String, dynamic>>.from(response);
    calculateData(data);
    setState(() {
      issues = data;
    });
  }

  void calculateData(List<Map<String, dynamic>> data) {
    pendingCount = 0;
    rejectedCount = 0;
    resolvedCount = 0;
    progressCount = 0;
    categoryCount.clear();

    for (var item in data) {
      final status = item['status'];
      final category = item['category'];
      if (status == 'Pending') pendingCount++;
      if (status == 'Rejected') rejectedCount++;
      if (status == 'Resolved') resolvedCount++;
      if (status == 'In Progress') progressCount++;
      if (category != null) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }
  }
  List<BarChartGroupData> buildBarGroups() {
    final categories = categoryCount.keys.toList();
    return List.generate(categories.length, (i) {
      final value = categoryCount[categories[i]] ?? 0;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: value.toDouble(), color: Colors.blue),
        ],
      );
    });
  }

  List<String> getCategoryLabels() => categoryCount.keys.toList();

  List<PieChartSectionData> buildPieSections() {
    final total =
        pendingCount + rejectedCount + resolvedCount + progressCount;
    if (total == 0) return [];
    return [
      PieChartSectionData(
        color: Colors.orange,
        value: pendingCount.toDouble(),
        title: '${((pendingCount / total) * 100).toStringAsFixed(0)}%',
      ),
      PieChartSectionData(
        color: Colors.red,
        value: rejectedCount.toDouble(),
        title: '${((rejectedCount / total) * 100).toStringAsFixed(0)}%',
      ),
      PieChartSectionData(
        color: Colors.green,
        value: resolvedCount.toDouble(),
        title: '${((resolvedCount / total) * 100).toStringAsFixed(0)}%',
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: progressCount.toDouble(),
        title: '${((progressCount / total) * 100).toStringAsFixed(0)}%',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Dashboard"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => KasusAdmin()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DataAdmin()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileAdmin()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work), label: 'Kasus'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storage), label: 'Data'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: statusBox(
                        "Pending", pendingCount.toString(), Colors.orange)),
                const SizedBox(width: 10),
                Expanded(
                    child: statusBox(
                        "Ditolak", rejectedCount.toString(), Colors.red)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: statusBox(
                        "Selesai", resolvedCount.toString(), Colors.green)),
                const SizedBox(width: 10),
                Expanded(
                    child: statusBox(
                        "Progress", progressCount.toString(), Colors.blue)),
              ],
            ),

            const SizedBox(height: 20),


            const SizedBox(height: 12),

            const Text(
              'Data Kasus Kategori',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              padding: const EdgeInsets.all(12),
              child: BarChart(
                BarChartData(barGroups: buildBarGroups()),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Data Kasus Status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 300,
                    padding: const EdgeInsets.all(12),
                    child: PieChart(
                      PieChartData(
                        sections: buildPieSections().isEmpty
                            ? [
                                PieChartSectionData(
                                    value: 1,
                                    color: Colors.grey,
                                    title: "0%")
                              ]
                            : buildPieSections(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(width: 12, height: 12, color: Colors.green),
                        const SizedBox(width: 6),
                        const Text("Selesai"),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                            width: 12, height: 12, color: Colors.orange),
                        const SizedBox(width: 6),
                        const Text("Pending"),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(width: 12, height: 12, color: Colors.red),
                        const SizedBox(width: 6),
                        const Text("Ditolak"),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(width: 12, height: 12, color: Colors.blue),
                        const SizedBox(width: 6),
                        const Text("Progress"),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget statusBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}