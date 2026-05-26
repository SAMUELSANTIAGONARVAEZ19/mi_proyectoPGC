import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/auth_service.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _empleos   = [];
  List<Map<String, dynamic>> _usuarios  = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    await Future.wait([_cargarEmpleos(), _cargarUsuarios()]);
    setState(() => _cargando = false);
  }

  Future<void> _cargarEmpleos() async {
    try {
      final r = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/empleos/'));
      if (r.statusCode == 200) {
        final List data = jsonDecode(r.body);
        _empleos = data.map((e) => {
          'id':      e['id_empleo'].toString(),
          'titulo':  e['titulo_puesto'] ?? '',
          'empresa': e['empresa_nombre'] ?? '',
          'lugar':   e['lugar'] ?? '',
          'imagen':  e['imagen_url'] ?? '',
        }).toList();
      }
    } catch (_) {}
  }

  Future<void> _cargarUsuarios() async {
    try {
      final r = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/usuarios/'));
      if (r.statusCode == 200) {
        final List data = jsonDecode(r.body);
        _usuarios = data.map((u) => {
          'id':       u['id'].toString(),
          'nombre':   u['nombre'] ?? '',
          'correo':   u['correo'] ?? '',
          'rol':      u['rol'] ?? '',
          'telefono': u['telefono'] ?? '',
          'fecha':    u['fecha'] ?? '',
        }).toList();
      }
    } catch (_) {}
  }

Future<void> _cambiarImagen(Map<String, dynamic> empleo) async {
  final resultado = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );

  if (resultado == null || resultado.files.single.bytes == null) return;

  final bytes = resultado.files.single.bytes!;
  final base64Img = 'data:image/jpeg;base64,${base64Encode(bytes)}';

  try {
    final r = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/empleos/${empleo['id']}/imagen/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imagen_url': base64Img}),
    );
    if (r.statusCode == 200) {
      await _cargarTodo();
      if (mounted) _snack('✓ Imagen actualizada', const Color(0xFF059669));
    }
  } catch (_) {
    if (mounted) _snack('Error al actualizar', Colors.red);
  }
}

  Future<void> _eliminarUsuario(Map<String, dynamic> u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Eliminar usuario',
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Eliminar a "${u['nombre']}"?\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
            child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final r = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/usuarios/${u['id']}/'));
      if (r.statusCode == 200) {
        await _cargarTodo();
        if (mounted) _snack('✓ Usuario eliminado', const Color(0xFF059669));
      }
    } catch (_) {
      if (mounted) _snack('Error al eliminar', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.esAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        Navigator.pushReplacementNamed(context, '/home'));
      return const SizedBox.shrink();
    }

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgCard    = isDark ? const Color(0xFF1E293B) : Colors.white;
    final bgHeader  = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final greyText  = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    final totalEstudiantes = _usuarios.where((u) => u['rol'] == 'estudiante').length;
    final totalEmpresas    = _usuarios.where((u) => u['rol'] == 'empresa').length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Panel de Administrador',
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTodo,
            tooltip: 'Recargar'),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red, size: 18),
            label: const Text('Salir',
              style: TextStyle(color: Colors.red)),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _cargando
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Stats
              Wrap(spacing: 16, runSpacing: 16, children: [
                _statCard('Total Empleos', _empleos.length.toString(),
                  Icons.work_outline,
                  const Color(0xFF2563EB), const Color(0xFFDBEAFE),
                  bgCard, borderCol),
                _statCard('Usuarios', _usuarios.length.toString(),
                  Icons.people_outline,
                  const Color(0xFF7C3AED), const Color(0xFFEDE9FE),
                  bgCard, borderCol),
                _statCard('Estudiantes', totalEstudiantes.toString(),
                  Icons.school_outlined,
                  const Color(0xFF059669), const Color(0xFFD1FAE5),
                  bgCard, borderCol),
                _statCard('Empresas', totalEmpresas.toString(),
                  Icons.business_outlined,
                  const Color(0xFFD97706), const Color(0xFFFEF3C7),
                  bgCard, borderCol),
              ]),

              const SizedBox(height: 32),

              // Imágenes de empleos
              const Text('Imágenes de ofertas laborales',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Haz clic en "Cambiar imagen" para actualizar la foto.',
                style: TextStyle(color: greyText, fontSize: 13)),
              const SizedBox(height: 16),
              _empleos.isEmpty
                ? Text('No hay empleos.', style: TextStyle(color: greyText))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320, mainAxisExtent: 260,
                        crossAxisSpacing: 16, mainAxisSpacing: 16),
                    itemCount: _empleos.length,
                    itemBuilder: (_, i) {
                      final e = _empleos[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                              child: e['imagen'].isNotEmpty
                                ? Image.network(e['imagen'],
                                    height: 140, width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                      _sinImagen(140))
                                : _sinImagen(140),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e['titulo'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                  Text(e['empresa'],
                                    style: TextStyle(
                                      color: greyText, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.image_outlined, size: 15),
                                      label: const Text('Cambiar imagen',
                                        style: TextStyle(fontSize: 12)),
                                      onPressed: () => _cambiarImagen(e),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                          const Color(0xFF2563EB),
                                        side: const BorderSide(
                                          color: Color(0xFF2563EB)),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                            BorderRadius.circular(8))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

              const SizedBox(height: 32),

              // Usuarios reales desde BD
              const Text('Usuarios registrados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${_usuarios.length} usuarios en el sistema',
                style: TextStyle(color: greyText)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol)),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgHeader,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12))),
                    child: Row(children: [
                      Expanded(flex: 3, child: Text('Nombre',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          fontSize: 13, color: greyText))),
                      Expanded(flex: 4, child: Text('Email',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          fontSize: 13, color: greyText))),
                      Expanded(flex: 2, child: Text('Rol',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          fontSize: 13, color: greyText))),
                      Expanded(flex: 2, child: Text('Registro',
                        style: TextStyle(fontWeight: FontWeight.w600,
                          fontSize: 13, color: greyText))),
                      const SizedBox(width: 40),
                    ]),
                  ),
                  const Divider(height: 1),
                  ..._usuarios.asMap().entries.map((entry) {
                    final u = entry.value;
                    final isLast = entry.key == _usuarios.length - 1;
                    Color rolColor() {
                      switch (u['rol']) {
                        case 'administrador': return const Color(0xFF7C3AED);
                        case 'empresa':       return const Color(0xFF059669);
                        default:              return const Color(0xFF2563EB);
                      }
                    }
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                        child: Row(children: [
                          Expanded(flex: 3, child: Row(children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                rolColor().withValues(alpha: 0.15),
                              child: Text(
                                (u['nombre'] as String).isNotEmpty
                                  ? (u['nombre'] as String)[0].toUpperCase()
                                  : '?',
                                style: TextStyle(fontSize: 12,
                                  color: rolColor(),
                                  fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(u['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 13),
                              overflow: TextOverflow.ellipsis)),
                          ])),
                          Expanded(flex: 4, child: Text(u['correo'],
                            style: TextStyle(color: greyText, fontSize: 13),
                            overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 2, child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: rolColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              u['rol'] == 'administrador' ? 'Admin'
                                : u['rol'] == 'empresa' ? 'Empresa'
                                : 'Estudiante',
                              style: TextStyle(color: rolColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          )),
                          Expanded(flex: 2, child: Text(u['fecha'],
                            style: TextStyle(
                              color: greyText, fontSize: 12),
                            overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 18),
                            tooltip: 'Eliminar usuario',
                            onPressed: () => _eliminarUsuario(u),
                          ),
                        ]),
                      ),
                      if (!isLast) Divider(height: 1, color: borderCol),
                    ]);
                  }),
                ]),
              ),

              const SizedBox(height: 40),
            ]),
          ),
    );
  }

  Widget _sinImagen(double h) => Container(
    height: h,
    color: const Color(0xFFE5E7EB),
    child: const Center(child: Icon(Icons.image_outlined,
      color: Colors.grey, size: 40)),
  );

  Widget _statCard(String titulo, String valor, IconData icon,
      Color fg, Color bg, Color bgCard, Color borderCol) =>
    Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: fg, size: 22),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(valor, style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: fg)),
          Text(titulo, style: const TextStyle(
            color: Colors.grey, fontSize: 12)),
        ]),
      ]),
    );
}