import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../data/jobs_data.dart';
import 'jobs_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(children: [
          const _Header(),
          _HeroSection(context),
          _CategoriasSection(context),
          const _PorQueSection(),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(children: [
        const Icon(Icons.work, color: Color(0xFF2563EB), size: 28),
        const SizedBox(width: 8),
        Text('UniTrabajo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
            color: textColor)),
        const Spacer(),
        if (AuthService.estaAutenticado) ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            child: Text('Favoritos', style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            child: Text('Mi Perfil', style: TextStyle(color: textColor)),
          ),

          // ── BOTÓN EMPRESA: solo aparece si el rol es empresa ────
          if (AuthService.esEmpresa)
            TextButton.icon(
              icon: const Icon(Icons.business_center_outlined,
                size: 17, color: Color(0xFF2563EB)),
              label: const Text('Mis ofertas',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold)),
              onPressed: () =>
                Navigator.pushNamed(context, '/mis-empleos-empresa'),
            ),

          // ── BOTÓN ADMIN: solo aparece si el rol es admin ────────
          if (AuthService.esAdmin)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              child: const Text('Admin',
                style: TextStyle(color: Color(0xFF2563EB))),
            ),

          OutlinedButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? Colors.white30 : const Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Salir', style: TextStyle(color: textColor)),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Iniciar Sesión', style: TextStyle(color: textColor)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF2563EB) : Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Registrarse'),
          ),
        ],
      ]),
    );
  }
}

class _HeroSection extends StatefulWidget {
  final BuildContext ctx;
  const _HeroSection(this.ctx);

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final _busquedaCtrl = TextEditingController();
  final _ciudadCtrl   = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 72),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Encuentra el trabajo perfecto para\ntu horario universitario',
          style: TextStyle(color: Colors.white, fontSize: 42,
            fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 16),
        const Text(
          'Conectamos estudiantes con empleos flexibles que se adaptan\na tu calendario académico',
          style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 16),
        ),
        const SizedBox(height: 36),

        Container(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(children: [
            Expanded(
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _busquedaCtrl,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Buscar trabajos...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => JobsScreen(
                    busquedaInicial: _busquedaCtrl.text,
                    ciudadInicial:   _ciudadCtrl.text,
                  ))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Buscar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        Container(
          constraints: const BoxConstraints(maxWidth: 640),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: TextField(
            controller: _ciudadCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Filtrar por ciudad o municipio (ej: Girardot)',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.location_on_outlined,
                color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(spacing: 28, runSpacing: 12, children: [
          _stat(Icons.trending_up, '${empleos.length} trabajos activos'),
          _stat(Icons.access_time, 'Horarios flexibles'),
          _stat(Icons.verified_outlined, 'Empresas verificadas'),
        ]),
      ]),
    );
  }

  Widget _stat(IconData icon, String texto) =>
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white70, size: 18),
      const SizedBox(width: 6),
      Text(texto,
        style: const TextStyle(color: Colors.white, fontSize: 14)),
    ]);

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    _ciudadCtrl.dispose();
    super.dispose();
  }
}

class _CategoriasSection extends StatelessWidget {
  final BuildContext ctx;
  const _CategoriasSection(this.ctx);

  int _count(String id) => empleos.where((e) => e.categoria == id).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Categorías de trabajo',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 6),
        Text('Explora oportunidades en diferentes áreas',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey, fontSize: 15)),
        const SizedBox(height: 36),
        LayoutBuilder(builder: (_, c) {
          final cols = c.maxWidth > 700 ? 3 : 1;
          final itemW = cols == 3 ? (c.maxWidth - 48) / 3 : c.maxWidth;
          return Wrap(
            spacing: 24, runSpacing: 24,
            children: categorias.map((cat) => SizedBox(
              width: itemW,
              child: _TarjetaCategoria(
                cat: cat,
                count: _count(cat['id']),
                onTap: () => Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) =>
                    JobsScreen(categoriaInicial: cat['id']))),
              ),
            )).toList(),
          );
        }),
      ]),
    );
  }
}

class _TarjetaCategoria extends StatefulWidget {
  final Map<String, dynamic> cat;
  final int count;
  final VoidCallback onTap;
  const _TarjetaCategoria({
    required this.cat, required this.count, required this.onTap});

  @override
  State<_TarjetaCategoria> createState() => _TarjetaCategoriaState();
}

class _TarjetaCategoriaState extends State<_TarjetaCategoria> {
  bool _hover = false;

  IconData _icono(String id) {
    switch (id) {
      case 'desarrollo': return Icons.code;
      case 'oficina':    return Icons.work_outline;
      default:           return Icons.people_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color  = Color(widget.cat['color'] as int);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hover ? color
                : (isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB)),
              width: _hover ? 2 : 1,
            ),
            boxShadow: _hover ? [
              BoxShadow(color: color.withOpacity(0.15),
                blurRadius: 20, offset: const Offset(0, 8))
            ] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(14)),
                child: Icon(_icono(widget.cat['id']),
                  color: Colors.white, size: 26),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: _hover
                  ? (Matrix4.identity()..translate(4.0, 0.0))
                  : Matrix4.identity(),
                child: Icon(Icons.arrow_forward,
                  color: _hover ? color
                    : (isDark ? Colors.white38 : Colors.grey),
                  size: 22),
              ),
            ]),
            const SizedBox(height: 20),
            Text(widget.cat['nombre'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 6),
            Text(widget.cat['descripcion'],
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey,
                fontSize: 13, height: 1.4)),
            const SizedBox(height: 16),
            Text('${widget.count} trabajos disponibles',
              style: TextStyle(fontWeight: FontWeight.w600,
                fontSize: 13, color: color)),
          ]),
        ),
      ),
    );
  }
}

class _PorQueSection extends StatelessWidget {
  const _PorQueSection();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(children: [
        Text('¿Por qué UniTrabajo?',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 6),
        Text('La mejor plataforma para estudiantes universitarios',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.grey, fontSize: 15)),
        const SizedBox(height: 48),
        Wrap(spacing: 40, runSpacing: 40, children: [
          _feature(context, Icons.access_time,
            const Color(0xFFDBEAFE), const Color(0xFF2563EB),
            'Horarios Flexibles',
            'Elige cuándo y cuánto quieres trabajar. Adapta tu empleo a tu horario de clases.'),
          _feature(context, Icons.search,
            const Color(0xFFEDE9FE), const Color(0xFF7C3AED),
            'Fácil de Encontrar',
            'Busca empleos por categoría, ubicación o días disponibles en segundos.'),
          _feature(context, Icons.verified_user_outlined,
            const Color(0xFFD1FAE5), const Color(0xFF059669),
            'Empresas Verificadas',
            'Todas las empresas pasan por un proceso de verificación para tu seguridad.'),
        ]),
      ]),
    );
  }

  Widget _feature(BuildContext context, IconData icon, Color bg, Color fg,
      String titulo, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(width: 260, child: Column(children: [
      Container(width: 68, height: 68,
        decoration: BoxDecoration(
          color: isDark ? fg.withOpacity(0.2) : bg,
          shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: 32)),
      const SizedBox(height: 18),
      Text(titulo,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 8),
      Text(desc, textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? Colors.white60 : Colors.grey,
          fontSize: 13, height: 1.6)),
    ]));
  }
}