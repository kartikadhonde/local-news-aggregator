import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Initialize and check if user is already logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Check if user already exists
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final users = (json.decode(usersJson) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Check for existing email
      if (users.any((u) => u['email'] == email)) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );

      // Store user credentials
      users.add({
        ...newUser.toJson(),
        'password': password, // In production, use proper hashing
      });

      await prefs.setString('users', json.encode(users));
      await prefs.setString('current_user', json.encode(newUser.toJson()));

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final users = (json.decode(usersJson) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Find user
      final userMap = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (userMap.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // Invalid credentials
      }

      // Remove password before storing current user
      userMap.remove('password');
      _currentUser = User.fromJson(userMap);

      await prefs.setString(
        'current_user',
        json.encode(_currentUser!.toJson()),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? profileImageUrl,
    String? defaultCity,
    String? defaultState,
    String? defaultCountry,
    String? defaultCountryCode,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Update current user
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        bio: bio ?? _currentUser!.bio,
        location: location ?? _currentUser!.location,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        defaultCity: defaultCity ?? _currentUser!.defaultCity,
        defaultState: defaultState ?? _currentUser!.defaultState,
        defaultCountry: defaultCountry ?? _currentUser!.defaultCountry,
        defaultCountryCode:
            defaultCountryCode ?? _currentUser!.defaultCountryCode,
      );

      // Update in storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'current_user',
        json.encode(_currentUser!.toJson()),
      );

      // Update in users list
      final usersJson = prefs.getString('users') ?? '[]';
      final users = (json.decode(usersJson) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final userIndex = users.indexWhere((u) => u['id'] == _currentUser!.id);
      if (userIndex != -1) {
        final password = users[userIndex]['password'];
        users[userIndex] = {...(_currentUser!.toJson()), 'password': password};
        await prefs.setString('users', json.encode(users));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
