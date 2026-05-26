import 'dart:convert';
import 'package:http/http.dart' as http;
class EmpleoEmpresa {
  String id;
  String titulo;
  String tipo;
  String descripcion;
  String lugar;
  String salario;
  String horas;
  List<String> dias;
  String horarioInicio;
  String horarioFin;
  bool esRemoto;
  EmpleoEmpresa({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.descripcion,
    required this.lugar,
    required this.salario,
    required this.horas,
    required this.dias,
    required this.horarioInicio,
    required this.horarioFin,
    required this.esRemoto,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo_puesto': titulo,
    'titulo': titulo,
    'tipo_empleo': tipo,
    'descripcion': descripcion,
    'lugar': lugar,
    'salario': salario,
    'horas_semana': horas,
    'horas': horas,
    'dias': dias,
    'horario_inicio': horarioInicio,
    'horario_fin': horarioFin,
    'esRemoto': esRemoto,
    'empresa_nombre': EmpresaService.nombreEmpresa,
    'imagen': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400',
    'requisitos': ['Disponibilidad horaria', 'Compromiso', 'Responsabilidad'],
    'ubicacion': lugar,
  };
}
class PostuladoInfo {
  final int idPostulacion;
  final String estado;
  final String fecha;
  final String nombreEstudiante;
  final String correo;
  final String carrera;
  final String semestre;
  final String telefono;
  final String habilidades;
  PostuladoInfo({
    required this.idPostulacion,
    required this.estado,
    required this.fecha,
    required this.nombreEstudiante,
    required this.correo,
    required this.carrera,
    required this.semestre,
    required this.telefono,
    required this.habilidades,
  });
  factory PostuladoInfo.fromJson(Map<String, dynamic> j) => PostuladoInfo(
    idPostulacion:    j['id_postulacion'] ?? 0,
    estado:           j['estado'] ?? 'pendiente',
    fecha:            j['fecha'] ?? '',
    nombreEstudiante: j['estudiante_nombre'] ?? '',
    correo:           j['estudiante_correo'] ?? '',
    carrera:          j['estudiante_carrera'] ?? '',
    semestre:         j['estudiante_semestre']?.toString() ?? '',
    telefono:         j['estudiante_telefono'] ?? '',
    habilidades:      j['estudiante_habilidades'] ?? '',
  );
}
class EmpresaService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static String nombreEmpresa = '';
  static int? empresaId;
  static final List<EmpleoEmpresa> _empleos = [];
  static List<EmpleoEmpresa> get empleos => List.unmodifiable(_empleos);
  static Future<void> cargarEmpleos() async {
    if (empresaId == null) return;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/empleos/mis/$empresaId/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        _empleos.clear();
        for (final e in data) {
          _empleos.add(EmpleoEmpresa(
            id:            e['id_empleo'].toString(),
            titulo:        e['titulo_puesto'] ?? '',
            tipo:          e['tipo_empleo'] ?? '',
            descripcion:   e['descripcion'] ?? '',
            lugar:         e['lugar'] ?? '',
            salario:       e['salario']?.toString() ?? '',
            horas:         e['horas_semana'] ?? '',
            dias:          _parseDias(e['dias_laborales']),
            horarioInicio: e['horario_inicio'] ?? '',
            horarioFin:    e['horario_fin'] ?? '',
            esRemoto:      false,
          ));
        }
      }
    } catch (_) {}
  }
  static List<String> _parseDias(dynamic dias) {
    if (dias == null) return [];
    if (dias is List) return dias.cast<String>();
    if (dias is String && dias.isNotEmpty) {
      return dias.split(',').map((d) => d.trim()).toList();
    }
    return [];
  }
  static Future<bool> publicar({
    required String titulo,
    required String tipo,
    required String descripcion,
    required String lugar,
    required String salario,
    required String horas,
    required List<String> dias,
    required String horarioInicio,
    required String horarioFin,
    required bool esRemoto,
  }) async {
    if (empresaId == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/empleos/publicar/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'empresa_id':     empresaId,
          'titulo_puesto':  titulo,
          'tipo_empleo':    tipo,
          'descripcion':    descripcion,
          'lugar':          lugar,
          'salario':        salario.isNotEmpty ? salario : null,
          'horas_semana':   horas,
          'dias_laborales': dias.join(', '),
          'horario_inicio': horarioInicio.isNotEmpty ? horarioInicio : null,
          'horario_fin':    horarioFin.isNotEmpty ? horarioFin : null,
        }),
      );
      if (response.statusCode == 201) {
        await cargarEmpleos();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
  static Future<bool> editar({
    required String id,
    required String titulo,
    required String tipo,
    required String descripcion,
    required String lugar,
    required String salario,
    required String horas,
    required List<String> dias,
    required String horarioInicio,
    required String horarioFin,
    required bool esRemoto,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/empleos/$id/editar/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo_puesto':  titulo,
          'tipo_empleo':    tipo,
          'descripcion':    descripcion,
          'lugar':          lugar,
          'salario':        salario.isNotEmpty ? salario : null,
          'horas_semana':   horas,
          'dias_laborales': dias.join(', '),
          'horario_inicio': horarioInicio.isNotEmpty ? horarioInicio : null,
          'horario_fin':    horarioFin.isNotEmpty ? horarioFin : null,
        }),
      );
      if (response.statusCode == 200) {
        await cargarEmpleos();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
  static void eliminar(String id) {
    _empleos.removeWhere((e) => e.id == id);
  }
  static Future<List<PostuladoInfo>> getPostulados(String empleoId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/empleos/$empleoId/postulaciones/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => PostuladoInfo.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
