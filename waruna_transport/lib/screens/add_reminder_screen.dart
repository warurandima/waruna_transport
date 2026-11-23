import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderModel? existingReminder;

  const AddReminderScreen({super.key, this.existingReminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _notificationService = NotificationService();
  final _dateFormat = DateFormat('yyyy-MM-dd (EEEE)');

  late DateTime _selectedDate;
  String _materialType = 'වැලි (Sand)';
  bool _isLoading = false;

  bool get _isEditing => widget.existingReminder != null;

  final List<String> _materials = [
    'වැලි (Sand)',
    'ගල් (Metal)',
    'පස් (Soil)',
    'සිමෙන්ති (Cement)',
    'වෙනත් (Other)',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final r = widget.existingReminder!;
      _customerController.text = r.customerName;
      _quantityController.text = r.quantity;
      _selectedDate = r.targetDate;
      if (_materials.contains(r.materialType)) {
        _materialType = r.materialType;
      } else {
        _materialType = 'වෙනත් (Other)';
      }
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 1));
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'නියමිත දිනය තෝරන්න (Select Target Date)',
      cancelText: 'අවලංගු කරන්න',
      confirmText: 'තහවුරු කරන්න',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditing) {
        final updatedReminder = ReminderModel(
          id: widget.existingReminder!.id,
          targetDate: _selectedDate,
          customerName: _customerController.text.trim(),
          materialType: _materialType,
          quantity: _quantityController.text.trim(),
          isCompleted: widget.existingReminder!.isCompleted,
        );

        await _firestoreService.updateReminder(updatedReminder);
        await _notificationService.scheduleReminderNotification(
          updatedReminder,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('මතක් කිරීම සාර්ථකව යාවත්කාලීන කරන ලදී'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final reminder = ReminderModel(
          id: '',
          targetDate: _selectedDate,
          customerName: _customerController.text.trim(),
          materialType: _materialType,
          quantity: _quantityController.text.trim(),
          isCompleted: false,
        );

        await _firestoreService.addReminder(reminder);
        await _notificationService.scheduleReminderNotification(reminder);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('මතක් කිරීම සාර්ථකව සටහන් කරන ලදී (Reminder Saved)'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('දෝෂයක් සිදු විය: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'මතක් කිරීම සංස්කරණය' : 'නව මතක් කිරීමක් (New Reminder)',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target Date Picker
                      Text(
                        'බෙදාහැරීමේ දිනය (Delivery Target Date)',
                        style: GoogleFonts.notoSansSinhala(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateFormat.format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_month,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Customer Name Field
                      TextFormField(
                        controller: _customerController,
                        decoration: InputDecoration(
                          labelText: 'පාරිභෝගිකයාගේ නම (Customer Name)',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'පාරිභෝගිකයාගේ නම ඇතුලත් කරන්න';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Material Type Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _materialType,
                        decoration: InputDecoration(
                          labelText: 'ද්‍රව්‍ය වර්ගය (Material Type)',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _materials.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: Text(m),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _materialType = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity Field
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText:
                              'ප්‍රමාණය (Quantity e.g., ලෝඩ් 1 / කියුබ් 2)',
                          prefixIcon: const Icon(Icons.straighten),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ප්‍රමාණය ඇතුලත් කරන්න';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'යාවත්කාලීන කරන්න' : 'මතක් කිරීම සුරකින්න',
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
