import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Make sure 'your_project_name_here' matches the 'name:' in your pubspec.yaml
import 'package:e_library/models/book.dart';
import 'package:e_library/models/author.dart';
import 'package:e_library/models/publisher.dart';

class ApiService {
  // Replace with your backend's base URL (e.g., 'http://10.0.2.2:8080' for Android emulator, or your server IP)
  // If running on a real device or a different machine, use your backend's actual IP address or domain name.
  // Example for a local backend on your computer, accessible from Android emulator:
  // static const String _baseUrl = 'http://10.0.2.2:5000/api';
  // Example for a local backend on your computer, accessible from iOS simulator/device or web:
  // static const String _baseUrl = 'http://localhost:5000/api';
  // *** IMPORTANT: CHANGE THIS TO YOUR ACTUAL BACKEND API BASE URL ***
  static const String _baseUrl = 'http://localhost:8080'; // Placeholder!

  String? _token; // Stores the JWT token

  // --- Constructor ---
  ApiService() {
    _loadToken(); // Try to load the token when ApiService is created
  }

  // --- Token Management ---
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
  }

  String? getToken() => _token;

  // --- Helper for Headers ---
  Map<String, String> _getHeaders({bool requireAuth = false}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Common Request Handler ---
  Future<http.Response> _sendRequest(
      String endpoint, String method,
      {Map<String, dynamic>? body, bool requireAuth = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = _getHeaders(requireAuth: requireAuth);
    final encodedBody = body != null ? json.encode(body) : null;

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody);
          break;
        // Add other methods like PUT, DELETE if needed later
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      return response;
    } catch (e) {
      // General network error (e.g., no internet, backend not running)
      throw Exception('Network error: $e');
    }
  }

  // --- API Endpoints ---

  // 1. Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _sendRequest(
      '/auth/login', // Your backend login path
      'POST',
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']); // Save the JWT token
      return data; // Return full response (including isAdmin, userId etc.)
    } else {
      // Handle specific error messages from backend
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to login. Please check credentials.');
    }
  }

  // 2. Sign-Up
  Future<String> signUp(String username, String password, String fName, String lName) async {
    final response = await _sendRequest(
      '/auth/signup', // Your backend signup path
      'POST',
      body: {
        'username': username,
        'password': password,
        'fName': fName,
        'lName': lName,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'User registered successfully!';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to sign up.');
    }
  }

  // 3. Add Book (Admin Only)
  Future<String> addBook(String title, String type, double price, String pubId, String authorId) async {
    final response = await _sendRequest(
      '/books',
      'POST',
      body: {
        'title': title,
        'type': type,
        'price': price,
        'pubId': pubId,
        'authorId': authorId,
      },
      requireAuth: true, // Requires JWT token
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Book added successfully!';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add book.');
    }
  }

  // 4. Add Publisher (Admin Only)
  Future<String> addPublisher(String pName, String city) async {
    final response = await _sendRequest(
      '/publishers',
      'POST',
      body: {'pName': pName, 'city': city},
      requireAuth: true, // Requires JWT token
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Publisher added successfully!';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add publisher.');
    }
  }

  // 5. Add Author (Admin Only)
  Future<String> addAuthor(String fName, String lName, String country, String city, String address) async {
    final response = await _sendRequest(
      '/authors',
      'POST',
      body: {
        'fName': fName,
        'lName': lName,
        'country': country,
        'city': city,
        'address': address,
      },
      requireAuth: true, // Requires JWT token
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'] ?? 'Author added successfully!';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add author.');
    }
  }

  // 6. Display All Books (List)
  Future<List<Book>> fetchAllBooks() async {
    final response = await _sendRequest('/books', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Book.fromJsonList(json)).toList();
    } else {
      throw Exception('Failed to load books.');
    }
  }

  // 6.1. Display Single Book Details
  Future<Book> fetchBookDetails(String bookId) async {
    final response = await _sendRequest('/books/$bookId', 'GET');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Book.fromJsonDetail(jsonData); // Use the detail constructor
    } else if (response.statusCode == 404) {
      throw Exception('Book not found.');
    } else {
      throw Exception('Failed to load book details.');
    }
  }

  // 7. Search Books by Title
  Future<List<Book>> searchBooksByTitle(String title) async {
    final response = await _sendRequest('/books/search?title=$title', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Book.fromJsonList(json)).toList();
    } else {
      throw Exception('Failed to search books by title.');
    }
  }

  // 8. Search Authors by Name
  Future<List<Author>> searchAuthorsByName(String name) async {
    final response = await _sendRequest('/authors/search?name=$name', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Author.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search authors by name.');
    }
  }

  // 8.1. Display Books by Author
  Future<List<Book>> fetchBooksByAuthor(String authorId) async {
    final response = await _sendRequest('/authors/$authorId/books', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Book.fromJsonList(json)).toList();
    } else {
      throw Exception('Failed to load books by author.');
    }
  }

  // 9. Search Publishers by Name
  Future<List<Publisher>> searchPublishersByName(String name) async {
    final response = await _sendRequest('/publishers/search?name=$name', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Publisher.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search publishers by name.');
    }
  }

  // 9.1. Display Books by Publisher
  Future<List<Book>> fetchBooksByPublisher(String publisherId) async {
    final response = await _sendRequest('/publishers/$publisherId/books', 'GET');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Book.fromJsonList(json)).toList();
    } else {
      throw Exception('Failed to load books by publisher.');
    }
  }
}