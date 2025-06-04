import 'package:e_library/models/author.dart';   // Changed 'e_library' to 'ELIBRARY'
import 'package:e_library/models/publisher.dart'; // Changed 'e_library' to 'ELIBRARY'

class Book {
  final String id;
  final String title;
  final String type;
  final double price;
  final String pubId; // Reference to Publisher ID
  final String authorId; // Reference to Author ID
  final Author? author; // Populated only when getting full details
  final Publisher? publisher; // Populated only when getting full details

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.pubId,
    required this.authorId,
    this.author,
    this.publisher,
  });

  // Factory constructor for fetching lists of books (basic details)
  factory Book.fromJsonList(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'],
      type: json['type'],
      price: (json['price'] as num).toDouble(), // Ensure price is a double
      pubId: json['pubId']?.toString() ?? '', // Convert to string if int/num
      authorId: json['authorId']?.toString() ?? '', // Convert to string if int/num
    );
  }

  // Factory constructor for fetching full book details (with nested author/publisher)
  factory Book.fromJsonDetail(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      pubId: json['publisher']['id']?.toString() ?? '', // Get ID from nested publisher
      authorId: json['author']['id']?.toString() ?? '', // Get ID from nested author
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
      publisher: json['publisher'] != null ? Publisher.fromJson(json['publisher']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'price': price,
      'pubId': pubId,
      'authorId': authorId,
      // We usually don't include nested objects when sending to the backend for creation/update
    };
  }
}