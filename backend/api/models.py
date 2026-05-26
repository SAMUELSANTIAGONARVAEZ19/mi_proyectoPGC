from django.db import models
from django.contrib.auth.hashers import make_password, check_password as _check


class Usuario(models.Model):
    ROL = [('estudiante','Estudiante'),('empresa','Empresa')]
    id_usuario           = models.AutoField(primary_key=True)
    nombre_completo      = models.CharField(max_length=150)
    correo_institucional = models.CharField(max_length=100, unique=True)
    password             = models.CharField(max_length=255)
    rol                  = models.CharField(max_length=10, choices=ROL)
    telefono             = models.CharField(max_length=20, null=True, blank=True)
    fecha_registro       = models.DateTimeField(auto_now_add=True)
    foto_perfil          = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'usuarios'

    def set_password(self, raw):
        self.password = make_password(raw)

    def check_password(self, raw):
        return _check(raw, self.password)


class Estudiante(models.Model):
    id_estudiante = models.OneToOneField(
        Usuario, on_delete=models.CASCADE,
        db_column='id_estudiante', primary_key=True,
        related_name='perfil_estudiante'
    )
    carrera               = models.CharField(max_length=100, db_column='Carrera')
    semestre              = models.IntegerField(null=True, blank=True)
    habilidades           = models.TextField(null=True, blank=True)
    intereses             = models.TextField(null=True, blank=True)
    bloque_libre          = models.TextField(null=True, blank=True)
    ubicacion_tiempo_real = models.CharField(max_length=100, null=True, blank=True)

    class Meta:
        db_table = 'Estudiante'


class Empresa(models.Model):
    id_empresa          = models.OneToOneField(
        Usuario, on_delete=models.CASCADE,
        db_column='id_empresa', primary_key=True,
        related_name='perfil_empresa'
    )
    nombre_comercial    = models.CharField(max_length=150)
    nit                 = models.CharField(max_length=20, unique=True, null=True, blank=True)
    descripcion_empresa = models.TextField(null=True, blank=True)
    direccion           = models.CharField(max_length=150, null=True, blank=True)
    sector_economico    = models.CharField(max_length=100, null=True, blank=True)

    class Meta:
        db_table = 'empresas'


class Empleo(models.Model):
    id_empleo      = models.AutoField(primary_key=True)
    id_empresa     = models.ForeignKey(
        Empresa, on_delete=models.CASCADE,
        db_column='id_empresa', related_name='empleos'
    )
    titulo_puesto  = models.CharField(max_length=100)
    tipo_empleo    = models.CharField(max_length=50, null=True, blank=True)
    descripcion    = models.TextField(null=True, blank=True)
    horas_semana   = models.CharField(max_length=50, null=True, blank=True)
    lugar          = models.CharField(max_length=100, null=True, blank=True)
    salario        = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    horario_inicio = models.TimeField(null=True, blank=True)
    horario_fin    = models.TimeField(null=True, blank=True)
    dias_laborales = models.CharField(max_length=100, null=True, blank=True)
    imagen_url     = models.TextField(blank=True, default='')

    class Meta:
        db_table = 'empleos'



class Postulacion(models.Model):
    ESTADOS = [
        ('Pendiente','Pendiente'),
        ('Aceptado','Aceptado'),
        ('Rechazado','Rechazado'),
    ]
    id_postulacion = models.AutoField(primary_key=True)
    id_empleo      = models.ForeignKey(
        Empleo, on_delete=models.CASCADE,
        db_column='id_empleo', related_name='postulaciones'
    )
    id_estudiante  = models.ForeignKey(
        Estudiante, on_delete=models.CASCADE,
        db_column='id_estudiante', related_name='postulaciones'
    )
    estado = models.CharField(max_length=20, choices=ESTADOS, default='Pendiente')
    fecha  = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'postulaciones'
        unique_together = ('id_empleo', 'id_estudiante')

