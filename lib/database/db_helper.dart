import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('invoices.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // جدول العملاء
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT
      )
    ''');

    // جدول الفواتير
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL,
        customerId INTEGER NOT NULL,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // جدول بنود الفاتورة
    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId INTEGER NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitPrice REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== عمليات العملاء ====================
  Future<int> insertCustomer(Customer customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  // ==================== عمليات الفواتير ====================
  Future<int> insertInvoice(Invoice invoice) async {
    final db = await instance.database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await instance.database;
    final result = await db.query('invoices', orderBy: 'date DESC');
    return result.map((json) => Invoice.fromMap(json)).toList();
  }

  Future<int> updateInvoiceStatus(int invoiceId, String status) async {
    final db = await instance.database;
    return await db.update(
      'invoices',
      {'status': status},
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // ==================== عمليات بنود الفاتورة ====================
  Future<int> insertInvoiceItem(InvoiceItem item) async {
    final db = await instance.database;
    return await db.insert('invoice_items', item.toMap());
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await instance.database;
    final result = await db.query(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    return result.map((json) => InvoiceItem.fromMap(json)).toList();
  }
// دالة لحفظ فاتورة كاملة (الفاتورة + بنودها) باستخدام Transaction
Future<int> createInvoiceWithItems(Invoice invoice, List<InvoiceItem> items) async {
  final db = await instance.database;
  
  return await db.transaction((txn) async {
    // 1. حفظ الفاتورة الأساسية
    final invoiceId = await txn.insert('invoices', invoice.toMap());

    // 2. حفظ بنود الفاتورة
    for (var item in items) {
      // ننشئ نسخة جديدة من البند مع معرف الفاتورة الجديد
      final itemMap = item.toMap();
      itemMap['invoiceId'] = invoiceId;
      await txn.insert('invoice_items', itemMap);
    }

    return invoiceId; // نرجع معرف الفاتورة
  });
}
// جلب عميل واحد بواسطة الـ ID
Future<Customer> getCustomerById(int id) async {
  final db = await instance.database;
  final result = await db.query(
    'customers',
    where: 'id = ?',
    whereArgs: [id],
  );
  return Customer.fromMap(result.first);
}
}