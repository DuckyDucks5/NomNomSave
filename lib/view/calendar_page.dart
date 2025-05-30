import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

class _CalendarPageState extends State<CalendarPage> {
  final Color orange = const Color(0xFFFF8C42);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Menyimpan event sebagai widget untuk ditampilkan
  final Map<DateTime, List<Widget>> _todayEvents = {};
  final Set<DateTime> _loadedDates = {};
 
  final String baseUrl = "http://10.0.2.2:3000";

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    //final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (token != null) {
      final today = normalizeDate(DateTime.now());
      _selectedDay = today;
      _focusedDay = today;
      await _loadMarkedDates(_focusedDay);
      setState(() {});
    } else {
      print("Token not found");
    }
  }

  Future<void> _loadMarkedDates(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (token == null) return;

    final month = day.month;
    final year = day.year;
    print("userIDon loadmarkeddates: $userId");

    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/dot-calendar?month=$month&year=$year&userId=$userId",
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("response calendar loadMarkedDates: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> dates = jsonDecode(response.body)['markedDates'];

        for (var d in dates) {
          final date = normalizeDate(DateTime.parse(d));
          if (!_loadedDates.contains(date)) {
            await _loadEventsForDay(date);
            _loadedDates.add(date);
          }
          print("list dates dot: $dates");
          setState(() {});
        }

        //print("list dates dot: $dates")
      } else {
        print("Failed to fetch marked dates");
      }
    } catch (e) {
      print("Error loading marked dates: $e");
    }
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    //final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');
    if (token == null) return;

    final dateString =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final key = normalizeDate(day);

    print("Loading events for day: $dateString");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/calendar-product?date=$dateString"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("response calendar loadEventsForDay: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todayEvents = (data['today'] ?? []) as List;
        print("dates data events: $data");
        setState(() {
          _todayEvents[key] =
              todayEvents.map<Widget>((e) {
                final name = e['name'] ?? 'Unknown';
                final room = e['room'] ?? 'Unknown Room';
                final date = e['date'] ?? '';
                return EventItem(name: name, room: room, date: date);
              }).toList();
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _todayEvents[key] = [];
        });
      } else {
        print("Failed to fetch events: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching events: $e");
    }

    print("todayEvent");
  }

  // Untuk eventLoader di kalender: tampilkan dot jika ada event dan bukan tanggal yang dipilih
  List<String> _getAllEventsForDay(DateTime day) {
    final key = normalizeDate(day);
    final isSelected = isSameDay(day, _selectedDay);

    if (isSelected) return [];

    final events = _todayEvents[key] ?? [];
    return events.isNotEmpty ? ['event'] : [];
  }

  List<Widget> _getTodayEventsForDay(DateTime day) {
    final key = normalizeDate(day);
    return _todayEvents[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? _focusedDay;
    final todayItems = _getTodayEventsForDay(selected);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: orange,
      //   onPressed: () => _showAddEventDialog(context),
      //   child: const Icon(Icons.addchart_rounded, color: Colors.white),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getAllEventsForDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: orange),
                  rightChevronIcon: Icon(Icons.chevron_right, color: orange),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(),
                  todayTextStyle: TextStyle(
                    color: orange,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.white),
                  markerDecoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadEventsForDay(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = focusedDay;
                    _loadedDates.clear();
                  });
                  _loadMarkedDates(focusedDay);
                },
              ),
              const SizedBox(height: 20),
              if (todayItems.isEmpty)
                const Text("No products expiring on this date.")
              else
                _buildExpiringBox(
                  title: "Products Expiring Today",
                  items: todayItems,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringBox({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1C4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    DateTime selectedDate = _selectedDay ?? _focusedDay;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add Product Expiration'),
            content: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Product Description',
                prefixIcon: Icon(Icons.inventory_2_rounded),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    final key = normalizeDate(selectedDate);
                    setState(() {
                      _todayEvents.putIfAbsent(key, () => []);
                      _todayEvents[key]!.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _controller.text.trim(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }
}

// Widget event khusus styling
class EventItem extends StatelessWidget {
  final String name;
  final String room;
  final String date;

  const EventItem({
    Key? key,
    required this.name,
    required this.room,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: "$date: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            TextSpan(text: "$name "),
            TextSpan(text: "from $room"),
          ],
        ),
      ),
    );
  }
}