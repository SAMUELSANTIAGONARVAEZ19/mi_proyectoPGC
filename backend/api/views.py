from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Usuario, Estudiante, Empresa, Empleo, Postulacion


class RegistroEstudianteView(APIView):
    def post(self, request):
        d = request.data
        if Usuario.objects.filter(correo_institucional=d.get('correo_institucional')).exists():
            return Response({'error': 'El correo ya está registrado.'}, status=400)
        u = Usuario(
            nombre_completo=d['nombre_completo'],
            correo_institucional=d['correo_institucional'],
            rol='estudiante',
            telefono=d.get('telefono', ''),
        )
        u.set_password(d['password'])
        u.save()
        Estudiante.objects.create(
            id_estudiante=u,
            carrera=d.get('carrera', ''),
            semestre=d.get('semestre'),
            habilidades=d.get('habilidades', ''),
            intereses=d.get('intereses', ''),
        )
        return Response({'mensaje': 'Estudiante registrado.', 'id': u.id_usuario,
                         'rol': u.rol, 'nombre': u.nombre_completo}, status=201)


class RegistroEmpresaView(APIView):
    def post(self, request):
        d = request.data
        if Usuario.objects.filter(correo_institucional=d.get('correo_institucional')).exists():
            return Response({'error': 'El correo ya está registrado.'}, status=400)
        u = Usuario(
            nombre_completo=d['nombre_completo'],
            correo_institucional=d['correo_institucional'],
            rol='empresa',
            telefono=d.get('telefono', ''),
        )
        u.set_password(d['password'])
        u.save()
        Empresa.objects.create(
            id_empresa=u,
            nombre_comercial=d.get('nombre_comercial', ''),
            nit=d.get('nit', ''),
            direccion=d.get('direccion', ''),
            sector_economico=d.get('sector_economico', ''),
        )
        return Response({'mensaje': 'Empresa registrada.', 'id': u.id_usuario,
                         'rol': u.rol, 'nombre': u.nombre_completo}, status=201)


class LoginView(APIView):
    def post(self, request):
        correo   = request.data.get('correo_institucional', '')
        password = request.data.get('password', '')
        try:
            u = Usuario.objects.get(correo_institucional=correo)
        except Usuario.DoesNotExist:
            return Response({'error': 'Credenciales inválidas.'}, status=401)
        if not u.check_password(password):
            return Response({'error': 'Credenciales inválidas.'}, status=401)
        return Response({
            'id': u.id_usuario,
            'nombre': u.nombre_completo,
            'rol': u.rol,
            'correo': u.correo_institucional,
        })


class EmpleoListView(APIView):
    def get(self, request):
        qs = Empleo.objects.select_related('id_empresa').all().order_by('-id_empleo')
        ciudad = request.query_params.get('ciudad')
        titulo = request.query_params.get('titulo')
        if ciudad:
            qs = qs.filter(lugar__icontains=ciudad)
        if titulo:
            qs = qs.filter(titulo_puesto__icontains=titulo)
        data = [{
            'id_empleo':      e.id_empleo,
            'titulo_puesto':  e.titulo_puesto,
            'tipo_empleo':    e.tipo_empleo,
            'descripcion':    e.descripcion,
            'lugar':          e.lugar,
            'salario':        str(e.salario) if e.salario else None,
            'horas_semana':   e.horas_semana,
            'dias_laborales': e.dias_laborales,
            'horario_inicio': str(e.horario_inicio) if e.horario_inicio else None,
            'horario_fin':    str(e.horario_fin) if e.horario_fin else None,
            'empresa_nombre': e.id_empresa.nombre_comercial,
            'empresa_dir':    e.id_empresa.direccion,
        } for e in qs]
        return Response(data)


class EmpleoCreateView(APIView):
    def post(self, request):
        d = request.data
        empresa = get_object_or_404(Empresa, pk=d.get('empresa_id'))
        e = Empleo.objects.create(
            id_empresa=empresa,
            titulo_puesto=d['titulo_puesto'],
            tipo_empleo=d.get('tipo_empleo', ''),
            descripcion=d.get('descripcion', ''),
            lugar=d.get('lugar', ''),
            salario=d.get('salario'),
            horas_semana=d.get('horas_semana', ''),
            dias_laborales=d.get('dias_laborales', ''),
            horario_inicio=d.get('horario_inicio') or None,
            horario_fin=d.get('horario_fin') or None,
        )
        return Response({'mensaje': 'Empleo publicado.', 'id_empleo': e.id_empleo}, status=201)


class EmpleoUpdateView(APIView):
    def put(self, request, empleo_id):
        e = get_object_or_404(Empleo, pk=empleo_id)
        d = request.data
        e.titulo_puesto  = d.get('titulo_puesto', e.titulo_puesto)
        e.tipo_empleo    = d.get('tipo_empleo', e.tipo_empleo)
        e.descripcion    = d.get('descripcion', e.descripcion)
        e.lugar          = d.get('lugar', e.lugar)
        e.salario        = d.get('salario') or e.salario
        e.horas_semana   = d.get('horas_semana', e.horas_semana)
        e.dias_laborales = d.get('dias_laborales', e.dias_laborales)
        e.horario_inicio = d.get('horario_inicio') or e.horario_inicio
        e.horario_fin    = d.get('horario_fin') or e.horario_fin
        e.save()
        return Response({'mensaje': 'Empleo actualizado.'})


class MisEmpleosView(APIView):
    def get(self, request, empresa_id):
        empresa = get_object_or_404(Empresa, pk=empresa_id)
        qs = Empleo.objects.filter(id_empresa=empresa).order_by('-id_empleo')
        data = [{
    'id_empleo':      e.id_empleo,
    'titulo_puesto':  e.titulo_puesto,
    'tipo_empleo':    e.tipo_empleo,
    'descripcion':    e.descripcion,
    'lugar':          e.lugar,
    'salario':        str(e.salario) if e.salario else None,
    'horas_semana':   e.horas_semana,
    'dias_laborales': e.dias_laborales,
    'horario_inicio': str(e.horario_inicio) if e.horario_inicio else None,
    'horario_fin':    str(e.horario_fin) if e.horario_fin else None,
    'empresa_nombre': e.id_empresa.nombre_comercial,
    'empresa_dir':    e.id_empresa.direccion,
    'imagen_url':     e.imagen_url or '',
} for e in qs]


class PostularseView(APIView):
    def post(self, request, empleo_id):
        estudiante = get_object_or_404(Estudiante, pk=request.data.get('estudiante_id'))
        empleo     = get_object_or_404(Empleo, pk=empleo_id)
        if Postulacion.objects.filter(id_empleo=empleo, id_estudiante=estudiante).exists():
            return Response({'error': 'Ya te postulaste a este empleo.'}, status=400)
        p = Postulacion.objects.create(id_empleo=empleo, id_estudiante=estudiante)
        return Response({'mensaje': 'Postulación enviada.', 'id': p.id_postulacion}, status=201)


class MisPostulacionesView(APIView):
    def get(self, request, estudiante_id):
        qs = Postulacion.objects.filter(
            id_estudiante_id=estudiante_id
        ).select_related('id_empleo', 'id_empleo__id_empresa')
        data = [{
            'id_postulacion': p.id_postulacion,
            'estado':         p.estado,
            'fecha':          str(p.fecha)[:10],
            'empleo_titulo':  p.id_empleo.titulo_puesto,
            'empresa_nombre': p.id_empleo.id_empresa.nombre_comercial,
        } for p in qs]
        return Response(data)


class PostulacionesEmpresaView(APIView):
    def get(self, request, empleo_id):
        qs = Postulacion.objects.filter(
            id_empleo_id=empleo_id
        ).select_related('id_estudiante__id_estudiante')
        data = []
        for p in qs:
            u = p.id_estudiante.id_estudiante
            e = p.id_estudiante
            data.append({
                'id_postulacion':         p.id_postulacion,
                'estado':                 p.estado,
                'fecha':                  str(p.fecha)[:10],
                'estudiante_nombre':      u.nombre_completo,
                'estudiante_correo':      u.correo_institucional,
                'estudiante_telefono':    u.telefono or '',
                'estudiante_carrera':     e.carrera or '',
                'estudiante_semestre':    e.semestre,
                'estudiante_habilidades': e.habilidades or '',
            })
        return Response(data)

    def put(self, request, empleo_id):
        p = get_object_or_404(Postulacion, pk=request.data.get('id_postulacion'))
        p.estado = request.data.get('estado')
        p.save()
        return Response({'mensaje': f'Estado cambiado a {p.estado}.'})


class FotoPerfilView(APIView):
    def post(self, request, usuario_id):
        from .models import Usuario
        import base64
        u = get_object_or_404(Usuario, pk=usuario_id)
        foto_base64 = request.data.get('foto')
        if not foto_base64:
            return Response({'error': 'No se envió foto.'}, status=400)
        u.foto_perfil = foto_base64
        u.save()
        return Response({'mensaje': 'Foto guardada.'})

    def get(self, request, usuario_id):
        from .models import Usuario
        u = get_object_or_404(Usuario, pk=usuario_id)
        return Response({'foto': u.foto_perfil or ''})
class EmpleoImagenView(APIView):
    def put(self, request, empleo_id):
        e = get_object_or_404(Empleo, pk=empleo_id)
        imagen_url = request.data.get('imagen_url', '')
        e.imagen_url = imagen_url
        e.save()
        return Response({'mensaje': 'Imagen actualizada.'})
    
class AdminUsuariosView(APIView):
    def get(self, request):
        usuarios = Usuario.objects.all().order_by('rol', 'nombre_completo')
        data = [{
            'id':       u.id_usuario,
            'nombre':   u.nombre_completo,
            'correo':   u.correo_institucional,
            'rol':      u.rol,
            'telefono': u.telefono or '',
            'fecha':    str(u.fecha_registro)[:10],
        } for u in usuarios]
        return Response(data)
    
class AdminUsuarioDetailView(APIView):
    def delete(self, request, usuario_id):
        u = get_object_or_404(Usuario, pk=usuario_id)
        u.delete()
        return Response({'mensaje': 'Usuario eliminado.'})
    
class PerfilUpdateView(APIView):
    def put(self, request, usuario_id):
        u = get_object_or_404(Usuario, pk=usuario_id)
        u.nombre_completo = request.data.get('nombre_completo', u.nombre_completo)
        u.telefono = request.data.get('telefono', u.telefono)
        u.save()
        try:
            est = u.perfil_estudiante
            est.carrera = request.data.get('carrera', est.carrera)
            est.habilidades = request.data.get('habilidades', est.habilidades)
            est.save()
        except Exception:
            pass
        return Response({'mensaje': 'Perfil actualizado.'})