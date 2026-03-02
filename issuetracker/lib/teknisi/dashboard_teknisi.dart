import 'package:flutter/material.dart';
import 'package:issuetracker/teknisi/history_teknisi.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardTeknisi extends StatefulWidget {
  const DashboardTeknisi({super.key});

  @override
  State<DashboardTeknisi> createState() => _DashboardTeknisiState();
}

class _DashboardTeknisiState extends State<DashboardTeknisi> {
  String selectedFilter = "All";
  int _currentIndex = 0;
List <Widget> _pages = [DashboardTeknisi(), HistoryTeknisi()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'DashboardTeknisi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HistoryTeknisi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'chart'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'settings'),
        ],

        onTap: (index) => setState(() => _currentIndex = index),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang.",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xffe6e6e6),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cari Tugas...",
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = "All";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == "All"
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "All",
                          style: TextStyle(
                            color: selectedFilter == "All"
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = "Low";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == "Low"
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "Low",
                          style: TextStyle(
                            color: selectedFilter == "Low"
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = "Medium";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == "Medium"
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "Medium",
                          style: TextStyle(
                            color: selectedFilter == "Medium"
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = "Hard";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == "Hard"
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "Medium",
                          style: TextStyle(
                            color: selectedFilter == "Hard"
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = "Urgent";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedFilter == "Urgent"
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          "Urgent",
                          style: TextStyle(
                            color: selectedFilter == "Urgent"
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffebebeb),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffebebeb),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "In_progress",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffebebeb),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Resolved",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Tugas Terbaru",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfff25c5c),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tidak ada air",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "urgent",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Lokasi : Lantai 1",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                     Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
  children: [
    Text(
      "2 Februari 2026",
      style: TextStyle(
        fontSize: 11,
        color: Colors.white,
      ),
    ),

    //error euy
   /* GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailLaporanTeknisi(issueId: issue['id'].toString()),
          ),
        );
      },
      child: Text(
        "Lihat Detail",
        style: TextStyle(
          color: Colors.blue, 
          fontSize: 11,
          fontWeight: FontWeight.bold, 
        ),
      ),
    ),
    */
  ],
)

                     
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}