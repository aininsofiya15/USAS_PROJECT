class UserSession {
  // A 'Singleton' ensures there is only ONE session in the whole app
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  String name = "";
  String role = "";

  // This will be called once the login is successful
  void createSession(String newName, String newRole) {
    name = newName;
    role = newRole;
  }
}