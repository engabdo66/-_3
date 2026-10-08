class InvoiceItem {
  final int? id;
  final int invoiceId;
  String description;
  double quantity;
  double unitPrice;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  // حساب السعر الإجمالي للبند
  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoiceId'],
      description: map['description'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
    );
  }
}