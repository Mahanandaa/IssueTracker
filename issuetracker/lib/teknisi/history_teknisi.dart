import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:issuetracker/teknisi/setting_profile_teknisi.dart';
import 'package:issuetracker/teknisi/statistic_teknisi.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryTeknisi extends StatefulWidget {
  const HistoryTeknisi({super.key});

  @override
  State<HistoryTeknisi> createState() => _HistoryTeknisiState();
}

class _HistoryTeknisiState extends State<HistoryTeknisi> {
  DateTime theFocusDay = DateTime.now();
  DateTime theSelectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
   int _currentIndex = 0;
   return Scaffold(
  
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
              bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'statistic'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],

        onTap: (index) {
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  HistoryTeknisi(),
      ),
    );
  } else if (index == 2){
    Navigator.push(context, MaterialPageRoute(builder: 
    (context) => Statistic()));
  } if (index == 3) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>  SettingProfileTeknisi()));
  } else if (index == 4) {
    Navigator.push(context, MaterialPageRoute(builder: (contex) => DashboardTeknisi()));
  };

 
},
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text("History"),
      ),
      
      body: SafeArea(
        
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              focusedDay: theFocusDay,
              lastDay: DateTime.utc(theFocusDay.year + 50),
              selectedDayPredicate: (day) => DateUtils.isSameDay(theSelectedDay, day),
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                theSelectedDay = selectedDay;
                theFocusDay = focusedDay;
              }),
              calendarFormat: calendarFormat,
              onFormatChanged: (format) => setState(() {
                calendarFormat = format;
              }),
              startingDayOfWeek: StartingDayOfWeek.monday,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'List Laporan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),

                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Masalah Koneksi Internet',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                            Container(
                              
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.green[800],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                        
                         Text('Rating : 9'),
                        const Text('FeedBack : '),
                         Text(
                          'Teknisi Bekerja dengan sangat baik',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}