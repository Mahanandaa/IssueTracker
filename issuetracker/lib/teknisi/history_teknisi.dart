import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/dashboard_teknisi.dart';
import 'package:issuetracker/teknisi/setting_profile_teknisi.dart';
import 'package:issuetracker/teknisi/statistic_teknisi.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class HistoryTeknisi extends StatefulWidget {
  const HistoryTeknisi({super.key

  });

  @override
  State<HistoryTeknisi> createState() => _HistoryTeknisiState();
}

final supabase = Supabase.instance.client;
List<Map<String, dynamic>> issues = [];
 




class _HistoryTeknisiState extends State<HistoryTeknisi> {
  @override
  void initState() {
    super.initState();
    filterByDate(theSelectedDay);
  }
  bool _isLoading = false;
Future<void> filterByDate(DateTime date) async{
   setState(() {
    _isLoading = true;
  });

try{
  final start = DateTime(date.year, date.month, date.day);
final end = start.add(const Duration(days: 1));

final response  = await supabase.from('issues').select().gte('created_at', start.toIso8601String()).lt('ceated_end', end.toIso8601String());

  setState(() {
        issues = List<Map<String, dynamic>>.from(response);
      });
} catch (a) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERROR :$a')));
} finally {
  setState(() {
    _isLoading = false;
  });
}


}
  DateTime theFocusDay = DateTime.now();
  DateTime theSelectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  @override
  Widget build(BuildContext context) {
   int _currentIndex = 1;
   return Scaffold(
  
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
         bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.grey[200],
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,
  currentIndex: _currentIndex,
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

  onTap: (index) {

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardTeknisi(),
        ),
      );
    }

    else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryTeknisi(),
        ),
      );
    }

    else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Statistic(),
        ),
      );
    }

    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingProfileTeknisi(),
        ),
      );
    }
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
                filterByDate(selectedDay);
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
                 ...issues.map((issues){
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white

                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(issues['judul'] ?? ' Not Found',
                          style: TextStyle(
                            fontWeight: FontWeight.w400
                          ),
                          
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green[800],
                            ),
                           
                           padding: EdgeInsets.all(10),
                           child: Text(issues['status'] ?? 'not found',
                          style: TextStyle(
                            color: Colors.white
                          ),
                           ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text("Rating :${issues [ 'rating'] ?? '0'}"),
                      Text('FeedBack :'),
                      Text(
                        issues['feedback'] ?? '-',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic
                        ),
                      )
                    ],
                    ),
                  );  
                 }),
                                ],
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}