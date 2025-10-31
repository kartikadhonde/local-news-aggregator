import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _firebaseAuth.authStateChanges().listen((
        firebase_auth.User? firebaseUser,
      ) async {
        if (firebaseUser != null) {
          await _loadUserProfile(firebaseUser.uid);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromJson({...doc.data()!, 'id': uid});
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final newUser = User(id: uid, email: email, name: name);

      await _firestore.collection('users').doc(uid).set(newUser.toJson());
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Registration error: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign in with Firebase Auth (works for both admin and regular users)
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserProfile(userCredential.user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

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

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(_currentUser!.toJson());

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
