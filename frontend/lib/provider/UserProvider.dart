import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "";
  String _role = "";

  String get name => _name;
  String get role => _role;

  void createSession(String newName, String newRole) {
    _name = newName;
    _role = newRole;
    
    // This tells the Sidebar and Header to refresh automatically!
    notifyListeners(); 
  }
}