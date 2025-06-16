import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

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

  final Map<DateTime, List<Widget>> _todayEvents = {};
  final Set<DateTime> _loadedDates = {};

  final String baseUrl = "http://10.0.2.2:3000";

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      final today = normalizeDate(DateTime.now());
      _selectedDay = today;
      _focusedDay = today;
      _todayEvents.clear();
      _loadedDates.clear();
      await _loadMarkedDates(_focusedDay);
      if (mounted) setState(() {});
    } else {
      print("Token not found");
    }
  }

  Future<void> _refreshCalendar() async {
    await _initialize();
  }

  Future<void> _loadMarkedDates(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('UserID');
    final token = prefs.getString('token');

    if (token == null) return;

    final month = day.month;
    final year = day.year;

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

      if (response.statusCode == 200) {
        final List<dynamic> dates = jsonDecode(response.body)['markedDates'];

        for (var d in dates) {
          final date = normalizeDate(DateTime.parse(d));
          if (!_loadedDates.contains(date)) {
            await _loadEventsForDay(date);
            _loadedDates.add(date);
          }
        }

        if (mounted) setState(() {});
      } else {
        print("Failed to fetch marked dates");
      }
    } catch (e) {
      print("Error loading marked dates: $e");
    }
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final dateString =
        "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final key = normalizeDate(day);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/calendar-product?date=$dateString"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final todayEvents = (data['today'] ?? []) as List;

        _todayEvents[key] = todayEvents.map<Widget>((e) {
          final name = e['name'] ?? 'Unknown';
          final room = e['room'] ?? 'Unknown Room';
          final date = e['date'] ?? '';
          final productStatus = e['productStatus'] ?? 0;
          return EventItem(
            name: name,
            room: room,
            date: date,
            productStatus: productStatus,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        _todayEvents[key] = [];
      } else {
        print("Failed to fetch events: ${response.statusCode}");
      }

      if (mounted) setState(() {});
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop();
    return false;
  }

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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            color: orange,
            onRefresh: _refreshCalendar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: orange),
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
                        title: isSameDay(selected, DateTime.now())
                            ? "Products List Today"
                            : "Products List",
                        items: todayItems,
                      ),
                  ],
                ),
              ),
            ),
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
}

class EventItem extends StatelessWidget {
  final String name;
  final String room;
  final String date;
  final int productStatus;

  const EventItem({
    Key? key,
    required this.name,
    required this.room,
    required this.date,
    required this.productStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    print("Product Status: $productStatus");

    if (productStatus == 2) {
      statusColor = Colors.red;
    } else if (productStatus == 3) {
      statusColor = Colors.green;
    } else if (productStatus == 1) {
      statusColor = Colors.white;
    } else {
      statusColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: statusColor, width: 5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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
      ),
    );
  }
}
