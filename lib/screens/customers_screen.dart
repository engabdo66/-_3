import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // دالة لجلب العملاء من قاعدة البيانات
  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final customers = await DatabaseHelper.instance.getCustomers();
    setState(() {
      _customers = customers;
      _isLoading = false;
    });
  }

  // نافذة منبثقة لإضافة عميل جديد
  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عميل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل *'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              final newCustomer = Customer(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
              );
              
              await DatabaseHelper.instance.insertCustomer(newCustomer);
              if (mounted) {
                Navigator.pop(context);
                _loadCustomers(); // إعادة تحميل القائمة
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة العملاء')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('لا يوجد عملاء مضافين بعد'))
              : ListView.builder(
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone.isNotEmpty ? customer.phone : 'لا يوجد رقم'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}