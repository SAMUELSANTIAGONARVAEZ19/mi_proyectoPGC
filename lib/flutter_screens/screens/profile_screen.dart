import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/auth_service.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _fotoBytes;
  bool _cargandoFoto = false;

  @override
  void initState() {
    super.initState();
    temaApp.addListener(_actualizar);
    _cargarFoto();
  }

  void _actualizar() => setState(() {});

  @override
  void dispose() {
    temaApp.removeListener(_actualizar);
    super.dispose();
  }

  Future<void> _cargarFoto() async {
    final u = AuthService.usuarioActual;
    if (u == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/usuarios/${u.id}/foto/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foto = data['foto'] as String? ?? '';
        if (foto.isNotEmpty) {
          setState(() => _fotoBytes = base64Decode(foto));
        }
      }
    } catch (_) {}
  }

  Future<void> _guardarFoto(Uint8List bytes) async {
    final u = AuthService.usuarioActual;
    if (u == null) return;
    try {
      await http.post(
        Uri.parse('http://127.0.0.1:8000/api/usuarios/${u.id}/foto/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'foto': base64Encode(bytes)}),
      );
    } catch (_) {}
  }

  void _subirFoto() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((event) async {
      final file = input.files?.first;
      if (file == null) return;
      setState(() => _cargandoFoto = true);
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) async {
        final bytes = reader.result as Uint8List;
        setState(() => _fotoBytes = bytes);
        await _guardarFoto(bytes);
        setState(() => _cargandoFoto = false);
      });
    });
  }

  void _editarPerfil() {
    final u = AuthService.usuarioActual!;
    final nombreCtrl   = TextEditingController(text: u.nombreCompleto);
    final telefonoCtrl = TextEditingController(text: u.telefono ?? '');
    final univCtrl     = TextEditingController(text: u.universidad ?? '');
    final habCtrl      = TextEditingController(text: u.habilidades ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Editar información',
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _campoEditar('Nombre completo', nombreCtrl, Icons.person_outline),
            const SizedBox(height: 12),
            _campoEditar('Teléfono', telefonoCtrl, Icons.phone_outlined,
              teclado: TextInputType.phone),
            const SizedBox(height: 12),
            _campoEditar('Universidad / Carrera', univCtrl, Icons.school_outlined),
            const SizedBox(height: 12),
            _campoEditar('Habilidades', habCtrl, Icons.star_outline,
              maxLineas: 3),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _guardarPerfil(
                nombre:     nombreCtrl.text.trim(),
                telefono:   telefonoCtrl.text.trim(),
                universidad: univCtrl.text.trim(),
                habilidades: habCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
            child: const Text('Guardar')),
        ],
      ),
    );
  }

  Future<void> _guardarPerfil({
    required String nombre,
    required String telefono,
    required String universidad,
    required String habilidades,
  }) async {
    final u = AuthService.usuarioActual;
    if (u == null) return;
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/usuarios/${u.id}/perfil/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': nombre,
          'telefono':        telefono,
          'carrera':         universidad,
          'habilidades':     habilidades,
        }),
      );
      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✓ Perfil actualizado'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _eliminarCuenta() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Eliminar cuenta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta?\n\n'
          'Esta acción eliminará todos tus datos, postulaciones y favoritos. '
          'No se puede deshacer.',
          style: TextStyle(color: Colors.grey)),
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
            child: const Text('Eliminar mi cuenta')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final u = AuthService.usuarioActual!;
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/usuarios/${u.id}/'));
      if (response.statusCode == 200) {
        AuthService.logout();
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (_) {}
  }

  Widget _campoEditar(String label, TextEditingController ctrl,
      IconData icon, {TextInputType? teclado, int maxLineas = 1}) =>
    TextField(
      controller: ctrl,
      keyboardType: teclado,
      maxLines: maxLineas,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      ),
    );

  @override
  Widget build(BuildContext context) {
    final u = AuthService.usuarioActual;
    if (u == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
        Navigator.pushReplacementNamed(context, '/login'));
      return const SizedBox.shrink();
    }

    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    Color rolColor() {
      switch (u.rol) {
        case 'administrador': return const Color(0xFF7C3AED);
        case 'empresa':       return const Color(0xFF059669);
        default:              return const Color(0xFF2563EB);
      }
    }

    String rolLabel() {
      switch (u.rol) {
        case 'administrador': return 'Administrador';
        case 'empresa':       return 'Empresa';
        default:              return 'Estudiante';
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red, size: 18),
            label: const Text('Salir', style: TextStyle(color: Colors.red)),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [

              // Foto y datos básicos
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol)),
                child: Column(children: [
                  Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: rolColor().withValues(alpha: 0.15),
                      backgroundImage: _fotoBytes != null
                        ? MemoryImage(_fotoBytes!) : null,
                      child: _cargandoFoto
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _fotoBytes == null
                          ? Text('${u.nombre[0]}${u.apellido.isNotEmpty ? u.apellido[0] : ''}',
                              style: TextStyle(fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: rolColor()))
                          : null,
                    ),
                    GestureDetector(
                      onTap: _subirFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(u.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(u.email,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: rolColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(rolLabel(),
                      style: TextStyle(
                        color: rolColor(), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  // Botón editar perfil
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar información personal'),
                      onPressed: _editarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // Modo oscuro
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol)),
                child: Row(children: [
                  Icon(temaApp.esOscuro ? Icons.dark_mode : Icons.light_mode,
                    color: const Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Modo oscuro',
                    style: TextStyle(fontWeight: FontWeight.w600))),
                  Switch(
                    value: temaApp.esOscuro,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (_) => temaApp.toggleTema(),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // Información personal
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text('Información personal',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (u.telefono != null && u.telefono!.isNotEmpty)
                    _fila(Icons.phone_outlined, 'Teléfono', u.telefono!, isDark),
                  if (u.universidad != null && u.universidad!.isNotEmpty)
                    _fila(Icons.school_outlined, 'Universidad', u.universidad!, isDark),
                  if (u.habilidades != null && u.habilidades!.isNotEmpty)
                    _fila(Icons.star_outline, 'Habilidades', u.habilidades!, isDark),
                  _fila(Icons.badge_outlined, 'Rol', rolLabel(), isDark),
                ]),
              ),

              const SizedBox(height: 20),

              // Accesos rápidos
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text('Accesos rápidos',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _botonAcceso(context, Icons.assignment_outlined,
                    'Mis postulaciones', '/my-applications'),
                  const SizedBox(height: 8),
                  _botonAcceso(context, Icons.favorite_outline,
                    'Mis favoritos', '/favorites'),
                  const SizedBox(height: 8),
                  _botonAcceso(context, Icons.search,
                    'Ver empleos disponibles', '/jobs'),
                  const SizedBox(height: 8),
                  _botonAcceso(context, Icons.home_outlined,
                    'Ir al inicio', '/home'),
                  if (AuthService.esAdmin) ...[
                    const SizedBox(height: 8),
                    _botonAcceso(context, Icons.admin_panel_settings,
                      'Panel de administrador', '/admin',
                      color: const Color(0xFF7C3AED)),
                  ],
                ]),
              ),

              const SizedBox(height: 20),

              // Zona peligrosa — eliminar cuenta
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.2)
                    : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Row(children: [
                    Icon(Icons.warning_amber_outlined,
                      color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Zona peligrosa',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                        color: Colors.red)),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'Al eliminar tu cuenta se borrarán todos tus datos permanentemente.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 18),
                      label: const Text('Eliminar mi cuenta',
                        style: TextStyle(color: Colors.red)),
                      onPressed: _eliminarCuenta,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _fila(IconData icon, String label, String valor, bool isDark) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey)),
          Text(valor, style: const TextStyle(fontSize: 14)),
        ]),
      ]),
    );

  Widget _botonAcceso(BuildContext ctx, IconData icon, String label,
      String ruta, {Color? color}) =>
    SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, size: 18, color: color ?? const Color(0xFF2563EB)),
        label: Text(label,
          style: TextStyle(color: color ?? const Color(0xFF2563EB))),
        onPressed: () => Navigator.pushNamed(ctx, ruta),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: (color ?? const Color(0xFF2563EB)).withValues(alpha: 0.3)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
}