class Farmer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String? imageUrl;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'imageUrl': imageUrl,
    };
  }

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
} 