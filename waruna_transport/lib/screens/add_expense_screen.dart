import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? existingExpense;

  const AddExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _noteController = TextEditingController();
  final _firestoreService = FirestoreService();

  final List<String> _types = const [
    'තෙල් (Fuel)',
    'නඩත්තු (Maintenance)',
    'ටයර් (Tire)',
    'වෙනත් (Other)',
  ];
  String _selectedType = 'තෙල් (Fuel)';
  bool _isSaving = false;

  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final expense = widget.existingExpense!;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _noteController.text = expense.note ?? '';

      final matchedType = _types.firstWhere(
        (t) =>
            t.toLowerCase().contains(expense.type.toLowerCase()) ||
            expense.type.toLowerCase().contains(t.split(' ')[0].toLowerCase()),
        orElse: () => '',
      );

      if (matchedType.isNotEmpty) {
        _selectedType = matchedType;
      } else {
        _selectedType = 'වෙනත් (Other)';
        _customTypeController.text = expense.customType ?? expense.type;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customTypeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
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
      final isOther = _selectedType.startsWith('වෙනත්');
      final finalType = isOther && _customTypeController.text.trim().isNotEmpty
          ? _customTypeController.text.trim()
          : _selectedType.split(' ')[0]; // Store clean Sinhala category

      if (_isEditing) {
        final updatedExpense = ExpenseModel(
          id: widget.existingExpense!.id,
          date: widget.existingExpense!.date,
          type: finalType,
          amount: amount,
          customType: isOther ? _customTypeController.text.trim() : null,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

        await _firestoreService.updateExpense(updatedExpense);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('වියදම සාර්ථකව යාවත්කාලීන කරන ලදී'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final expense = ExpenseModel(
          id: '',
          date: DateTime.now(),
          type: finalType,
          amount: amount,
          customType: isOther ? _customTypeController.text.trim() : null,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
        );

        await _firestoreService.addExpense(expense);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('වියදම සාර්ථකව සුරකින ලදී'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('දෝෂයක් ඇතිවිය: $e'),
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
          _isEditing ? 'වියදම සංස්කරණය (Edit Expense)' : 'නව වියදමක්',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
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
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'වියදම් වර්ගය (Expense Type)',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _types.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedType = val;
                            });
                          }
                        },
                      ),
                      if (_selectedType.startsWith('වෙනත්')) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customTypeController,
                          decoration: InputDecoration(
                            labelText: 'වෙනත් වර්ගය (Custom Type)',
                            prefixIcon: const Icon(Icons.edit_note),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedType.startsWith('වෙනත්') &&
                                (value == null || value.trim().isEmpty)) {
                              return 'කරුණාකර වියදම් වර්ගය ඇතුලත් කරන්න';
                            }
                            return null;
                          },
                        ),
                      ],
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
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'සටහන (Note - Optional)',
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
                        _isEditing ? 'යාවත්කාලීන කරන්න' : 'සුරකින්න',
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
