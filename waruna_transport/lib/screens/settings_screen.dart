import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isSavingService = false;

  Future<void> _pickLastServiceDate(DateTime currentLastDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentLastDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _isSavingService = true;
      });

      try {
        final nextDate = DateTime(picked.year, picked.month + 1, picked.day);
        await _firestoreService.updateServiceInfo(picked, nextDate);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('සර්විස් දිනයන් සාර්ථකව යාවත්කාලීන කරන ලදී'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('යාවත්කාලීන කිරීමේ දෝෂයක්: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSavingService = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'සැකසුම් (Settings)',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Setting Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: AppColors.primaryColor,
                  ),
                ),
                title: Text(
                  'අඳුරු තේමාව (Dark Mode)',
                  style: GoogleFonts.notoSansSinhala(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark Mode ක්‍රියාත්මකයි'
                      : 'Light Mode ක්‍රියාත්මකයි',
                ),
                value: themeProvider.isDarkMode,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (val) {
                  themeProvider.toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Service Reminder Card
            Text(
              'ලොරි රථ නඩත්තු සටහන් (Vehicle Service)',
              style: GoogleFonts.notoSansSinhala(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<ServiceModel?>(
              stream: _firestoreService.getServiceInfo(),
              builder: (context, snapshot) {
                final serviceInfo = snapshot.data;
                final lastDate = serviceInfo?.lastServiceDate ?? DateTime.now();
                final nextDate =
                    serviceInfo?.nextServiceDate ??
                    DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
                final daysRemaining = nextDate
                    .difference(DateTime.now())
                    .inDays;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(
                                Icons.build_circle,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ඊළඟ සර්විස් කිරීම (Next Service):',
                                    style: GoogleFonts.notoSansSinhala(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _dateFormat.format(nextDate),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: daysRemaining <= 5
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            daysRemaining < 0
                                ? 'සර්විස් දිනය දින ${-daysRemaining} කින් ප්‍රමාදයි!'
                                : daysRemaining == 0
                                ? 'අද සර්විස් දිනයයි!'
                                : 'තව දින $daysRemaining ක් ඉතිරිව ඇත (Next Service in $daysRemaining days)',
                            style: TextStyle(
                              color: daysRemaining <= 5
                                  ? Colors.red.shade900
                                  : Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'අවසන් සර්විස් දිනය:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _dateFormat.format(lastDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _isSavingService
                                  ? null
                                  : () => _pickLastServiceDate(lastDate),
                              icon: const Icon(Icons.edit_calendar),
                              label: Text(
                                'දිනය වෙනස් කරන්න',
                                style: GoogleFonts.notoSansSinhala(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
