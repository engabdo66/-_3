class Invoice {
  final int? id;
  final String invoiceNumber;
  final int customerId;
  final String date;
  final double totalAmount;
  final String status; // 'مدفوعة' أو 'غير مدفوعة'

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.date,
    required this.totalAmount,
    this.status = 'غير مدفوعة',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'date': date,
      'totalAmount': totalAmount,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoiceNumber'],
      customerId: map['customerId'],
      date: map['date'],
      totalAmount: map['totalAmount'],
      status: map['status'],
    );
  }
}