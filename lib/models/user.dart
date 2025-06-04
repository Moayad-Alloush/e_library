class User {
  final String id; 
  final String username;
  final String? fName; 
  final String? lName; 
  final bool isAdmin; 

  // This is the constructor. It's like the initial setup when you create a new User object.
  User({
    required this.id, // 'required' means you MUST provide an ID when creating a User
    required this.username,
    this.fName,
    this.lName,
    this.isAdmin = false, // Default to false if not specified during creation
  });

  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Get 'id' from JSON, if null, use empty string
      username: json['username'],
      fName: json['fName'],
      lName: json['lName'],
      isAdmin: json['isAdmin'] ?? false, // Get 'isAdmin' from JSON, if null, assume false
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fName': fName,
      'lName': lName,
      'isAdmin': isAdmin,
    };
  }
}