import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/service_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class MaintenanceCalendarScreen extends StatefulWidget {
  const MaintenanceCalendarScreen({super.key});

  @override
  State<MaintenanceCalendarScreen> createState() =>
      _MaintenanceCalendarScreenState();
}

class _MaintenanceCalendarScreenState extends State<MaintenanceCalendarScreen> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('yyyy-MM-dd (EEEE)');

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _isSameDayWithoutTime(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'නඩත්තු කැලැන්ඩරය (Maintenance)',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<ServiceModel?>(
        stream: _firestoreService.getServiceInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final serviceInfo = snapshot.data;
          final lastServiceDate = serviceInfo?.lastServiceDate;
          final nextServiceDate = serviceInfo?.nextServiceDate;
          final lastTireDate = serviceInfo?.lastTireChangeDate;

          List<String> getEventsForDay(DateTime day) {
            final events = <String>[];
            if (lastServiceDate != null &&
                _isSameDayWithoutTime(day, lastServiceDate)) {
              events.add('අවසන් සර්විස් කිරීම (Last Service)');
            }
            if (nextServiceDate != null &&
                _isSameDayWithoutTime(day, nextServiceDate)) {
              events.add('ඊළඟ සර්විස් කිරීම (Next Service Due)');
            }
            if (lastTireDate != null &&
                _isSameDayWithoutTime(day, lastTireDate)) {
              events.add('අවසන් ටයර් මාරුව (Tire Replacement)');
            }
            return events;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calendar Card
                Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2035),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: getEventsForDay,
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return null;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: events.map((event) {
                              Color markerColor = Colors.blue;
                              if (event.toString().contains('Next')) {
                                markerColor = Colors.redAccent;
                              } else if (event.toString().contains('Tire')) {
                                markerColor = Colors.green;
                              }
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: markerColor,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Legend & Maintenance Milestones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'නඩත්තු විස්තර (Maintenance Details)',
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Next Service Card
                      if (nextServiceDate != null) ...[
                        _buildMilestoneCard(
                          title: 'ඊළඟ සර්විස් කිරීම (Next Service Due)',
                          date: nextServiceDate,
                          icon: Icons.build_circle,
                          color: Colors.redAccent,
                          subtitle:
                              'තව දින ${nextServiceDate.difference(DateTime.now()).inDays} කින්',
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Last Service Card
                      if (lastServiceDate != null) ...[
                        _buildMilestoneCard(
                          title: 'අවසන් සර්විස් කිරීම (Last Service)',
                          date: lastServiceDate,
                          icon: Icons.history,
                          color: Colors.blueAccent,
                          subtitle:
                              'දින ${DateTime.now().difference(lastServiceDate).inDays} කට පෙර',
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Last Tire Change Card
                      if (lastTireDate != null) ...[
                        _buildMilestoneCard(
                          title: 'අවසන් ටයර් මාරුව (Tire Replacement)',
                          date: lastTireDate,
                          icon: Icons.tire_repair,
                          color: Colors.green,
                          subtitle:
                              'දින ${DateTime.now().difference(lastTireDate).inDays} කට පෙර',
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        _buildEmptyMilestoneCard(
                          title: 'ටයර් මාරු කිරීමක් සටහන් කර නොමැත',
                          subtitle:
                              'සැකසුම් පිටුවෙන් ටයර් මාරු කළ දිනය සටහන් කළ හැක.',
                          icon: Icons.tire_repair,
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestoneCard({
    required String title,
    required DateTime date,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansSinhala(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text('$subtitle • ${_dateFormat.format(date)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            DateFormat('yyyy-MM-dd').format(date),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMilestoneCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.grey),
        ),
        title: Text(
          title,
          style: GoogleFonts.notoSansSinhala(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.notoSansSinhala(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
