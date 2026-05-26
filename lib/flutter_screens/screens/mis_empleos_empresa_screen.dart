
/// mis_empleos_empresa_screen.dart
import 'package:flutter/material.dart';
import '../data/empresa_service.dart';
import 'publicar_empleo_screen.dart';
 
class MisEmpleosEmpresaScreen extends StatefulWidget {
  const MisEmpleosEmpresaScreen({super.key});
 
  @override
  State<MisEmpleosEmpresaScreen> createState() =>
    _MisEmpleosEmpresaScreenState();
}
 
class _MisEmpleosEmpresaScreenState extends State<MisEmpleosEmpresaScreen> {
  bool _cargando = true;
 
  @override
  void initState() {
    super.initState();
    _recargar();
  }
 
  Future<void> _recargar() async {
    setState(() => _cargando = true);
    await EmpresaService.cargarEmpleos();
    if (mounted) setState(() => _cargando = false);
  }
 
  Future<void> _irAPublicar({EmpleoEmpresa? empleo}) async {
    final cambio = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) =>
        PublicarEmpleoScreen(empleoExistente: empleo)));
    if (cambio == true) _recargar();
  }
 
  Future<void> _confirmarEliminar(EmpleoEmpresa empleo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Eliminar oferta',
          style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${empleo.titulo}"?\n\nEsta acción no se puede deshacer.',
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
    if (ok == true) {
      EmpresaService.eliminar(empleo.id);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Oferta eliminada'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    }
  }
 
  void _verPostulados(EmpleoEmpresa e) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _PostuladosScreen(empleo: e)));
  }
 
  @override
  Widget build(BuildContext context) {
    final empleos = EmpresaService.empleos;
 
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Mis ofertas laborales',
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _recargar,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva oferta'),
              onPressed: () => _irAPublicar(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: _cargando
        ? const Center(child: CircularProgressIndicator())
        : empleos.isEmpty
          ? _pantallaVacia()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: empleos.length,
              itemBuilder: (ctx, i) => _tarjetaEmpleo(empleos[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _irAPublicar(),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Publicar oferta'),
      ),
    );
  }
 
  Widget _pantallaVacia() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.work_outline,
          size: 50, color: Color(0xFF2563EB)),
      ),
      const SizedBox(height: 20),
      const Text('No tienes ofertas publicadas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Publica tu primera oferta laboral\ny los estudiantes podrán postularse.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 14)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Publicar primera oferta'),
        onPressed: () => _irAPublicar(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ]),
  );
 
  Widget _tarjetaEmpleo(EmpleoEmpresa e) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.work,
              color: Color(0xFF2563EB), size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.titulo,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              Text(e.tipo,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20)),
            child: const Text('Activa',
              style: TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.bold,
                fontSize: 12)),
          ),
        ]),
 
        const Divider(height: 20),
 
        Wrap(spacing: 16, runSpacing: 8, children: [
          _detalle(Icons.location_on_outlined, e.lugar),
          _detalle(Icons.attach_money,
            e.salario.isNotEmpty ? '\$${e.salario}/hora' : 'Sin especificar'),
          _detalle(Icons.schedule, e.horas),
          _detalle(e.esRemoto ? Icons.wifi : Icons.business_outlined,
            e.esRemoto ? 'Remoto' : 'Presencial'),
        ]),
 
        if (e.dias.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: e.dias.map((dia) => Chip(
            label: Text(dia, style: const TextStyle(fontSize: 11)),
            backgroundColor: const Color(0xFFEEF2FF),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )).toList()),
        ],
 
        if (e.horarioInicio.isNotEmpty && e.horarioFin.isNotEmpty) ...[
          const SizedBox(height: 8),
          _detalle(Icons.access_time,
            'Horario: ${e.horarioInicio} — ${e.horarioFin}'),
        ],
 
        const SizedBox(height: 14),
 
        // Botones
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.people_outline, size: 17),
              label: const Text('Ver postulados'),
              onPressed: () => _verPostulados(e),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF059669),
                side: const BorderSide(color: Color(0xFF059669)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('Editar'),
              onPressed: () => _irAPublicar(empleo: e),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, size: 17),
              label: const Text('Eliminar'),
              onPressed: () => _confirmarEliminar(e),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ]),
      ]),
    ),
  );
 
  Widget _detalle(IconData icon, String texto) =>
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(texto, style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ]);
}
 
// ── Pantalla de postulados ──────────────────────────────────────────────────
 
class _PostuladosScreen extends StatefulWidget {
  final EmpleoEmpresa empleo;
  const _PostuladosScreen({required this.empleo});
 
  @override
  State<_PostuladosScreen> createState() => _PostuladosScreenState();
}
 
class _PostuladosScreenState extends State<_PostuladosScreen> {
  List<PostuladoInfo> _postulados = [];
  bool _cargando = true;
 
  @override
  void initState() {
    super.initState();
    _cargar();
  }
 
  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final data = await EmpresaService.getPostulados(widget.empleo.id);
    if (mounted) setState(() { _postulados = data; _cargando = false; });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: Text('Postulados — ${widget.empleo.titulo}',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _cargando
        ? const Center(child: CircularProgressIndicator())
        : _postulados.isEmpty
          ? _vacio()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _postulados.length,
              itemBuilder: (_, i) => _tarjeta(_postulados[i]),
            ),
    );
  }
 
  Widget _vacio() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people_outline, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('Aún no hay postulados',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Los estudiantes que se postulen\naparecerán aquí.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey)),
    ]),
  );
 
  Widget _tarjeta(PostuladoInfo p) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
 
        // Encabezado con nombre y estado
        Row(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            radius: 24,
            child: Text(
              p.nombreEstudiante.isNotEmpty
                ? p.nombreEstudiante[0].toUpperCase()
                : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.nombreEstudiante,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Postulado el ${p.fecha}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )),
          _badgeEstado(p.estado),
        ]),
 
        const Divider(height: 20),
 
        // Datos personales
        if (p.correo.isNotEmpty)
          _fila(Icons.email_outlined, p.correo),
        if (p.telefono.isNotEmpty)
          _fila(Icons.phone_outlined, p.telefono),
        if (p.carrera.isNotEmpty)
          _fila(Icons.school_outlined, p.carrera),
        if (p.semestre.isNotEmpty)
          _fila(Icons.calendar_today_outlined, 'Semestre ${p.semestre}'),
        if (p.habilidades.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.star_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(child: Text(p.habilidades,
              style: const TextStyle(fontSize: 13, color: Colors.grey))),
          ]),
        ],
      ]),
    ),
  );
 
  Widget _fila(IconData icon, String texto) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Icon(icon, size: 15, color: Colors.grey),
      const SizedBox(width: 8),
      Expanded(child: Text(texto,
        style: const TextStyle(fontSize: 13))),
    ]),
  );
 
  Widget _badgeEstado(String estado) {
    Color bg, fg;
    switch (estado.toLowerCase()) {
      case 'aceptado':
        bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); break;
      case 'rechazado':
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626); break;
      default:
        bg = const Color(0xFFFEF9C3); fg = const Color(0xFFB45309);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(estado,
        style: TextStyle(
          color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}