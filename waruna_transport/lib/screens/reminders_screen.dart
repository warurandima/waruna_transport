import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final dateFormat = DateFormat('yyyy-MM-dd (EEEE)');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<ReminderModel>>(
        stream: firestoreService.getReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'තවම කිසිදු මතක් කිරීමක් ඇතුලත් කර නැත.',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 80,
              left: 12,
              right: 12,
            ),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final isDone = reminder.isCompleted;

              return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: isDone ? 0 : 2,
                    color: isDone
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: isDone
                          ? BorderSide(color: Colors.grey.shade300)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Checkbox(
                        value: isDone,
                        activeColor: AppColors.primaryColor,
                        onChanged: (val) {
                          if (val != null) {
                            firestoreService.toggleReminderCompletion(
                              reminder.id,
                              val,
                            );
                          }
                        },
                      ),
                      title: Text(
                        '${reminder.customerName} - ${reminder.materialType}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: isDone ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ප්‍රමාණය: ${reminder.quantity}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDone
                                    ? Colors.grey
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: isDone
                                      ? Colors.grey
                                      : AppColors.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateFormat.format(reminder.targetDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDone
                                        ? Colors.grey
                                        : AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(
                    delay: (index < 10 ? index * 50 : 0).ms,
                    duration: 400.ms,
                  )
                  .slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}
