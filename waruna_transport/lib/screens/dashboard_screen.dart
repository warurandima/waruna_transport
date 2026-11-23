import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';
import '../models/service_model.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/pdf_service.dart';
import '../utils/app_colors.dart';
import '../utils/page_transitions.dart';
import 'add_order_screen.dart';
import 'add_expense_screen.dart';
import 'add_reminder_screen.dart';
import 'bank_details_screen.dart';
import 'debtors_screen.dart';
import 'reminders_screen.dart';
import 'reset_pin_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final _firestoreService = FirestoreService();
  final _pdfService = PdfService();
  final _currencyFormat = NumberFormat.currency(
    symbol: 'රු. ',
    decimalDigits: 2,
  );
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  // Home Tab Month/Year selection
  late DateTime _selectedMonth;

  // Orders Tab Filter
  String _orderFilter = 'සියල්ල';

  // Expenses Tab Filter
  String _expenseFilter = 'සියල්ල';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  String _getMonthSinhalaName(int month) {
    const months = [
      '',
      'ජනවාරි (Jan)',
      'පෙබරවාරි (Feb)',
      'මාර්තු (Mar)',
      'අප්‍රේල් (Apr)',
      'මැයි (May)',
      'ජූනි (Jun)',
      'ජූලි (Jul)',
      'අගෝස්තු (Aug)',
      'සැප්තැම්බර් (Sep)',
      'ඔක්තෝබර් (Oct)',
      'නොවැම්බර් (Nov)',
      'දෙසැම්බර් (Dec)',
    ];
    return months[month];
  }

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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Waruna Transport',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'සැකසුම් (Settings)',
            onPressed: () {
              Navigator.push(
                context,
                SlideFadePageRoute(page: const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset, color: Colors.white),
            tooltip: 'PIN අංකය වෙනස් කරන්න',
            onPressed: () {
              Navigator.push(
                context,
                SlideFadePageRoute(page: const ResetPinScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.secondaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 54,
                      width: 54,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'WARUNA TRANSPORT',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'වරුණ ට්‍රාන්ස්පෝර්ට්',
                    style: GoogleFonts.notoSansSinhala(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primaryColor),
              title: Text(
                'මුල් පිටුව',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_shipping,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'ඇණවුම්',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.redAccent),
              title: Text(
                'වියදම්',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm, color: Colors.orange),
              title: Text(
                'මතක් කිරීම්',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.teal),
              title: Text(
                'ණය කළමනාකරණය',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.account_balance,
                color: AppColors.primaryColor,
              ),
              title: Text(
                'බැංකු ගිණුම් (Bank Accounts)',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const BankDetailsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: Text(
                'සැකසුම් (Settings)',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.blueGrey),
              title: Text(
                'PIN අංකය වෙනස් කරන්න',
                style: GoogleFonts.notoSansSinhala(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const ResetPinScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildOrdersTab(),
          _buildExpensesTab(),
          const RemindersScreen(),
          const DebtorsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.notoSansSinhala(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.notoSansSinhala(),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'මුල් පිටුව'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'ඇණවුම්',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'වියදම්',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'මතක් කිරීම්',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'ණය'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const AddOrderScreen()),
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
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
          : _selectedIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const AddExpenseScreen()),
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
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
          : _selectedIndex == 3
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideFadePageRoute(page: const AddReminderScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_alarm, color: Colors.white),
              label: Text(
                'නව මතක් කිරීමක්',
                style: GoogleFonts.notoSansSinhala(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
          : null,
    );
  }

  Widget _buildHomeTab() {
    final now = DateTime.now();

    return StreamBuilder<List<OrderModel>>(
      stream: _firestoreService.getOrders(),
      builder: (context, ordersSnapshot) {
        return StreamBuilder<List<ExpenseModel>>(
          stream: _firestoreService.getExpenses(),
          builder: (context, expensesSnapshot) {
            final orders = ordersSnapshot.data ?? [];
            final expenses = expensesSnapshot.data ?? [];

            // Filter by the selected month from global dropdown
            final selectedMonthOrders = orders
                .where(
                  (o) =>
                      o.date.year == _selectedMonth.year &&
                      o.date.month == _selectedMonth.month,
                )
                .toList();
            final selectedMonthExpenses = expenses
                .where(
                  (e) =>
                      e.date.year == _selectedMonth.year &&
                      e.date.month == _selectedMonth.month,
                )
                .toList();

            final monthlyIncome = selectedMonthOrders.fold<double>(
              0.0,
              (sum, item) => sum + item.amount,
            );
            final monthlyExpense = selectedMonthExpenses.fold<double>(
              0.0,
              (sum, item) => sum + item.amount,
            );
            final monthlyProfit = monthlyIncome - monthlyExpense;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service Reminder Banner from Firestore
                  StreamBuilder<ServiceModel?>(
                    stream: _firestoreService.getServiceInfo(),
                    builder: (context, serviceSnapshot) {
                      final serviceInfo = serviceSnapshot.data;
                      if (serviceInfo == null) {
                        return const SizedBox.shrink();
                      }
                      final daysRemaining = serviceInfo.nextServiceDate
                          .difference(DateTime.now())
                          .inDays;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: daysRemaining <= 5
                              ? Colors.red.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: daysRemaining <= 5
                                ? Colors.red.shade300
                                : Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.build_circle,
                              color: daysRemaining <= 5
                                  ? Colors.red
                                  : Colors.blueAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                daysRemaining < 0
                                    ? 'සර්විස් දිනය දින ${-daysRemaining} කින් ප්‍රමාදයි!'
                                    : daysRemaining == 0
                                    ? 'අද ලොරි රථය සර්විස් කළ යුතු දිනයයි!'
                                    : 'ඊළඟ සර්විස් කිරීම දින $daysRemaining කින් (Next Service in $daysRemaining days)',
                                style: TextStyle(
                                  color: daysRemaining <= 5
                                      ? Colors.red.shade900
                                      : Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tomorrow's Orders Reminder Card
                  StreamBuilder<List<ReminderModel>>(
                    stream: _firestoreService.getReminders(),
                    builder: (context, snapshot) {
                      final allReminders = snapshot.data ?? [];
                      final tomorrow = DateTime.now().add(
                        const Duration(days: 1),
                      );
                      final tomorrowReminders = allReminders.where((r) {
                        return r.targetDate.year == tomorrow.year &&
                            r.targetDate.month == tomorrow.month &&
                            r.targetDate.day == tomorrow.day;
                      }).toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.withValues(
                                      alpha: 0.15,
                                    ),
                                    radius: 16,
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.blueAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'හෙට දිනට නියමිත ඇණවුම්',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.notoSansSinhala(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              if (tomorrowReminders.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    'හෙට දිනට ඇණවුම් නොමැත.',
                                    style: GoogleFonts.notoSansSinhala(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              else
                                ...tomorrowReminders.map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          r.isCompleted
                                              ? Icons.check_circle
                                              : Icons.arrow_right,
                                          color: r.isCompleted
                                              ? Colors.green
                                              : AppColors.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${r.customerName} - ${r.materialType} (${r.quantity})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              decoration: r.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: r.isCompleted
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      );
                    },
                  ),

                  // Month Selection Header & Global Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'මාසික දළ සටහන (Monthly Summary)',
                          style: GoogleFonts.notoSansSinhala(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Prominent Global Dropdown for Month/Year
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<DateTime>(
                              value: _selectedMonth,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primaryColor,
                              ),
                              items: List.generate(12, (index) {
                                final d = DateTime(
                                  now.year,
                                  now.month - index,
                                  1,
                                );
                                return DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    '${_getMonthSinhalaName(d.month)} ${d.year}',
                                    style: GoogleFonts.notoSansSinhala(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedMonth = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildSummaryCard(
                              title: 'මාසික ආදායම (Monthly Income)',
                              amount: _currencyFormat.format(monthlyIncome),
                              icon: Icons.trending_up,
                              color: Colors.teal,
                            ).animate().scale(
                              delay: 100.ms,
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _buildSummaryCard(
                              title: 'මාසික වියදම (Monthly Expenses)',
                              amount: _currencyFormat.format(monthlyExpense),
                              icon: Icons.trending_down,
                              color: Colors.redAccent,
                            ).animate().scale(
                              delay: 200.ms,
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    title: 'මාසික ශුද්ධ ලාභය (Monthly Net Profit)',
                    amount: _currencyFormat.format(monthlyProfit),
                    icon: Icons.account_balance_wallet,
                    color: monthlyProfit >= 0
                        ? AppColors.primaryColor
                        : Colors.orange,
                  ).animate().scale(
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      _pdfService.generateMonthlyReport(
                        selectedMonthOrders,
                        selectedMonthExpenses,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text(
                      'තෝරාගත් මාසයේ වාර්තාව (PDF Report)',
                      style: GoogleFonts.notoSansSinhala(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().scale(
                    delay: 400.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'මෑත ඇණවුම් (Recent Orders)',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (orders.isEmpty)
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'තවම කිසිදු ඇණවුමක් ඇතුලත් කර නැත.',
                            style: GoogleFonts.notoSansSinhala(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...orders.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final order = entry.value;
                      return _buildOrderTile(order)
                          .animate()
                          .fade(delay: (index * 80).ms, duration: 400.ms)
                          .slideX(begin: 0.1);
                    }),
                ],
              ),
            );
          },
        );
      },
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
                      fontSize: 12,
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
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return StreamBuilder<List<OrderModel>>(
      stream: _firestoreService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawOrders = snapshot.data ?? [];

        // Apply filter chips
        var filteredOrders = rawOrders;
        if (_orderFilter == 'ක්‍රියාත්මක වෙමින්') {
          filteredOrders = rawOrders.where((o) => !o.isCompleted).toList();
        } else if (_orderFilter == 'සම්පූර්ණයි') {
          filteredOrders = rawOrders.where((o) => o.isCompleted).toList();
        }

        // Sort by date descending
        filteredOrders.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['සියල්ල', 'ක්‍රියාත්මක වෙමින්', 'සම්පූර්ණයි'].map((
                  filter,
                ) {
                  final isSelected = _orderFilter == filter;
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
                        setState(() => _orderFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            if (filteredOrders.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ඇණවුම් නොමැත.',
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
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final currentDateStr = _dateOnlyFormat.format(order.date);
                    final prevDateStr = index > 0
                        ? _dateOnlyFormat.format(filteredOrders[index - 1].date)
                        : null;
                    final showHeader =
                        index == 0 || currentDateStr != prevDateStr;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) _buildDateHeader(currentDateStr),
                        _buildOrderTile(order)
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
    );
  }

  Widget _buildExpensesTab() {
    return StreamBuilder<List<ExpenseModel>>(
      stream: _firestoreService.getExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final rawExpenses = snapshot.data ?? [];

        // Apply filter chips
        var filteredExpenses = rawExpenses;
        if (_expenseFilter == 'තෙල්') {
          filteredExpenses = rawExpenses
              .where((e) => e.type == 'තෙල්' || e.type == 'Fuel')
              .toList();
        } else if (_expenseFilter == 'නඩත්තු') {
          filteredExpenses = rawExpenses
              .where((e) => e.type == 'නඩත්තු' || e.type == 'Maintenance')
              .toList();
        } else if (_expenseFilter == 'වෙනත්') {
          filteredExpenses = rawExpenses
              .where(
                (e) =>
                    e.type != 'තෙල්' &&
                    e.type != 'Fuel' &&
                    e.type != 'නඩත්තු' &&
                    e.type != 'Maintenance',
              )
              .toList();
        }

        // Sort by date descending
        filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['සියල්ල', 'තෙල්', 'නඩත්තු', 'වෙනත්'].map((filter) {
                  final isSelected = _expenseFilter == filter;
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
                      selectedColor: Colors.redAccent,
                      checkmarkColor: Colors.white,
                      onSelected: (_) {
                        setState(() => _expenseFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            if (filteredExpenses.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'වියදම් නොමැත.',
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
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    final titleText =
                        expense.customType != null &&
                            expense.customType!.isNotEmpty
                        ? expense.customType!
                        : expense.type;

                    final currentDateStr = _dateOnlyFormat.format(expense.date);
                    final prevDateStr = index > 0
                        ? _dateOnlyFormat.format(
                            filteredExpenses[index - 1].date,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: const Icon(
                                    Icons.money_off,
                                    color: Colors.red,
                                  ),
                                ),
                                title: Text(
                                  titleText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (expense.note != null &&
                                        expense.note!.isNotEmpty)
                                      Text(expense.note!),
                                    Text(
                                      _dateFormat.format(expense.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
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
    );
  }

  Widget _buildOrderTile(OrderModel order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: order.isCompleted
              ? Colors.green.withValues(alpha: 0.15)
              : AppColors.primaryColor.withValues(alpha: 0.15),
          child: Icon(
            order.isCompleted ? Icons.check_circle : Icons.local_shipping,
            color: order.isCompleted ? Colors.green : AppColors.primaryColor,
          ),
        ),
        title: Text(
          order.materialType,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dateFormat.format(order.date),
              overflow: TextOverflow.ellipsis,
            ),
            if (order.debtorName != null && order.debtorName!.isNotEmpty)
              Text(
                'පාරිභෝගිකයා: ${order.debtorName}',
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: order.isCredit
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.isCredit ? 'ණයට (Credit)' : 'මුදල් (Cash)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: order.isCredit
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: order.isCompleted
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.isCompleted ? 'සම්පූර්ණයි' : 'ක්‍රියාත්මක වෙමින්',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: order.isCompleted
                          ? Colors.blue.shade900
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currencyFormat.format(order.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: order.isCredit
                    ? Colors.orange.shade800
                    : AppColors.primaryColor,
                fontSize: 15,
              ),
            ),
            if (!order.isCompleted)
              InkWell(
                onTap: () async {
                  await _firestoreService.markOrderCompleted(order.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ඇණවුම සම්පූර්ණ කරන ලදී'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.teal,
                        size: 14,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'සම්පූර්ණ කරන්න',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
