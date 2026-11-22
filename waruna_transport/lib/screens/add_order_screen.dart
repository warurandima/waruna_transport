import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _debtorNameController = TextEditingController();
  final _debtorPhoneController = TextEditingController();
  final _firestoreService = FirestoreService();

  final List<String> _materials = const ['වැලි', 'ගල්', 'ගඩොල්', 'සිමෙන්ති'];
  String _selectedMaterial = 'වැලි';
  bool _isCredit = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _debtorNameController.dispose();
    _debtorPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර වලංගු මුදලක් ඇතුලත් කරන්න'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final order = OrderModel(
        id: '',
        date: DateTime.now(),
        materialType: _selectedMaterial,
        amount: amount,
        isCredit: _isCredit,
        isCompleted: false,
        debtorName: _isCredit ? _debtorNameController.text.trim() : null,
        debtorPhone: _isCredit ? _debtorPhoneController.text.trim() : null,
      );

      await _firestoreService.addOrder(order);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ඇණවුම සාර්ථකව සුරකින ලදී'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ඇණවුම සුරැකීමේදී දෝෂයක් ඇතිවිය: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
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
          'නව ඇණවුමක්',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
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
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedMaterial,
                        decoration: InputDecoration(
                          labelText: 'ද්‍රව්‍ය වර්ගය (Material)',
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
                              _selectedMaterial = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'මුදල (රු.) - Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'මුදල ඇතුලත් කරන්න';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'වලංගු මුදලක් ඇතුලත් කරන්න';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'ණයට ද? (Is Credit?)',
                          style: GoogleFonts.notoSansSinhala(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _isCredit
                              ? 'ණය පදනම මත (Credit Order)'
                              : 'මුදල් ලැබුණි (Cash)',
                          style: TextStyle(
                            color: _isCredit
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: _isCredit,
                        activeThumbColor: Colors.orange,
                        onChanged: (val) {
                          setState(() {
                            _isCredit = val;
                          });
                        },
                      ),
                      if (_isCredit) ...[
                        const Divider(height: 24),
                        TextFormField(
                          controller: _debtorNameController,
                          decoration: InputDecoration(
                            labelText: 'ණයගැතියාගේ නම (Debtor Name)',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (_isCredit &&
                                (value == null || value.trim().isEmpty)) {
                              return 'කරුණාකර ණයගැතියාගේ නම ඇතුලත් කරන්න';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _debtorPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'දුරකථන අංකය (Phone Number)',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (_isCredit &&
                                (value == null || value.trim().isEmpty)) {
                              return 'කරුණාකර දුරකථන අංකය ඇතුලත් කරන්න';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'සුරකින්න',
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
