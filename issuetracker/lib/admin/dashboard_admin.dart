import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/tidak_selesai_teknisi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> issues = [];

  final SearchBar = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  Future<void> fetchIssues() async {
    final response = await supabase.from('issues').select();
    setState(() {
      issues = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fenchData([String? searchTerm]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var query = supabase.from('issues').select();

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = supabase
            .from('issues')
            .select()
            .or('title.ilike.%$searchTerm%, location.ilike.%$searchTerm%');
      }

      final data = await query;

      setState(() {
        issues = List<Map<String, dynamic>>.from(data);
      });
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error : ${error.message}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("Dashboard"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: TextField(
                      controller: SearchBar,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari kasus...',
                        prefixIcon: Icon(Icons.search),
                      ),

                      onChanged: (value) {
                        if (value.isEmpty) {
                          fetchIssues();
                        } else {
                          fenchData(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    icon: Icon(Icons.date_range_outlined,
                        color: Colors.blue[400], size: 28),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardAdmin(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                     setState(() {
                     selectedStatus = 'Hari Ini';
                                  });
                        fetchIssues();
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),

                        decoration: BoxDecoration(
                          color: selectedStatus == 'Hari Ini'
                              ? Colors.blue[700]
                              : Colors.grey[200],

                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Center(
                          child: Text(
                            'Hari Ini',

                            style: TextStyle(
                              color: selectedStatus == 'Hari Ini'
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                            setState(() {
                       selectedStatus = 'Minggu Ini';
                            });          
                        fetchIssues();
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),

                        decoration: BoxDecoration(
                          color: selectedStatus == 'Minggu Ini'
                              ? Colors.blue[700]
                              : Colors.grey[200],

                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Center(
                          child: Text(
                            'Minggu Ini',

                            style: TextStyle(
                              color: selectedStatus == 'Minggu Ini'
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),

                      decoration: BoxDecoration(
                        color: const Color.fromARGB(220, 245, 243, 243),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),

                      child: const Column(
                        children: [
                          Text("Pending",
                              style: TextStyle(fontSize: 12, color: Colors.orange)),
                          SizedBox(height: 4),
                          Text("12",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),

                      decoration: BoxDecoration(
                        color: const Color.fromARGB(220, 245, 243, 243),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),

                      child: const Column(
                        children: [
                          Text("Ditolak",
                              style: TextStyle(fontSize: 12, color: Colors.red)),
                          SizedBox(height: 4),
                          Text("12",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Analisis',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),

              const SizedBox(height: 10),

              Container(
                height: 320,
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: const ChartType(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartType extends StatelessWidget {
  const ChartType({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,

              getTitlesWidget: (value, meta) {

                const weeks = [
                  'IT',
                  'Fasilitas',
                  'Kebersihan',
                  'Keamanan',
                  'Pipa',
                  'Electronic',
                  'Lainnya'
                ];

                if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                  return Text(weeks[value.toInt()]);
                }

                return const Text('');
              },
            ),
          ),
        ),

        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (i + i) * 0.2,
                color: Colors.blue,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class ChartStatus extends StatelessWidget {
  const ChartStatus({super.key});

  @override
  Widget build(BuildContext context) {

    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: showingSections(),
      ),
    );
  }
}

List<PieChartSectionData> showingSections() {

  return List.generate(4, (i) {

    const fontSize = 16.0;
    const radius = 50.0;

    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    switch (i) {

      case 0:
        return PieChartSectionData(
          color: Colors.blue,
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );

      case 1:
        return PieChartSectionData(
          color: Colors.yellow,
          value: 30,
          title: '30%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );

      case 2:
        return PieChartSectionData(
          color: Colors.purple,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );

      default:
        return PieChartSectionData(
          color: Colors.green,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );
    }
  });
}