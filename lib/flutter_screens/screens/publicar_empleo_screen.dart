import 'package:flutter/material.dart';
import '../data/empresa_service.dart';

class PublicarEmpleoScreen extends StatefulWidget {
  final EmpleoEmpresa? empleoExistente;
  const PublicarEmpleoScreen({super.key, this.empleoExistente});

  @override
  State<PublicarEmpleoScreen> createState() => _PublicarEmpleoScreenState();
}

class _PublicarEmpleoScreenState extends State<PublicarEmpleoScreen> {
  final _fk = GlobalKey<FormState>();

  late TextEditingController _titulo;
  late TextEditingController _descripcion;
  late TextEditingController _lugar;
  late TextEditingController _salario;
  late TextEditingController _horas;
  late TextEditingController _horIni;
  late TextEditingController _horFin;

  String _tipo = 'Medio tiempo';
  bool _esRemoto = false;
  final Set<String> _diasSeleccionados = {};
  bool _guardando = false;

  final List<String> _tipos = [
    'Tiempo completo', 'Medio tiempo', 'Por horas', 'Fines de semana'
  ];
  final List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo'
  ];

  bool get _esEdicion => widget.empleoExistente != null;

  @override
  void initState() {
    super.initState();
    final e = widget.empleoExistente;
    _titulo      = TextEditingController(text: e?.titulo ?? '');
    _descripcion = TextEditingController(text: e?.descripcion ?? '');
    _lugar       = TextEditingController(text: e?.lugar ?? '');
    _salario     = TextEditingController(text: e?.salario ?? '');
    _horas       = TextEditingController(text: e?.horas ?? '');
    _horIni      = TextEditingController(text: e?.horarioInicio ?? '');
    _horFin      = TextEditingController(text: e?.horarioFin ?? '');
    if (e != null) {
      _tipo = e.tipo.isNotEmpty ? e.tipo : 'Medio tiempo';
      _esRemoto = e.esRemoto;
      _diasSeleccionados.addAll(e.dias);
    }
  }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return;
    if (_diasSeleccionados.isEmpty) {
      _mostrarError('Selecciona al menos un día laboral.');
      return;
    }
    setState(() => _guardando = true);

    bool ok;
    if (_esEdicion) {
      await EmpresaService.editar(
        id:            widget.empleoExistente!.id,
        titulo:        _titulo.text.trim(),
        tipo:          _tipo,
        descripcion:   _descripcion.text.trim(),
        lugar:         _lugar.text.trim(),
        salario:       _salario.text.trim(),
        horas:         _horas.text.trim(),
        dias:          _diasSeleccionados.toList(),
        horarioInicio: _horIni.text.trim(),
        horarioFin:    _horFin.text.trim(),
        esRemoto:      _esRemoto,
      );
      ok = await EmpresaService.editar(
        id:            widget.empleoExistente!.id,
        titulo:        _titulo.text.trim(),
        tipo:          _tipo,
        descripcion:   _descripcion.text.trim(),
        lugar:         _lugar.text.trim(),
        salario:       _salario.text.trim(),
        horas:         _horas.text.trim(),
        dias:          _diasSeleccionados.toList(),
        horarioInicio: _horIni.text.trim(),
        horarioFin:    _horFin.text.trim(),
        esRemoto:      _esRemoto,
      );
    } else {
      ok = await EmpresaService.publicar(
        titulo:        _titulo.text.trim(),
        tipo:          _tipo,
        descripcion:   _descripcion.text.trim(),
        lugar:         _lugar.text.trim(),
        salario:       _salario.text.trim(),
        horas:         _horas.text.trim(),
        dias:          _diasSeleccionados.toList(),
        horarioInicio: _horIni.text.trim(),
        horarioFin:    _horFin.text.trim(),
        esRemoto:      _esRemoto,
      );
    }

    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_esEdicion
          ? '✓ Empleo actualizado correctamente'
          : '✓ Empleo publicado correctamente'),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      Navigator.pop(context, true);
    } else {
      _mostrarError('No se pudo guardar. Verifica que el servidor esté activo.');
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: Text(
          _esEdicion ? 'Editar oferta laboral' : 'Publicar oferta laboral',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              icon: _guardando
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check, color: Color(0xFF2563EB)),
              label: Text(
                _esEdicion ? 'Guardar' : 'Publicar',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
              onPressed: _guardando ? null : _guardar,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _fk,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        _esEdicion
                          ? 'Modifica los campos y toca Guardar.'
                          : 'Completa el formulario para publicar tu oferta.',
                        style: const TextStyle(
                          color: Color(0xFF1D4ED8), fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  _seccion('Información del puesto'),
                  _campo('Título del puesto *', _titulo,
                    icono: Icons.work_outline,
                    hint: 'Ej: Cajero, Mesero, Asistente',
                    validator: (v) => v!.isEmpty ? 'El título es obligatorio' : null),
                  _dropdown('Tipo de empleo', _tipo, _tipos,
                    (v) => setState(() => _tipo = v!)),
                  _campo('Descripción del puesto', _descripcion,
                    icono: Icons.description_outlined,
                    hint: 'Describe las tareas y responsabilidades',
                    maxLineas: 4),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Row(children: [
                      const Icon(Icons.wifi, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('¿Es trabajo remoto?')),
                      Switch(
                        value: _esRemoto,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (v) => setState(() => _esRemoto = v)),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  _seccion('Lugar y compensación'),
                  _campo('Ciudad / Municipio *', _lugar,
                    icono: Icons.location_on_outlined,
                    hint: 'Ej: Girardot, Bogotá',
                    validator: (v) => v!.isEmpty ? 'El lugar es obligatorio' : null),
                  _campo('Salario por hora (COP)', _salario,
                    icono: Icons.attach_money,
                    hint: 'Ej: 10000',
                    teclado: TextInputType.number),
                  _campo('Horas por semana', _horas,
                    icono: Icons.schedule_outlined,
                    hint: 'Ej: 10-20 horas/semana'),
                  const SizedBox(height: 20),

                  _seccion('Horario de trabajo'),
                  Row(children: [
                    Expanded(child: _campo('Hora inicio', _horIni,
                      icono: Icons.access_time, hint: 'Ej: 08:00')),
                    const SizedBox(width: 16),
                    Expanded(child: _campo('Hora fin', _horFin,
                      icono: Icons.access_time_filled_outlined,
                      hint: 'Ej: 13:00')),
                  ]),
                  const SizedBox(height: 8),

                  _seccion('Días laborales *'),
                  const Text('Selecciona los días requeridos:',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: _diasSemana.map((dia) {
                      final sel = _diasSeleccionados.contains(dia);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel) _diasSeleccionados.remove(dia);
                          else _diasSeleccionados.add(dia);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: sel
                              ? const Color(0xFF2563EB)
                              : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE5E7EB))),
                          child: Text(dia,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.grey[700],
                              fontWeight: sel
                                ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      icon: Icon(_esEdicion
                        ? Icons.save_outlined : Icons.publish_outlined),
                      label: Text(
                        _esEdicion ? 'Guardar cambios' : 'Publicar oferta laboral',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
      const SizedBox(height: 4),
      Container(height: 2, width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 12),
    ]),
  );

  Widget _campo(String label, TextEditingController ctrl, {
    IconData? icono, String? hint, int maxLineas = 1,
    TextInputType? teclado, String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
        fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLineas,
        keyboardType: teclado,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icono != null
            ? Icon(icono, color: const Color(0xFF2563EB), size: 20) : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        ),
      ),
    ]),
  );

  Widget _dropdown(String label, String valor, List<String> opciones,
      void Function(String?) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
        fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: valor,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          prefixIcon: const Icon(Icons.category_outlined,
            color: Color(0xFF2563EB), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        ),
        items: opciones.map((o) =>
          DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    ]),
  );

  @override
  void dispose() {
    for (final c in [_titulo, _descripcion, _lugar, _salario,
        _horas, _horIni, _horFin]) {
      c.dispose();
    }
    super.dispose();
  }
}