import 'dart:convert';
import 'package:http/http.dart' as http;
import 'empresa_service.dart';

class Usuario {
  final String id;
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String rol;
  final String? telefono;
  final String? universidad;
  final String? habilidades;

  Usuario({
    required this.id,
    required this.email,
    this.password = '',
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.universidad,
    this.habilidades,
  });

  String get nombreCompleto => '$nombre $apellido';
}

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static Usuario? _usuarioActual;

  static Usuario? get usuarioActual => _usuarioActual;
  static bool get estaAutenticado  => _usuarioActual != null;
  static bool get esAdmin          => _usuarioActual?.rol == 'administrador';
  static bool get esEmpresa        => _usuarioActual?.rol == 'empresa';

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo_institucional': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final nombreParts = (data['nombre'] as String).split(' ');
        _usuarioActual = Usuario(
          id:       data['id'].toString(),
          email:    data['correo'] ?? email,
          nombre:   nombreParts.first,
          apellido: nombreParts.length > 1
              ? nombreParts.sublist(1).join(' ')
              : '',
          rol:      data['rol'] ?? 'estudiante',
        );

        // Si es empresa, guardamos el id para usarlo en EmpresaService
        if (_usuarioActual!.rol == 'empresa') {
          EmpresaService.empresaId     = data['id'];
          EmpresaService.nombreEmpresa = data['nombre'];
          await EmpresaService.cargarEmpleos();
        }

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registrar({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
    String? universidad,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/registro/estudiante/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo_institucional': email,
          'password':             password,
          'nombre_completo':      '$nombre $apellido',
          'telefono':             telefono ?? '',
          'carrera':              universidad ?? '',
          'semestre':             1,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _usuarioActual = Usuario(
          id:          data['id'].toString(),
          email:       email,
          nombre:      nombre,
          apellido:    apellido,
          rol:         data['rol'] ?? 'estudiante',
          telefono:    telefono,
          universidad: universidad,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void logout() {
    _usuarioActual = null;
    EmpresaService.empresaId = null;
    EmpresaService.nombreEmpresa = '';
  }

  static List<Usuario> getTodosLosUsuarios() {
    return _usuarioActual != null ? [_usuarioActual!] : [];
  }
}