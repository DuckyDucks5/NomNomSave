import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final Color orange = const Color(0xFFFF8C42);

  DateTime _focusedDay = DateTime(2025, 3, 3);
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _expirationEvents = {
    DateTime.utc(2025, 3, 3): ["Ultramilk Chocolate 9000mL"],
    DateTime.utc(2025, 3, 4): ["Ultramilk Strawberry 9000mL"],
  };

  List<String> _getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _expirationEvents[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: orange,
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.addchart_rounded, color: Colors.white),
      ),
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
                eventLoader: _getEventsForDay,
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
                  todayDecoration: const BoxDecoration(), // no circle
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
                },
              ),
              const SizedBox(height: 20),
              if (_getEventsForDay(_selectedDay ?? _focusedDay).isNotEmpty)
                _buildExpiringBox(
                  title: "Products Expiring",
                  items: _getEventsForDay(_selectedDay ?? _focusedDay),
                )
              else
                const Text("No products expiring on this date."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringBox({
    required String title,
    required List<String> items,
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (e) => Text(
              e,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    DateTime selectedDate = _selectedDay ?? _focusedDay;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Product Expiration'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Product Description',
            prefixIcon: Icon(Icons.inventory_2_rounded, color: Colors.white),
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
                setState(() {
                  final key = DateTime.utc(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                  );
                  _expirationEvents.putIfAbsent(key, () => []);
                  _expirationEvents[key]!.add(_controller.text.trim());
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
