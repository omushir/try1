class Region {
  final String id;
  final String name;
  final String state;

  Region({
    required this.id,
    required this.name,
    required this.state,
  });

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'state': state,
    };
  }
} 