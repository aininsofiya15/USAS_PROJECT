import 'package:flutter/material.dart';


class UserProvider with ChangeNotifier {
  String _name = "";
  String _role = "";
  late int _userId; 

  String get name => _name;
  String get role => _role;
  int get userId => _userId; // Return nullable int

  void createSession(String newName, String newRole, int newUserId) {
    _name = newName;
    _role = newRole;
    _userId = newUserId;
    notifyListeners(); 
  }

  // Optional: Add a logout method to clear data
  void logout() {
    _name = "";
    _role = "";
    _userId = 0;
    notifyListeners();
  }
}