import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';

class PdfService {
  Future<void> generateMonthlyReport(
    List<OrderModel> orders,
    List<ExpenseModel> expenses,
  ) async {
    final pdf = pw.Document();

    final totalIncome = orders.fold<double>(0.0, (sum, o) => sum + o.amount);
    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, e) => sum + e.amount,
    );
    final netProfit = totalIncome - totalExpenses;

    final currencyFormat = NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('yyyy-MM-dd');
    final generatedOn = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'WARUNA TRANSPORT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Monthly Business Report',
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Generated: $generatedOn',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Income',
                    currencyFormat.format(totalIncome),
                    PdfColors.teal,
                  ),
                  _buildSummaryItem(
                    'Total Expenses',
                    currencyFormat.format(totalExpenses),
                    PdfColors.redAccent,
                  ),
                  _buildSummaryItem(
                    'Net Profit',
                    currencyFormat.format(netProfit),
                    netProfit >= 0 ? PdfColors.teal800 : PdfColors.orange800,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Orders Summary (${orders.length})',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (orders.isEmpty)
              pw.Text(
                'No orders recorded.',
                style: const pw.TextStyle(color: PdfColors.grey600),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Material', 'Type', 'Status', 'Amount'],
                data: orders.map((o) {
                  return [
                    dateFormat.format(o.date),
                    o.materialType,
                    o.isCredit ? 'Credit' : 'Cash',
                    o.isCompleted ? 'Completed' : 'Pending',
                    currencyFormat.format(o.amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {4: pw.Alignment.centerRight},
              ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Expenses Summary (${expenses.length})',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (expenses.isEmpty)
              pw.Text(
                'No expenses recorded.',
                style: const pw.TextStyle(color: PdfColors.grey600),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Note', 'Amount'],
                data: expenses.map((e) {
                  final expenseType =
                      (e.customType != null && e.customType!.isNotEmpty)
                      ? '${e.type} (${e.customType})'
                      : e.type;
                  final noteText = (e.note == null || e.note!.isEmpty)
                      ? '-'
                      : e.note!;
                  return [
                    dateFormat.format(e.date),
                    expenseType,
                    noteText,
                    currencyFormat.format(e.amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey700,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {3: pw.Alignment.centerRight},
              ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Waruna_Transport_Monthly_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildSummaryItem(String label, String value, PdfColor valueColor) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
