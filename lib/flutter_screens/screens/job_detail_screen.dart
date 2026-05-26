import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/auth_service.dart';
import '../data/favorites_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobDetailScreen({super.key, required this.job});
  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late bool _esFavorito;
  bool _postulando = false;
  bool _yaPostulado = false;

  @override
  void initState() {
    super.initState();
    _esFavorito = FavoritesService.esFavorito(widget.job['id'].toString());
  }

  void _toggleFavorito() {
    setState(() {
      _esFavorito = FavoritesService.toggleFavorito(widget.job['id'].toString());
    });
  }

  Future<void> _postular() async {
    if (!AuthService.estaAutenticado) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() => _postulando = true);
    try {
      final empleoId = widget.job['id_empleo'] ?? widget.job['id'];
      final estudianteId = AuthService.usuarioActual!.id;
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/empleos/$empleoId/postular/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estudiante_id': int.parse(estudianteId)}),
      );
      if (!mounted) return;
      if (response.statusCode == 201) {
        setState(() => _yaPostulado = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('¡Postulación enviada para ${widget.job['titulo']}!'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['error'] ?? 'Error al postularse'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _postulando = false);
  }

  Widget _imagenWidget(String imagen, bool isDark, Color subColor) {
    if (imagen.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imagen.split(',').last);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes,
            height: 240, width: double.infinity, fit: BoxFit.cover));
      } catch (_) {}
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(imagen,
        height: 240, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 240,
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          child: Icon(Icons.image_outlined, size: 60, color: subColor))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e       = widget.job;
    final dias    = (e['dias'] as List? ?? []).cast<String>();
    final reqs    = (e['requisitos'] as List? ?? []).cast<String>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor  = isDark ? Colors.white60 : Colors.grey;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final chipColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
    final chipText  = isDark ? Colors.white70 : Colors.black87;
    final chipIcon  = isDark ? Colors.white54 : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context)),
        title: Text('Detalle del empleo',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              _esFavorito ? Icons.favorite : Icons.favorite_border,
              color: _esFavorito ? Colors.red : textColor),
            tooltip: _esFavorito ? 'Quitar de favoritos' : 'Guardar en favoritos',
            onPressed: _toggleFavorito,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _imagenWidget(e['imagen'] ?? '', isDark, subColor),
              const SizedBox(height: 24),
              Text(e['titulo'] ?? '',
                style: TextStyle(fontSize: 28,
                  fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 4),
              Text(e['empresa'] ?? '',
                style: TextStyle(fontSize: 16, color: subColor)),
              const SizedBox(height: 20),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _chip(Icons.location_on_outlined, e['ubicacion'] ?? '',
                  chipColor, chipText, chipIcon),
                _chip(Icons.attach_money, e['salario'] ?? '',
                  chipColor, chipText, chipIcon),
                _chip(Icons.schedule, e['horas'] ?? '',
                  chipColor, chipText, chipIcon),
                _chip(Icons.wifi, e['esRemoto'] == true ? 'Remoto' : 'Presencial',
                  chipColor, chipText, chipIcon),
              ]),
              const SizedBox(height: 20),
              Text('Días laborales',
                style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: dias.map((d) => Chip(
                label: Text(d, style: TextStyle(fontSize: 12, color: textColor)),
                backgroundColor: isDark
                  ? const Color(0xFF1D4ED8).withValues(alpha: 0.3)
                  : const Color(0xFFDBEAFE),
                padding: EdgeInsets.zero,
              )).toList()),
              const SizedBox(height: 20),
              Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              Text(e['descripcion'] ?? '',
                style: TextStyle(fontSize: 14, height: 1.6, color: textColor)),
              const SizedBox(height: 20),
              Text('Requisitos',
                style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16, color: textColor)),
              const SizedBox(height: 8),
              ...reqs.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_circle,
                    color: Color(0xFF2563EB), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(r,
                    style: TextStyle(fontSize: 14, color: textColor))),
                ]),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _postulando || _yaPostulado ? null : _postular,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yaPostulado
                      ? const Color(0xFF059669)
                      : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _postulando
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : Text(
                        _yaPostulado
                          ? '✓ Ya te postulaste'
                          : 'Postularme a este trabajo',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String texto, Color bg,
      Color txtColor, Color iconColor) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(fontSize: 13, color: txtColor)),
      ]),
    );
}