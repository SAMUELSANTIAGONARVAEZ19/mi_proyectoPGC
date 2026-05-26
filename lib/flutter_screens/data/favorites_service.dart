import 'jobs_data.dart';

class FavoritesService {
  static final Set<String> _ids = {};

  static bool esFavorito(String id) => _ids.contains(id);

  static bool toggleFavorito(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
      return false;
    }
    _ids.add(id);
    return true;
  }

  static List<Empleo> getFavoritos() =>
    empleos.where((e) => _ids.contains(e.id)).toList();
}