import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/auth_service.dart';
import 'job_detail_screen.dart';

String _imagenPorTitulo(String titulo) {
  final t = titulo.toLowerCase();
  if (t.contains('developer') || t.contains('desarrollador') || t.contains('flutter') || t.contains('backend') || t.contains('frontend') || t.contains('programador') || t.contains('software')) return 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400';
  if (t.contains('diseñ') || t.contains('design') || t.contains('ui') || t.contains('ux') || t.contains('grafico')) return 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400';
  if (t.contains('mesero') || t.contains('restaurante') || t.contains('cocina') || t.contains('chef') || t.contains('barista') || t.contains('cafe')) return 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400';
  if (t.contains('mecan') || t.contains('taller') || t.contains('motor') || t.contains('auto') || t.contains('carro')) return 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400';
  if (t.contains('admin') || t.contains('oficina') || t.contains('asistente') || t.contains('secretar')) return 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400';
  if (t.contains('dato') || t.contains('data') || t.contains('analista') || t.contains('estadist')) return 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400';
  if (t.contains('marketing') || t.contains('community') || t.contains('redes') || t.contains('publicidad')) return 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=400';
  if (t.contains('tutor') || t.contains('profesor') || t.contains('docente') || t.contains('enseñ')) return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=400';
  if (t.contains('seguridad') || t.contains('vigilante') || t.contains('guardia')) return 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400';
  if (t.contains('aseo') || t.contains('limpieza') || t.contains('aseador')) return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400';
  if (t.contains('ventas') || t.contains('vendedor') || t.contains('comercial')) return 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400';
  if (t.contains('contab') || t.contains('finanz') || t.contains('contador')) return 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400';
  return 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400';
}

class JobsScreen extends StatefulWidget {
  final String? categoriaInicial;
  final String? busquedaInicial;
  final String? ciudadInicial;
  const JobsScreen({super.key, this.categoriaInicial, this.busquedaInicial, this.ciudadInicial});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  List<Map<String, dynamic>> _empleos = [];
  List<Map<String, dynamic>> _filtrados = [];
  bool _cargando = true;
  String _busqueda = '';
  String _ciudad = '';
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _busqueda = widget.busquedaInicial ?? '';
    _ciudad   = widget.ciudadInicial ?? '';
    _busquedaCtrl.text = _busqueda;
    _cargarEmpleos();
  }

  Future<void> _cargarEmpleos() async {
    setState(() => _cargando = true);
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/empleos/'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _empleos = data.map((e) => {
            'id':          e['id_empleo'].toString(),
            'id_empleo':   e['id_empleo'],
            'titulo':      e['titulo_puesto'] ?? '',
            'empresa':     e['empresa_nombre'] ?? '',
            'ubicacion':   e['lugar'] ?? '',
            'salario':     e['salario'] != null ? '\$${e['salario']}/hora' : 'Sin especificar',
            'horas':       e['horas_semana'] ?? '',
            'dias':        _parseDias(e['dias_laborales']),
            'descripcion': e['descripcion'] ?? '',
            'requisitos':  ['Disponibilidad horaria', 'Compromiso', 'Responsabilidad'],
            'esRemoto':    (e['lugar'] ?? '').toLowerCase().contains('remoto'),
            'imagen':      (e['imagen_url'] != null && e['imagen_url'].toString().isNotEmpty)
                               ? e['imagen_url'].toString()
                               : _imagenPorTitulo(e['titulo_puesto'] ?? ''),
            'tipo':        e['tipo_empleo'] ?? '',
          }).toList();
          _aplicarFiltros();
          _cargando = false;
        });
      }
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  List<String> _parseDias(dynamic dias) {
    if (dias == null) return [];
    if (dias is List) return dias.cast<String>();
    if (dias is String && dias.isNotEmpty) return dias.split(',').map((d) => d.trim()).toList();
    return [];
  }

  void _aplicarFiltros() {
    setState(() {
      _filtrados = _empleos.where((e) {
        final matchBus = _busqueda.isEmpty ||
          (e['titulo'] as String).toLowerCase().contains(_busqueda.toLowerCase()) ||
          (e['empresa'] as String).toLowerCase().contains(_busqueda.toLowerCase());
        final matchCiudad = _ciudad.isEmpty ||
          (e['ubicacion'] as String).toLowerCase().contains(_ciudad.toLowerCase());
        return matchBus && matchCiudad;
      }).toList();
    });
  }

  void _limpiar() {
    setState(() { _busqueda = ''; _ciudad = ''; _busquedaCtrl.clear(); });
    _aplicarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor    = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.grey;
    final panelColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final fillColor    = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);
    final borderColor  = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: panelColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          const Icon(Icons.work, color: Color(0xFF2563EB), size: 22),
          const SizedBox(width: 8),
          Text('UniTrabajo', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: textColor), onPressed: _cargarEmpleos),
          if (AuthService.estaAutenticado)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: Text('Mi Perfil', style: TextStyle(color: textColor))),
        ],
      ),
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 230, color: panelColor,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _busquedaCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, size: 18, color: subTextColor),
                  filled: true, fillColor: fillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (v) { _busqueda = v; _aplicarFiltros(); },
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                GestureDetector(onTap: _limpiar, child: const Text('Limpiar', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13))),
              ]),
              const SizedBox(height: 16),
              Text('Ciudad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
              const SizedBox(height: 8),
              TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Ej: Bogotá',
                  hintStyle: TextStyle(color: subTextColor),
                  filled: true, fillColor: fillColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (v) { _ciudad = v; _aplicarFiltros(); },
              ),
            ]),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trabajos Disponibles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 2),
              Text('${_filtrados.length} trabajos encontrados', style: TextStyle(color: subTextColor, fontSize: 14)),
              const SizedBox(height: 20),
              Expanded(
                child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _filtrados.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off, size: 64, color: subTextColor),
                        const SizedBox(height: 12),
                        Text('No hay empleos disponibles', style: TextStyle(color: subTextColor)),
                      ]))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360, mainAxisExtent: 360,
                          crossAxisSpacing: 16, mainAxisSpacing: 16,
                        ),
                        itemCount: _filtrados.length,
                        itemBuilder: (ctx, i) => _TarjetaEmpleo(empleo: _filtrados[i]),
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() { _busquedaCtrl.dispose(); super.dispose(); }
}

class _TarjetaEmpleo extends StatefulWidget {
  final Map<String, dynamic> empleo;
  const _TarjetaEmpleo({required this.empleo});
  @override
  State<_TarjetaEmpleo> createState() => _TarjetaEmpleoState();
}

class _TarjetaEmpleoState extends State<_TarjetaEmpleo> {
  bool _hover = false;

  Widget _imagenWidget(String imagen, bool isDark, Color subColor) {
    if (imagen.startsWith('data:image')) {
      try {
        final base64Str = imagen.split(',').last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.memory(bytes,
            height: 140, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 140,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              child: Icon(Icons.image_outlined, color: subColor, size: 40))),
        );
      } catch (_) {}
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.network(imagen,
        height: 140, width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 140,
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          child: Icon(Icons.image_outlined, color: subColor, size: 40))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e      = widget.empleo;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final textColor   = isDark ? Colors.white : Colors.black87;
    final subColor    = isDark ? Colors.white60 : Colors.grey;
    final dias = (e['dias'] as List? ?? []).cast<String>();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => JobDetailScreen(job: e))),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hover ? const Color(0xFF2563EB) : borderColor),
            boxShadow: _hover ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              _imagenWidget(e['imagen'] ?? '', isDark, subColor),
              Positioned(top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (e['esRemoto'] == true) ? const Color(0xFF7C3AED) : Colors.black87,
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    (e['esRemoto'] == true) ? 'Remoto' : 'Presencial',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                )),
            ]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['titulo'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(e['empresa'] ?? '', style: TextStyle(color: subColor, fontSize: 13)),
                const SizedBox(height: 8),
                _info(Icons.location_on_outlined, e['ubicacion'] ?? '', subColor),
                _info(Icons.attach_money, e['salario'] ?? '', subColor),
                if (dias.isNotEmpty) _info(Icons.calendar_today_outlined, dias.join(', '), subColor),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String texto, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Expanded(child: Text(texto, style: TextStyle(fontSize: 12, color: color), maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]),
  );
}