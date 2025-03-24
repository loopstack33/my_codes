import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    await showDialog(
      context: context,
      builder: (context) => CustomDatePicker(
        initialDate: initialDate,
        onDateSelected: (date) {
          setState(() {
            selectedDate = date!;
          });
        },
      ),
    );
  }
  TimeOfDay? selectedTime;
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = selectedTime ?? TimeOfDay(hour: 12, minute: 0);

    await showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: initialTime,
        onTimeSelected: (time) {
          setState(() {
            selectedTime = time;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
         title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Selected Date: $selectedDate",
              style: TextStyle(fontSize: 18),
            ),
            Text("Selected Time: $selectedTime",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text("Pick a Date"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text("Pick a Time"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime?) onDateSelected;

  const CustomDatePicker({super.key, required this.initialDate, required this.onDateSelected});

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late DateTime selectedDate;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // Remove default padding
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom Header with Left & Right Navigation
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.blue, // Customize color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  "${_getMonthName(currentMonth.month)} ${currentMonth.year}",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          // Weekday Labels
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                  .map((day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ))
                  .toList(),
            ),
          ),

          // Custom GridView for Dates
          SizedBox(
            height: 300,
            width: 300,
            child: _buildCalendar(),
          ),
        ],
      ),

      // Clear Button
      actions: [
        TextButton(
          onPressed: () {
            widget.onDateSelected(null); // Clear selection
            Navigator.pop(context);
          },
          child: Text("Clear"),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    List<Widget> days = [];
    DateTime firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    int daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

    // Empty boxes for days before the 1st
    for (int i = 1; i < startingWeekday; i++) {
      days.add(Container());
    }

    // Actual days in the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime dayDate = DateTime(currentMonth.year, currentMonth.month, day);

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = dayDate;
            });
            widget.onDateSelected(dayDate);
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: selectedDate == dayDate ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            width: 40,
            height: 40,
            child: Text(
              "$day",
              style: TextStyle(
                color: selectedDate == dayDate ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7, // 7 days in a week
      shrinkWrap: true,
      children: days,
    );
  }

  String _getMonthName(int month) {
    List<String> months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay?) onTimeSelected;

  const CustomTimePicker({super.key, required this.initialTime, required this.onTimeSelected});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay selectedTime;
  List<TimeOfDay> timeSlots = [];

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    timeSlots.clear();
    TimeOfDay start = TimeOfDay(hour: 12, minute: 0);

    for (int i = 0; i < 24; i++) {
      timeSlots.add(start);
      start = _addMinutes(start, 30);
    }
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    int newMinutes = time.minute + minutes;
    int newHours = time.hour + (newMinutes ~/ 60);
    newMinutes %= 60;
    return TimeOfDay(hour: newHours % 24, minute: newMinutes);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:${time.minute.toString().padLeft(2, '0')} $period";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // Remove default padding
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar: Selected Time + Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(selectedTime),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(), // Divider below header

          // Time List
          SizedBox(
            width: 300,
            height: 300, // Adjust based on needs
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                TimeOfDay time = timeSlots[index];
                bool isSelected = time == selectedTime;

                return ListTile(
                  title: Text(_formatTime(time)),
                  // tileColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
                  onTap: () {
                    setState(() {
                      selectedTime = time;
                    });
                    widget.onTimeSelected(time);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



