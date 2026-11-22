import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import 'add_order_screen.dart';
import 'add_expense_screen.dart';
import 'reset_pin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _currencyFormat = NumberFormat.currency(symbol: 'රු. ', decimalDigits: 2);
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Waruna Transport',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_reset, color: Colors.white),
            tooltip: 'PIN අංකය වෙනස් කරන්න',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPinScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(appProvider),
          _buildOrdersTab(appProvider),
          _buildExpensesTab(appProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.notoSansSinhala(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'මුල් පිටුව',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'ඇණවුම්',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'වියදම්',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'නව ඇණවුමක්',
                style: GoogleFonts.notoSansSinhala(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : _selectedIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    );
                  },
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'නව වියදමක්',
                    style: GoogleFonts.notoSansSinhala(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildHomeTab(AppProvider provider) {
    final totalOrdersRevenue = provider.orders.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final totalExpenses = provider.expenses.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final netBalance = totalOrdersRevenue - totalExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ව්‍යාපාර දළ සටහන (Summary)',
            style: GoogleFonts.notoSansSinhala(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'මුළු ආදායම',
                  amount: _currencyFormat.format(totalOrdersRevenue),
                  icon: Icons.trending_up,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'මුළු වියදම',
                  amount: _currencyFormat.format(totalExpenses),
                  icon: Icons.trending_down,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            title: 'ශුද්ධ ශේෂය (Net Balance)',
            amount: _currencyFormat.format(netBalance),
            icon: Icons.account_balance_wallet,
            color: netBalance >= 0 ? AppColors.primaryColor : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'ඉක්මන් ක්‍රියා (Quick Actions)',
            style: GoogleFonts.notoSansSinhala(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    'නව ඇණවුමක්',
                    style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    );
                  },
                  icon: const Icon(Icons.money_off),
                  label: Text(
                    'නව වියදමක්',
                    style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'මෑත ඇණවුම් (Recent Orders)',
            style: GoogleFonts.notoSansSinhala(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (provider.orders.isEmpty)
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text('තවම කිසිදු ඇණවුමක් ඇතුලත් කර නැත.'),
                ),
              ),
            )
          else
            ...provider.orders.take(5).map((order) => _buildOrderTile(order)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  radius: 18,
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(AppProvider provider) {
    if (provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'තවම කිසිදු ඇණවුමක් ඇතුලත් කර නැත.',
              style: GoogleFonts.notoSansSinhala(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(
                'නව ඇණවුමක් එක් කරන්න',
                style: GoogleFonts.notoSansSinhala(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80, left: 12, right: 12),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        return _buildOrderTile(provider.orders[index]);
      },
    );
  }

  Widget _buildExpensesTab(AppProvider provider) {
    if (provider.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'තවම කිසිදු වියදමක් ඇතුලත් කර නැත.',
              style: GoogleFonts.notoSansSinhala(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(
                'නව වියදමක් එක් කරන්න',
                style: GoogleFonts.notoSansSinhala(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80, left: 12, right: 12),
      itemCount: provider.expenses.length,
      itemBuilder: (context, index) {
        final expense = provider.expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              child: const Icon(Icons.local_gas_station, color: Colors.red),
            ),
            title: Text(
              expense.type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expense.note.isNotEmpty) Text(expense.note),
                Text(
                  _dateFormat.format(expense.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            trailing: Text(
              _currencyFormat.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    final isCredit = order.paymentStatus.toLowerCase() == 'credit';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
          child: const Icon(Icons.local_shipping, color: AppColors.primaryColor),
        ),
        title: Text(
          order.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.materialType} • ${_dateFormat.format(order.date)}'),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isCredit ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isCredit ? 'ණය (Credit)' : 'මුදල් (Cash)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.orange.shade900 : Colors.green.shade900,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(order.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCredit ? Colors.orange.shade800 : AppColors.primaryColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
