import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../data/postulaciones_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});
  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late Future<List<Postulacion>> _futurePostulaciones;

  @override
  void initState() {
    super.initState();
    final id = AuthService.usuarioActual?.id ?? '';
    _futurePostulaciones = PostulacionesService.getMisPostulaciones(id);
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Aceptado':  return const Color(0xFF059669);
      case 'Rechazado': return const Color(0xFFDC2626);
      default:          return const Color(0xFFD97706);
    }
  }

  IconData _estadoIcon(String estado) {
    switch (estado) {
      case 'Aceptado':  return Icons.check_circle_outline;
      case 'Rechazado': return Icons.cancel_outlined;
      default:          return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final greyText  = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Mis Postulaciones',
          style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Postulacion>>(
        future: _futurePostulaciones,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text('Error al cargar postulaciones',
                style: TextStyle(color: greyText)));
          }

          final lista = snap.data ?? [];

          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 72, color: greyText),
                  const SizedBox(height: 16),
                  Text('No tienes postulaciones aún',
                    style: TextStyle(fontSize: 16, color: greyText)),
                  const SizedBox(height: 8),
                  Text('Explora empleos y postúlate',
                    style: TextStyle(fontSize: 13, color: greyText)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Ver empleos'),
                    onPressed: () => Navigator.pushNamed(context, '/jobs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final p = lista[i];
              final color = _estadoColor(p.estado);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    // Ícono estado
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_estadoIcon(p.estado), color: color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.empleoTitulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(p.empresaNombre,
                            style: TextStyle(color: greyText, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('Postulado el ${p.fecha}',
                            style: TextStyle(fontSize: 11, color: greyText)),
                        ],
                      ),
                    ),
                    // Badge estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(p.estado,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}