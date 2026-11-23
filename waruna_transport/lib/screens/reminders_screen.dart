import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('yyyy-MM-dd (EEEE)');
  final _dateOnlyFormat = DateFormat('yyyy-MM-dd');
  String _selectedFilter = 'සියල්ල';

  Widget _buildDateHeader(String dateStr) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            dateStr,
            style: GoogleFonts.notoSansSinhala(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<ReminderModel>>(
        stream: _firestoreService.getReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rawReminders = snapshot.data ?? [];

          // Apply filter chips
          var filteredReminders = rawReminders;
          if (_selectedFilter == 'ක්‍රියාත්මක වෙමින්') {
            filteredReminders = rawReminders
                .where((r) => !r.isCompleted)
                .toList();
          } else if (_selectedFilter == 'සම්පූර්ණයි') {
            filteredReminders = rawReminders
                .where((r) => r.isCompleted)
                .toList();
          }

          // Sort by targetDate descending
          filteredReminders.sort(
            (a, b) => b.targetDate.compareTo(a.targetDate),
          );

          return Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: ['සියල්ල', 'ක්‍රියාත්මක වෙමින්', 'සම්පූර්ණයි'].map((
                    filter,
                  ) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter,
                          style: GoogleFonts.notoSansSinhala(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        checkmarkColor: Colors.white,
                        onSelected: (_) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (filteredReminders.isEmpty)
                Expanded(
                  child: Center(
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
                          'මතක් කිරීම් නොමැත.',
                          style: GoogleFonts.notoSansSinhala(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 80,
                      left: 12,
                      right: 12,
                    ),
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];
                      final isDone = reminder.isCompleted;

                      final currentDateStr = _dateOnlyFormat.format(
                        reminder.targetDate,
                      );
                      final prevDateStr = index > 0
                          ? _dateOnlyFormat.format(
                              filteredReminders[index - 1].targetDate,
                            )
                          : null;
                      final showHeader =
                          index == 0 || currentDateStr != prevDateStr;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader) _buildDateHeader(currentDateStr),
                          Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: isDone ? 0 : 2,
                                color: isDone
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
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
                                        _firestoreService
                                            .toggleReminderCompletion(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            Expanded(
                                              child: Text(
                                                _dateFormat.format(
                                                  reminder.targetDate,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDone
                                                      ? Colors.grey
                                                      : AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        Navigator.push(
                                          context,
                                          SlideFadePageRoute(
                                            page: AddReminderScreen(
                                              existingReminder: reminder,
                                            ),
                                          ),
                                        );
                                      } else if (val == 'delete') {
                                        _confirmDeleteReminder(reminder);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text('සංස්කරණය'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('මකන්න'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fade(
                                delay: (index < 10 ? index * 40 : 0).ms,
                                duration: 350.ms,
                              )
                              .slideX(begin: 0.05),
                        ],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteReminder(ReminderModel reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'මතක් කිරීම මකා දැමීම',
          style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'මෙම මතක් කිරීම (${reminder.customerName} - ${reminder.materialType}) මකා දැමීමට ඔබට විශ්වාසද?',
          style: GoogleFonts.notoSansSinhala(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('අවලංගු කරන්න', style: GoogleFonts.notoSansSinhala()),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteReminder(reminder.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('මතක් කිරීම මකා දමන ලදී'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              'මකන්න',
              style: GoogleFonts.notoSansSinhala(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
