class Author {
  final String id;
  final String fName;
  final String lName;
  final String? country;
  final String? city;
  final String? address;

  Author({
    required this.id,
    required this.fName,
    required this.lName,
    this.country,
    this.city,
    this.address,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? '',
      fName: json['fName'],
      lName: json['lName'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fName': fName,
      'lName': lName,
      'country': country,
      'city': city,
      'address': address,
    };
  }
}