class Customer {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  // لتحويل البيانات من وإلى قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }
}