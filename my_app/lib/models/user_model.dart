  class UserModel {
    final String uid;
    final String name;
    final String email;
    final String phone;
    final String userType; // 'farmer' or 'customer'
    final String? address;

    UserModel({
      required this.uid,
      required this.name,
      required this.email,
      required this.phone,
      required this.userType,
      this.address,
    });

    Map<String, dynamic> toMap() {
      return {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType,
        'address': address,
      };
    }

    factory UserModel.fromMap(Map<String, dynamic> map) {
      return UserModel(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        userType: map['userType'] ?? '',
        address: map['address'],
      );
    }
  } 