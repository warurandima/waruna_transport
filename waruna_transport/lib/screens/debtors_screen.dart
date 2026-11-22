import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/debtor_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class DebtorsScreen extends StatelessWidget {
  const DebtorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(
      symbol: 'රු. ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<DebtorModel>>(
        stream: firestoreService.getDebtors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final debtors = snapshot.data ?? [];
          if (debtors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'තවම කිසිදු ණයගැතියෙකු නැත.',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalOutstanding = debtors.fold<double>(
            0.0,
            (sum, item) => sum + item.totalDue,
          );

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'මුළු අයවිය යුතු ණය (Total Debt)',
                            style: GoogleFonts.notoSansSinhala(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalOutstanding),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: debtors.length,
                  itemBuilder: (context, index) {
                    final debtor = debtors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(Icons.person, color: Colors.orange),
                        ),
                        title: Text(
                          debtor.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(debtor.phone),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(debtor.totalDue),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: debtor.totalDue > 0
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              debtor.totalDue > 0 ? 'හිඟ මුදල' : 'පියවා ඇත',
                              style: TextStyle(
                                fontSize: 11,
                                color: debtor.totalDue > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DebtorDetailScreen(phone: debtor.phone),
                            ),
                          );
                        },
                      ),
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
}

class DebtorDetailScreen extends StatefulWidget {
  final String phone;

  const DebtorDetailScreen({super.key, required this.phone});

  @override
  State<DebtorDetailScreen> createState() => _DebtorDetailScreenState();
}

class _DebtorDetailScreenState extends State<DebtorDetailScreen> {
  final _paymentController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _currencyFormat = NumberFormat.currency(
    symbol: 'රු. ',
    decimalDigits: 2,
  );
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  bool _isProcessing = false;

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment(DebtorModel debtor) async {
    final amount = double.tryParse(_paymentController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('කරුණාකර වලංගු ගෙවීම් මුදලක් ඇතුලත් කරන්න'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > debtor.totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ගෙවීමේ මුදල හිඟ මුදලට වඩා වැඩි විය නොහැක'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestoreService.payDebt(debtor.phone, amount);
      _paymentController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_currencyFormat.format(amount)} ක ණය මුදල සාර්ථකව පියවන ලදී',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ගෙවීම සටහන් කිරීමේදී දෝෂයක්: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
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
          'ණය විස්තර',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<DebtorModel?>(
        stream: _firestoreService.getDebtor(widget.phone),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final debtor = snapshot.data;
          if (debtor == null) {
            return const Center(child: Text('ණයගැතියා සොයාගත නොහැකි විය'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                        Text(
                          debtor.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'දුරකථන අංකය: ${debtor.phone}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'හිඟ මුදල (Total Due):',
                              style: GoogleFonts.notoSansSinhala(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currencyFormat.format(debtor.totalDue),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: debtor.totalDue > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (debtor.totalDue > 0)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ණය පියවීම සටහන් කරන්න (Record Payment)',
                            style: GoogleFonts.notoSansSinhala(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _paymentController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'ගෙවන මුදල (රු.)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _handlePayment(debtor),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'ගෙවන්න',
                                        style: GoogleFonts.notoSansSinhala(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'ගනුදෙනු ඉතිහාසය (Transaction History)',
                  style: GoogleFonts.notoSansSinhala(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (debtor.transactions.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('ගනුදෙනු ඉතිහාසයක් නැත')),
                    ),
                  )
                else
                  ...debtor.transactions.reversed.map((t) {
                    final amount = (t['amount'] is num)
                        ? (t['amount'] as num).toDouble()
                        : 0.0;
                    final isPayment = amount < 0;
                    final dateStr = t['date'] ?? '';
                    DateTime? dt = DateTime.tryParse(dateStr);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPayment
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          child: Icon(
                            isPayment
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isPayment ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(
                          t['description'] ?? 'ගනුදෙනුව',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: dt != null
                            ? Text(_dateFormat.format(dt))
                            : Text(dateStr),
                        trailing: Text(
                          _currencyFormat.format(amount.abs()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPayment
                                ? Colors.green
                                : Colors.orange.shade900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
