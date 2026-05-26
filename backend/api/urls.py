from django.urls import path
from . import views

urlpatterns = [
    path('auth/registro/estudiante/', views.RegistroEstudianteView.as_view()),
    path('auth/registro/empresa/',    views.RegistroEmpresaView.as_view()),
    path('auth/login/',               views.LoginView.as_view()),
    path('empleos/',                  views.EmpleoListView.as_view()),
    path('empleos/publicar/',         views.EmpleoCreateView.as_view()),
    path('empleos/mis/<int:empresa_id>/',           views.MisEmpleosView.as_view()),
    path('empleos/<int:empleo_id>/editar/',          views.EmpleoUpdateView.as_view()),
    path('empleos/<int:empleo_id>/postular/',        views.PostularseView.as_view()),
    path('empleos/<int:empleo_id>/postulaciones/',   views.PostulacionesEmpresaView.as_view()),
    path('mis-postulaciones/<int:estudiante_id>/',   views.MisPostulacionesView.as_view()),
    path('usuarios/<int:usuario_id>/foto/',          views.FotoPerfilView.as_view()),
    path('empleos/<int:empleo_id>/imagen/', views.EmpleoImagenView.as_view()),
    path('admin/usuarios/', views.AdminUsuariosView.as_view()),
    path('admin/usuarios/<int:usuario_id>/', views.AdminUsuarioDetailView.as_view()),
    path('usuarios/<int:usuario_id>/perfil/', views.PerfilUpdateView.as_view()),
]
