import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'dart:convert'; 




class AppContext extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Auth0 auth0 = Auth0('TU_DOMINIO_AUTH0', 'TU_CLIENT_ID_AUTH0');

  bool _isLoggedIn = false;

  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;

  AppContext() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? storedUserData = await _secureStorage.read(key: 'userData');

     if (_isLoggedIn && storedUserData != null) {
      _userData = Map<String, dynamic>.from(jsonDecode(storedUserData));
    }
    notifyListeners();
  }


  Future<void> login() async {
    try {
      final credentials = await auth0.webAuthentication().login();

      _isLoggedIn = true;
      _userData = {
        'email': credentials.user.email,
        'name': credentials.user.name,
        'auth0Id': credentials.user.sub,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _secureStorage.write(
        key: 'userData',
        value: _userData.toString(),
      );

      notifyListeners();
    } catch (error) {
      debugPrint('Error en login: $error');
debugPrint('Error al cerrar sesión: $error');
    }
  }

  Future<void> logout() async {
    try {
      await auth0.webAuthentication().logout();

      _isLoggedIn = false;
      _userData = null;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await _secureStorage.delete(key: 'userData');

      notifyListeners();
    } catch (error) {
      debugPrint('Error en login: $error');
debugPrint('Error al cerrar sesión: $error');
    }
  }
}
class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppContext>(
      create: (_) => AppContext(),
      child: child,
    );
  }
}
