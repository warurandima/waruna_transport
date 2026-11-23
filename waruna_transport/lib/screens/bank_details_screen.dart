import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/bank_account_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'බැංකු ගිණුම්',
          style: GoogleFonts.notoSansSinhala(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<BankAccountModel>>(
        stream: firestoreService.getBankAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snapshot.data ?? [];
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'තවම කිසිදු බැංකු ගිණුමක් ඇතුලත් කර නැත.',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'පහත බොත්තම ඔබා නව ගිණුමක් එක් කරන්න.',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).cardColor,
                        AppColors.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            radius: 20,
                            child: const Icon(
                              Icons.account_balance,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.bankName,
                                  style: GoogleFonts.notoSansSinhala(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (account.branchName.isNotEmpty)
                                  Text(
                                    'ශාඛාව (Branch): ${account.branchName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.blueGrey,
                            onPressed: () => _showAccountDialog(
                              context,
                              firestoreService,
                              account: account,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: Colors.redAccent,
                            onPressed: () => _confirmDelete(
                              context,
                              firestoreService,
                              account.id,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ගිණුම් අංකය (Account Number)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  account.accountNumber,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: 'ගිණුම් අංකය පිටපත් කරන්න (Copy)',
                            color: AppColors.primaryColor,
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: account.accountNumber),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'ගිණුම් අංකය පිටපත් කරගන්නා ලදී.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ගිණුම් හිමියාගේ නම (Account Holder)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        account.accountName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 350.ms).slideY(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'නව ගිණුමක්',
          style: GoogleFonts.notoSansSinhala(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () => _showAccountDialog(context, firestoreService),
      ),
    );
  }

  void _showAccountDialog(
    BuildContext context,
    FirestoreService firestoreService, {
    BankAccountModel? account,
  }) {
    final formKey = GlobalKey<FormState>();
    final isEditing = account != null;

    final accountNameController = TextEditingController(
      text: account?.accountName ?? '',
    );
    final accountNumberController = TextEditingController(
      text: account?.accountNumber ?? '',
    );
    final bankNameController = TextEditingController(
      text: account?.bankName ?? '',
    );
    final branchNameController = TextEditingController(
      text: account?.branchName ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'ගිණුම සංස්කරණය කරන්න' : 'නව බැංකු ගිණුමක්',
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankNameController,
                    decoration: InputDecoration(
                      labelText: 'බැංකුවේ නම (Bank Name)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'බැංකුවේ නම ඇතුලත් කරන්න'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ගිණුම් අංකය (Account Number)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'ගිණුම් අංකය ඇතුලත් කරන්න'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accountNameController,
                    decoration: InputDecoration(
                      labelText: 'ගිණුම් හිමියාගේ නම (Account Name)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'ගිණුම් හිමියාගේ නම ඇතුලත් කරන්න'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: branchNameController,
                    decoration: InputDecoration(
                      labelText: 'ශාඛාව (Branch Name)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final newModel = BankAccountModel(
                        id: account?.id ?? '',
                        accountName: accountNameController.text.trim(),
                        accountNumber: accountNumberController.text.trim(),
                        bankName: bankNameController.text.trim(),
                        branchName: branchNameController.text.trim(),
                      );
                      if (isEditing) {
                        await firestoreService.updateBankAccount(newModel);
                      } else {
                        await firestoreService.addBankAccount(newModel);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'යාවත්කාලීන කරන්න' : 'සුරකින්න (Save)',
                      style: GoogleFonts.notoSansSinhala(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    FirestoreService firestoreService,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'ගිණුම මකා දැමීම',
          style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'මෙම බැංකු ගිණුම මකා දැමීමට ඔබට විශ්වාසද?',
          style: GoogleFonts.notoSansSinhala(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('අවලංගු කරන්න', style: GoogleFonts.notoSansSinhala()),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestoreService.deleteBankAccount(id);
              if (ctx.mounted) Navigator.pop(ctx);
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
