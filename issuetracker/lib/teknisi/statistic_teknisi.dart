import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:issuetracker/teknisi/setting_profile_teknisi.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {

  final supabase = Supabase.instance.client;

  List<double> weeklyData = [0,0,0,0];
  List<double> monthlyData = List.generate(12, (index) => 0);

  int totalTask = 0;

  @override
  void initState() {
    super.initState();
    loadStatistic();
  }

  Future<void> loadStatistic() async {

    final response = await supabase
        .from('issues')
        .select('created_at');

    List data = response;

    setState(() {
      weeklyData = countWeekly(data);
      monthlyData = countMonthly(data);
      totalTask = data.length;
    });
  }

  List<double> countWeekly(List data) {

    List<double> weeks = [0,0,0,0];

    for (var item in data) {

      DateTime date = DateTime.parse(item['created_at']);

      int week = ((date.day - 1) / 7).floor();

      if(week >=0 && week <4){
        weeks[week] +=1;
      }

    }

    return weeks;
  }

  List<double> countMonthly(List data){

    List<double> months = List.generate(12, (index) => 0);

    for (var item in data){

      DateTime date = DateTime.parse(item['created_at']);

      months[date.month -1] +=1;

    }

    return months;
  }

  @override
  Widget build(BuildContext context) {

    int currentIndex = 2;

    return Scaffold(

      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Statistic",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,

        items: const [

          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Dashboard'),

          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),

          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Statistic'),

          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),

        ],

        onTap: (index){

          if(index == 0){

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context)=> DashboardTeknisi()
                )
            );

          }

          else if(index == 1){

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context)=> HistoryTeknisi()
                )
            );

          }

          else if(index == 3){

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context)=> SettingProfileTeknisi()
                )
            );

          }

        },

      ),

      body: SingleChildScrollView(

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(

                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                    vertical: 22,
                    horizontal: 16
                ),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0,4),
                    )
                  ],

                ),

                child: Column(

                  children: [

                    Text(
                      'Total Tugas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      totalTask.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                  ],

                ),

              ),

              const SizedBox(height: 28),

              const Text(
                "Statistik Mingguan",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),

              const SizedBox(height: 12),

              Container(

                height: 230,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0,4),
                    )
                  ],

                ),

                child: ChartWeek(data: weeklyData),

              ),

              const SizedBox(height: 28),

              const Text(
                "Statistik Bulanan",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),

              const SizedBox(height: 12),

              Container(

                height: 320,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0,4),
                    )
                  ],

                ),

                child: ChartMonth(data: monthlyData),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
class ChartWeek extends StatelessWidget {

  final List<double> data;

  const ChartWeek({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    return BarChart(

      BarChartData(

        titlesData: FlTitlesData(

          bottomTitles: AxisTitles(

            sideTitles: SideTitles(

              showTitles: true,

              getTitlesWidget: (value, meta){

                const weeks = [
                  'M1','M2','M3','M4'
                ];

                if(value.toInt() >=0 && value.toInt() < weeks.length){
                  return Text(weeks[value.toInt()]);
                }

                return const Text('');

              },

            ),

          ),

        ),

        barGroups: List.generate(data.length, (i){

          return BarChartGroupData(

            x: i,

            barRods: [

              BarChartRodData(
                toY: data[i],
                color: Colors.blue,
              )

            ],

          );

        }),

      ),

    );

  }

}

class ChartMonth extends StatelessWidget {

  final List<double> data;

  const ChartMonth({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    return BarChart(

      BarChartData(

        titlesData: FlTitlesData(

          bottomTitles: AxisTitles(

            sideTitles: SideTitles(

              showTitles: true,

              getTitlesWidget: (value, meta){

                const months = [
                  '1','2','3','4','5','6',
                  '7','8','9','10','11','12'
                ];

                if(value.toInt() >=0 && value.toInt() < months.length){
                  return Text(months[value.toInt()]);
                }

                return const Text('');

              },

            ),

          ),

        ),

        barGroups: List.generate(data.length, (i){

          return BarChartGroupData(

            x: i,

            barRods: [

              BarChartRodData(
                toY: data[i],
                color: Colors.blue,
              )

            ],

          );

        }),

      ),

    );

  }

}