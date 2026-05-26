/// jobs_data.dart
/// UBICACIÓN: flutter_application_pgc_samuel/lib/data/jobs_data.dart

class Empleo {
  final String id;
  final String titulo;
  final String empresa;
  final String categoria; // 'desarrollo', 'oficina', 'servicios'
  final String ubicacion;
  final String salario;
  final String horas;
  final List<String> dias;
  final String descripcion;
  final List<String> requisitos;
  final bool esRemoto;
  final String imagen;

  const Empleo({
    required this.id,
    required this.titulo,
    required this.empresa,
    required this.categoria,
    required this.ubicacion,
    required this.salario,
    required this.horas,
    required this.dias,
    required this.descripcion,
    required this.requisitos,
    required this.esRemoto,
    required this.imagen,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'titulo': titulo, 'empresa': empresa,
    'categoria': categoria, 'ubicacion': ubicacion, 'salario': salario,
    'horas': horas, 'dias': dias, 'descripcion': descripcion,
    'requisitos': requisitos, 'esRemoto': esRemoto, 'imagen': imagen,
  };
}

const List<Empleo> empleos = [
  Empleo(id:'1', titulo:'Desarrollador Frontend Junior', empresa:'Tech Solutions',
    categoria:'desarrollo', ubicacion:'Remoto', salario:'\$117,000-156,000/hora',
    horas:'10-20 horas/semana', dias:['Lunes','Miércoles','Viernes'],
    descripcion:'Buscamos estudiante de ingeniería para desarrollo de interfaces web con React. Horarios flexibles que se adaptan a tu calendario académico.',
    requisitos:['Conocimientos en React','HTML/CSS básico','Disponibilidad de 10-20 hrs/semana'],
    esRemoto:true, imagen:'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400'),
  Empleo(id:'2', titulo:'Desarrollador Backend', empresa:'StartUp Labs',
    categoria:'desarrollo', ubicacion:'Híbrido', salario:'\$140,400-195,000/hora',
    horas:'15-25 horas/semana', dias:['Martes','Jueves','Sábado'],
    descripcion:'Desarrollo de APIs y servicios backend. Perfecto para estudiantes de computación que quieren experiencia real.',
    requisitos:['Node.js o Python','Bases de datos','Git'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400'),
  Empleo(id:'3', titulo:'Asistente Administrativo', empresa:'Corporación Global',
    categoria:'oficina', ubicacion:'Presencial', salario:'\$93,600-117,000/hora',
    horas:'15-20 horas/semana', dias:['Lunes','Martes','Miércoles'],
    descripcion:'Apoyo en tareas administrativas, manejo de documentos y atención telefónica. Horario compatible con estudios.',
    requisitos:['Excel básico','Comunicación efectiva','Organización'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400'),
  Empleo(id:'4', titulo:'Mesero/Mesera', empresa:'Restaurante El Buen Sabor',
    categoria:'servicios', ubicacion:'Presencial', salario:'\$7,800/hora + propinas',
    horas:'12-16 horas/semana', dias:['Viernes','Sábado','Domingo'],
    descripcion:'Atención a clientes en restaurante premium. Turnos de fin de semana, ideal para estudiantes.',
    requisitos:['Buena presencia','Atención al cliente','Disponibilidad fines de semana'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
  Empleo(id:'5', titulo:'Soporte Técnico IT', empresa:'TechHelp',
    categoria:'oficina', ubicacion:'Remoto', salario:'\$109,200-132,600/hora',
    horas:'10-15 horas/semana', dias:['Lunes','Miércoles','Viernes'],
    descripcion:'Soporte técnico remoto a usuarios. Resolución de problemas básicos de software y hardware.',
    requisitos:['Conocimientos básicos de IT','Buena comunicación','Paciencia'],
    esRemoto:true, imagen:'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400'),
  Empleo(id:'6', titulo:'Diseñador UI/UX Junior', empresa:'Creative Studio',
    categoria:'desarrollo', ubicacion:'Remoto', salario:'\$124,800-171,600/hora',
    horas:'12-18 horas/semana', dias:['Martes','Jueves','Viernes'],
    descripcion:'Diseño de interfaces y experiencias de usuario. Ideal para estudiantes de diseño o afines.',
    requisitos:['Figma o Adobe XD','Portfolio básico','Creatividad'],
    esRemoto:true, imagen:'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400'),
  Empleo(id:'7', titulo:'Barista', empresa:'Café Aroma',
    categoria:'servicios', ubicacion:'Presencial', salario:'\$85,800/hora + propinas',
    horas:'15-20 horas/semana', dias:['Lunes','Miércoles','Sábado'],
    descripcion:'Preparación de bebidas y atención al cliente. Ambiente universitario friendly.',
    requisitos:['Actitud positiva','Rapidez','Trabajo en equipo'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400'),
  Empleo(id:'8', titulo:'Analista de Datos Junior', empresa:'Data Insights',
    categoria:'oficina', ubicacion:'Híbrido', salario:'\$132,600-179,400/hora',
    horas:'15-20 horas/semana', dias:['Martes','Jueves','Viernes'],
    descripcion:'Análisis de datos y creación de reportes. Excelente oportunidad para estudiantes de estadística o economía.',
    requisitos:['Excel avanzado','SQL básico','Análisis de datos'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400'),
  Empleo(id:'9', titulo:'Community Manager', empresa:'Digital Marketing Pro',
    categoria:'oficina', ubicacion:'Remoto', salario:'\$109,200-148,200/hora',
    horas:'12-18 horas/semana', dias:['Lunes','Miércoles','Viernes'],
    descripcion:'Gestión de redes sociales y creación de contenido. Ideal para estudiantes de comunicación o marketing.',
    requisitos:['Conocimiento de redes sociales','Creatividad','Redacción'],
    esRemoto:true, imagen:'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=400'),
  Empleo(id:'10', titulo:'Tutor Académico', empresa:'Centro de Tutorías Universitarias',
    categoria:'servicios', ubicacion:'Presencial', salario:'\$124,800-171,600/hora',
    horas:'8-15 horas/semana', dias:['Martes','Jueves'],
    descripcion:'Apoyo académico a estudiantes en matemáticas, física o química. Comparte tu conocimiento.',
    requisitos:['Promedio alto en la materia','Paciencia','Habilidades de enseñanza'],
    esRemoto:false, imagen:'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=400'),
];

const List<Map<String, dynamic>> categorias = [
  {'id':'desarrollo', 'nombre':'Desarrollo & IT', 'descripcion':'Programación, desarrollo web, apps y soporte técnico', 'color': 0xFF2563EB, 'icono': 'code'},
  {'id':'oficina', 'nombre':'Oficina & Admin', 'descripcion':'Asistencia administrativa, análisis de datos y más', 'color': 0xFF7C3AED, 'icono': 'briefcase'},
  {'id':'servicios', 'nombre':'Servicios', 'descripcion':'Atención al cliente, hostelería, mantenimiento', 'color': 0xFF059669, 'icono': 'people'},
];
