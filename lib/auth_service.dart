class AuthService {
  static bool loggedIn = false;
  static List<Map<String, String>> users = [];
  static String? currentUserEmail; // Track logged-in user

  static Future<bool> login(String email, String password) async {
    final user = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => <String, String>{},
    );

    if (user.isNotEmpty) {
      loggedIn = true;
      currentUserEmail = email; // Set current user
      return true;
    }
    return false;
  }

  static Future<bool> register(String email, String password) async {
    final emailExists = users.any((user) => user['email'] == email);
    if (emailExists) return false;

    users.add({'email': email, 'password': password});
    loggedIn = true;
    currentUserEmail = email; // Set current user
    return true;
  }

  static Future<bool> deleteAccount() async {
    if (currentUserEmail == null) return false;

    final initialLength = users.length;
    users.removeWhere((user) => user['email'] == currentUserEmail);

    if (users.length < initialLength) {
      loggedIn = false;
      currentUserEmail = null;
      return true;
    }
    return false;
  }

  static void logout() {
    loggedIn = false;
    currentUserEmail = null;
  }
}
