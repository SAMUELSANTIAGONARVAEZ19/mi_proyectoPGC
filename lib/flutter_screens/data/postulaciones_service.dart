import 'dart:convert';
import 'package:http/http.dart' as http;

class Postulacion {
  final int id;
  final String estado;
  final String fecha;
  final String empleoTitulo;
  final String empresaNombre;

  Postulacion({
    required this.id,
    required this.estado,
    required this.fecha,
    required this.empleoTitulo,
    required this.empresaNombre,
  });

  factory Postulacion.fromJson(Map<String, dynamic> j) => Postulacion(
    id:             j['id_postulacion'],
    estado:         j['estado'],
    fecha:          j['fecha'],
    empleoTitulo:   j['empleo_titulo'],
    empresaNombre:  j['empresa_nombre'],
  );
}

class PostulacionesService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<Postulacion>> getMisPostulaciones(String estudianteId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/mis-postulaciones/$estudianteId/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Postulacion.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}