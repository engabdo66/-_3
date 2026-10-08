import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/invoice.dart';
import 'create_invoice_screen.dart';
import 'invoice_details_screen.dart'; // تأكد من استيراد شاشة التفاصيل

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    final invoices = await DatabaseHelper.instance.getInvoices();
    setState(() {
      _invoices = invoices;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الفواتير')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? const Center(child: Text('لا توجد فواتير حتى الآن'))
              : ListView.builder(
                  itemCount: _invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = _invoices[index];
                    final date = DateFormat('yyyy/MM/dd').format(DateTime.parse(invoice.date));
                    final isPaid = invoice.status == 'مدفوعة';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid ? Colors.green : Colors.orange,
                          child: Icon(
                            isPaid ? Icons.check : Icons.pending,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('فاتورة رقم: ${invoice.invoiceNumber}'),
                        subtitle: Text('التاريخ: $date\nالإجمالي: ${invoice.totalAmount.toStringAsFixed(2)}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailsScreen(invoice: invoice),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
          );
          if (result == true) {
            _loadInvoices();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('فاتورة جديدة'),
      ),
    );
  }
}