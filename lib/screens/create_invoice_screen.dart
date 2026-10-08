import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  // قائمة العملاء لاختيار واحد منهم
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  
  // قائمة بنود الفاتورة
  List<InvoiceItem> _items = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    // إضافة بند فارغ افتراضي
    _addNewItem();
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper.instance.getCustomers();
    setState(() {
      _customers = customers;
      _isLoading = false;
    });
  }

  // دالة لإضافة بند جديد فارغ
  void _addNewItem() {
    setState(() {
      _items.add(InvoiceItem(
        invoiceId: 0, // سيتم تحديثه عند الحفظ
        description: '',
        quantity: 1,
        unitPrice: 0,
      ));
    });
  }

  // دالة لحذف بند
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // حساب الإجمالي الكلي
  double get _grandTotal {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  // دالة الحفظ
  Future<void> _saveInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار العميل أولاً'), backgroundColor: Colors.red),
      );
      return;
    }

    // التحقق من أن البنود ليست فارغة
    bool hasValidItems = _items.any((item) => item.description.isNotEmpty && item.unitPrice > 0);
    if (!hasValidItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة بند واحد على الأقل بسعر صحيح'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // إنشاء رقم فاتورة فريد (يمكن تخصيصه لاحقاً)
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    final newInvoice = Invoice(
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer!.id!,
      date: DateTime.now().toIso8601String(),
      totalAmount: _grandTotal,
      status: 'غير مدفوعة',
    );

    // حفظ الفاتورة والبنود في قاعدة البيانات
    await DatabaseHelper.instance.createInvoiceWithItems(newInvoice, _items);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الفاتورة بنجاح'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // نرجع true لتحديث القائمة
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _customers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة جديدة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveInvoice,
            tooltip: 'حفظ الفاتورة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== قسم اختيار العميل ====================
            const Text('بيانات العميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  hint: const Text('اختر العميل'),
                  value: _selectedCustomer,
                  isExpanded: true,
                  items: _customers.map((customer) {
                    return DropdownMenuItem(
                      value: customer,
                      child: Text(customer.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomer = value;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ==================== قسم بنود الفاتورة ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('بنود الفاتورة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة بند'),
                ),
              ],
            ),
            
            // عرض البنود
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.description,
                                decoration: const InputDecoration(labelText: 'وصف المنتج/الخدمة'),
                                onChanged: (value) => item.description = value, // ملاحظة: هذا لن يحدث الواجهة فوراً لكنه يحفظ القيمة
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item.quantity.toString(),
                                decoration: const InputDecoration(labelText: 'الكمية'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  item.quantity = double.tryParse(value) ?? 1;
                                  setState(() {}); // تحديث الإجمالي
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                initialValue: item.unitPrice.toString(),
                                decoration: const InputDecoration(labelText: 'السعر'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  item.unitPrice = double.tryParse(value) ?? 0;
                                  setState(() {}); // تحديث الإجمالي
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'الإجمالي: ${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Divider(thickness: 2),
            
            // ==================== قسم الإجمالي النهائي ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الكلي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  _grandTotal.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('حفظ الفاتورة', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}