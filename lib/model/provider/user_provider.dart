import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;


  void setUser(UserModel newUser) {
    _user = newUser;
    _saveUserToPrefs();
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _removeUserFromPrefs();
    notifyListeners();
  }

  // Load user from local storage
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final map = jsonDecode(userJson);
      _user = UserModel.fromMap(map);
      notifyListeners();
    }
  }

  // Save user to local storage
  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _user?.toMap();

    prefs.setString('user', jsonEncode(map));
    print("Saved user JSON: ${jsonEncode(map)}");
  }

  // Remove user from local storage
  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }
}
