class AuthService {
  static bool loggedIn = false;
  static List<Map<String, String>> users = [];

  static Future<bool> login(String email, String password) async {
    // Buscar usuario en el arreglo
    final user = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => <String, String>{},
    );

    if (user.isNotEmpty) {
      loggedIn = true;
      return true;
    }
    return false;
  }

  static Future<bool> register(String email, String password) async {
    // Verificar si el email ya existe
    final emailExists = users.any((user) => user['email'] == email);

    if (emailExists) return false;

    // Agregar nuevo usuario
    users.add({
      'email': email,
      'password': password,
    });

    loggedIn = true;
    return true;
  }

  static void logout() {
    loggedIn = false;
  }
}
