class Publisher {
  final String id;
  final String pName;
  final String? city;

  Publisher({
    required this.id,
    required this.pName,
    this.city,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'] ?? '',
      pName: json['pName'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pName': pName,
      'city': city,
    };
  }
}