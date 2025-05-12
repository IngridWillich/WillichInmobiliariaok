import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:3004'; // Cambia por tu IP

  static Future<List<dynamic>> searchProperties(Map<String, String> filters) async {
    try {
      // Construye la URL con los parámetros de búsqueda
      final uri = Uri.parse('$_baseUrl/api/properties/search').replace(
        queryParameters: filters..removeWhere((key, value) => value.isEmpty),
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Error al buscar propiedades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}


class PropertyService {
  static const String _baseUrl = 'http://localhost:3004'; 

  static Future<List<dynamic>> fetchProperties() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/properties'));
      
      if (response.statusCode == 200) {
        final List<dynamic> properties = jsonDecode(response.body);
        // Construir URLs completas para las imágenes
        return properties.map((property) {
          if (property['imageSrc'] != null) {
            property['imageSrc'] = (property['imageSrc'] as List).map((img) => 
              img.startsWith('http') ? img : '$_baseUrl$img').toList();
          }
          return property;
        }).toList();
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}


class AuthService {
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3004/api/login'),
        body: {'username': username, 'password': password},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}



