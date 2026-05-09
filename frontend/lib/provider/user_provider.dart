import 'package:flutter/material.dart';


class UserProvider with ChangeNotifier {
  String _name = "";
  String _role = "";
  int _userId = 0; 
  
  String get name => _name;
  String get role => _role;
  int get userId => _userId;

  void createSession(String newName, String newRole, int newUserId) {
    _name = newName;
    _role = newRole;
    _userId = newUserId;

    // This tells the Sidebar and Header to refresh automatically!
    notifyListeners(); 
  }
}