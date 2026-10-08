import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/pdf_service.dart'; // ← أضف هذا السطر
class InvoiceDetailsScreen extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  Customer? _customer;
  List<InvoiceItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // جلب بيانات العميل والبنود
    final customer = await DatabaseHelper.instance.getCustomerById(widget.invoice.customerId);
    final items = await DatabaseHelper.instance.getInvoiceItems(widget.invoice.id!);
    
    setState(() {
      _customer = customer;
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final date = DateFormat('yyyy/MM/dd').format(DateTime.parse(widget.invoice.date));

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الفاتورة ${widget.invoice.invoiceNumber}'),
        actions: [
          // زر تصدير الـ PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير كـ PDF',
            onPressed: () async {
              await PdfService.generateAndShareInvoice(
                invoice: widget.invoice,
                customer: _customer!,
                items: _items,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة معلومات العميل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('معلومات العميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text('الاسم: ${_customer!.name}'),
                    Text('الهاتف: ${_customer!.phone}'),
                    const SizedBox(height: 10),
                    Text('التاريخ: $date'),
                    Text('الحالة: ${widget.invoice.status}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // بطاقة البنود
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('البنود', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ..._items.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.description),
                      subtitle: Text('${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}'),
                      trailing: Text(item.totalPrice.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            // الإجمالي
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'الإجمالي الكلي: ${widget.invoice.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}