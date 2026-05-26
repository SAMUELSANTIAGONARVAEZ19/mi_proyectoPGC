import 'package:flutter/material.dart';
import '../data/favorites_service.dart';
import '../data/jobs_data.dart';
import 'job_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Empleo> get _favoritos => FavoritesService.getFavoritos();

  @override
  Widget build(BuildContext context) {
    final lista = _favoritos;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Mis Favoritos',
          style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: lista.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text('No tienes favoritos guardados',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 8),
                Text('Toca el corazón en cualquier empleo para guardarlo',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (ctx, i) {
              final e = lista[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      e.imagen, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56, height: 56,
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.work_outline, color: Colors.grey)),
                    ),
                  ),
                  title: Text(e.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(e.empresa,
                    style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      FavoritesService.toggleFavorito(e.id);
                      setState(() {});
                    },
                  ),
                  onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) =>
                      JobDetailScreen(job: e.toMap()))),
                ),
              );
            },
          ),
    );
  }
}