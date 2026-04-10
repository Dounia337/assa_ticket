import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assa_ticket/core/constants/app_constants.dart';
import 'package:assa_ticket/core/database/database_helper.dart';
import 'package:assa_ticket/core/models/models.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _pendingPhone;
  bool _isGuest = false;
  bool _isNewUser = false;

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isAdmin => _currentUser?.role == AppConstants.roleAdmin;
  bool get isGuest => _isGuest;
  bool get isNewUser => _isNewUser;
  String? get pendingPhone => _pendingPhone;

  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
      final userId = prefs.getInt(AppConstants.prefUserId);

      if (isLoggedIn && userId != null) {
        final user = await DatabaseHelper.instance.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _pendingPhone = phone;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Impossible d\'envoyer le code. Veuillez réessayer.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('>>> OTP ENTERED: $otp');
      debugPrint('>>> OTP EXPECTED: ${AppConstants.dummyOtp}');
      debugPrint('>>> PENDING PHONE: $_pendingPhone');

      if (otp != AppConstants.dummyOtp) {
        _state = AuthState.unauthenticated;
        _errorMessage = 'Code incorrect. Veuillez utiliser le code ${AppConstants.dummyOtp}.';
        notifyListeners();
        return false;
      }

      if (_pendingPhone == null || _pendingPhone!.isEmpty) {
        _state = AuthState.error;
        _errorMessage = 'Session expirée. Veuillez recommencer l\'envoi du code.';
        notifyListeners();
        return false;
      }

      final phone = _pendingPhone!;
      final existingUser = await DatabaseHelper.instance.getUserByPhone(phone);
      debugPrint('>>> USER FOUND IN DB: ${existingUser?.fullName}, ROLE: ${existingUser?.role}');

      if (existingUser != null) {
        // Existing user — log them in directly
        _isNewUser = false;
        _currentUser = existingUser;
        _state = AuthState.authenticated;
        _isGuest = false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.prefIsLoggedIn, true);
        await prefs.setInt(AppConstants.prefUserId, existingUser.id!);
        await prefs.setString(AppConstants.prefUserPhone, existingUser.phoneNumber);
        await prefs.setString(AppConstants.prefUserName, existingUser.fullName);
        await prefs.setString(AppConstants.prefUserRole, existingUser.role);
      } else {
        // New user — OTP is valid but we need their name first
        _isNewUser = true;
        _state = AuthState.unauthenticated;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('>>> ERROR: $e');
      _state = AuthState.error;
      _errorMessage = 'Une erreur est survenue lors de la vérification.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRegistration(String name) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_pendingPhone == null || _pendingPhone!.isEmpty) {
        _state = AuthState.error;
        _errorMessage = 'Session expirée. Veuillez recommencer.';
        notifyListeners();
        return false;
      }

      final phone = _pendingPhone!;
      final isAdmin = phone == AppConstants.adminPhone;

      final newUser = UserModel(
        fullName: name.trim(),
        phoneNumber: phone,
        email: isAdmin ? AppConstants.adminEmail : null,
        role: isAdmin ? AppConstants.roleAdmin : AppConstants.roleUser,
      );

      final id = await DatabaseHelper.instance.insertUser(newUser);
      final user = await DatabaseHelper.instance.getUserById(id);

      if (user == null) throw Exception('Impossible de créer le compte.');

      debugPrint('>>> REGISTERED: ${user.fullName}, ROLE: ${user.role}');

      _currentUser = user;
      _state = AuthState.authenticated;
      _isGuest = false;
      _isNewUser = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefIsLoggedIn, true);
      await prefs.setInt(AppConstants.prefUserId, user.id!);
      await prefs.setString(AppConstants.prefUserPhone, user.phoneNumber);
      await prefs.setString(AppConstants.prefUserName, user.fullName);
      await prefs.setString(AppConstants.prefUserRole, user.role);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('>>> REGISTRATION ERROR: $e');
      _state = AuthState.error;
      _errorMessage = 'Une erreur est survenue lors de l\'inscription.';
      notifyListeners();
      return false;
    }
  }

  void continueAsGuest() {
    _isGuest = true;
    _state = AuthState.authenticated;
    _currentUser = UserModel(
      id: 0,
      fullName: 'Invité',
      phoneNumber: '',
      role: AppConstants.roleUser,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserPhone);
    await prefs.remove(AppConstants.prefUserName);
    await prefs.remove(AppConstants.prefUserRole);

    _currentUser = null;
    _isGuest = false;
    _isNewUser = false;
    _pendingPhone = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String? email) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(fullName: name, email: email);
    await DatabaseHelper.instance.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}