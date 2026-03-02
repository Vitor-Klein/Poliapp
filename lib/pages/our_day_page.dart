import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class OurDayPage extends StatefulWidget {
  const OurDayPage({super.key});

  @override
  State<OurDayPage> createState() => _OurDayPageState();
}

class _OurDayPageState extends State<OurDayPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isNossoDia(DateTime day) => day.day == 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ sem Scaffold aqui (porque já existe um Scaffold no LoveMenuPage)
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Todo dia 7 é especial,\n💕',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarFormat: CalendarFormat.month,

                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  if (_isNossoDia(selectedDay)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('É o nosso dia! ❤️')),
                    );
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) =>
                      _buildDayCell(context, day, false),
                  todayBuilder: (context, day, _) =>
                      _buildDayCell(context, day, true),
                  selectedBuilder: (context, day, _) =>
                      _buildDayCell(context, day, true, isSelected: true),
                  outsideBuilder: (context, day, _) =>
                      _buildDayCell(context, day, false, isOutside: true),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.favorite, color: Colors.red, size: 18),
              SizedBox(width: 6),
              Text('Dia 7 é o nosso dia ❤️'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    bool isToday, {
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final isNossoDia = _isNossoDia(day) && day.month == _focusedDay.month;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNossoDia
                ? Colors.pink.shade100
                : (isSelected ? Colors.pink.shade50 : Colors.transparent),
            border: isNossoDia
                ? Border.all(color: Colors.pink.shade400, width: 2)
                : (isToday ? Border.all(color: Colors.blue, width: 1.5) : null),
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isNossoDia ? FontWeight.bold : FontWeight.normal,
                color: isOutside
                    ? Colors.grey
                    : (isNossoDia ? Colors.pink.shade700 : Colors.black87),
                fontSize: isNossoDia ? 18 : 14,
              ),
            ),
          ),
        ),
        if (isNossoDia)
          const Positioned(
            bottom: 2,
            right: 2,
            child: Icon(Icons.favorite, size: 18, color: Colors.red),
          ),
      ],
    );
  }
}
