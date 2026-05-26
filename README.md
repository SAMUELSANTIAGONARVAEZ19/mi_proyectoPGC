#  UniTrabajo — Agencia de Empleo Estudiantil
### Universidad de Cundinamarca · Ingeniería de Software · 2025

> Plataforma web que conecta estudiantes universitarios con empleos flexibles adaptados a su horario académico.

---

##  Tabla de contenidos

- [Descripción del proyecto](#-descripción-del-proyecto)
- [Tecnologías utilizadas](#-tecnologías-utilizadas)
- [Requisitos previos](#-requisitos-previos)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Configuración de la base de datos](#-configuración-de-la-base-de-datos)
- [Instalación y ejecución del backend](#-instalación-y-ejecución-del-backend-django)
- [Instalación y ejecución del frontend](#-instalación-y-ejecución-del-frontend-flutter)
- [Cómo usar la aplicación](#-cómo-usar-la-aplicación)
- [Funcionalidades](#-funcionalidades)
- [Usuarios de prueba](#-usuarios-de-prueba)
- [Autores](#-autores)

---

##  Descripción del proyecto

**UniTrabajo** es una aplicación web desarrollada como proyecto académico para la Universidad de Cundinamarca. Su objetivo es reducir el desempleo juvenil conectando a estudiantes universitarios con empresas locales que necesiten personal de medio tiempo o por horas, respetando los horarios académicos de los jóvenes.

El sistema cuenta con tres tipos de usuario:
- **Estudiante** — busca empleos, se postula y gestiona sus aplicaciones
- **Empresa** — publica ofertas laborales y gestiona postulantes
- **Administrador** — supervisa toda la plataforma y ve estadísticas

---

##  Tecnologías utilizadas

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Flutter (Web) | 3.41.8 |
| Lenguaje frontend | Dart | 3.x |
| Backend | Django + Django REST Framework | 6.x |
| Lenguaje backend | Python | 3.13 |
| Base de datos | MariaDB / MySQL | 10.4+ |
| Conector BD | PyMySQL | 2.x |
| CORS | django-cors-headers | 4.x |
| Variables de entorno | python-decouple | 3.8 |

---

##  Requisitos previos

Antes de ejecutar el proyecto asegúrate de tener instalado:

- [Python 3.10 o superior](https://www.python.org/downloads/)
- [Flutter 3.x](https://flutter.dev/docs/get-started/install)
- [MAMP](https://www.mamp.info/) o [XAMPP](https://www.apachefriends.org/) (para correr MariaDB/MySQL)
- [VS Code](https://code.visualstudio.com/) con la extensión de Flutter y Dart
- [Git](https://git-scm.com/) (opcional)

---

##  Estructura del proyecto

```
flutter_application_pgc_samuel/
│
├── 📂 backend/                        ← Servidor Django (API REST)
│   ├── manage.py                      ← Comando principal de Django
│   ├── .env                           ← Variables de entorno (BD, clave secreta)
│   ├── requirements.txt               ← Librerías Python
│   │
│   ├── 📂 core/                       ← Configuración central de Django
│   │   ├── __init__.py                ← Configura PyMySQL como driver
│   │   ├── settings.py                ← Configuración del proyecto
│   │   ├── urls.py                    ← Rutas principales
│   │   └── wsgi.py
│   │
│   └── 📂 api/                        ← Lógica del negocio
│       ├── models.py                  ← Tablas de la base de datos
│       ├── views.py                   ← Endpoints de la API
│       ├── urls.py                    ← Rutas de la API
│       └── serializers.py
│
└── 📂 lib/                            ← Aplicación Flutter
    ├── main.dart                      ← Punto de entrada + tema oscuro/claro
    │
    ├── 📂 data/
    │   ├── auth_service.dart          ← Login, registro y sesión
    │   ├── jobs_data.dart             ← Datos de empleos y categorías
    │   ├── favorites_service.dart     ← Gestión de favoritos
    │   └── empresa_service.dart       ← Gestión de ofertas (empresa)
    │
    └── 📂 screens/
        ├── splash_screen.dart
        ├── login_screen.dart
        ├── register_screen.dart
        ├── home_screen.dart
        ├── jobs_screen.dart
        ├── job_detail_screen.dart
        ├── profile_screen.dart
        ├── admin_screen.dart
        ├── favorites_screen.dart
        ├── mis_empleos_empresa_screen.dart
        └── publicar_empleo_screen.dart
```

---

##  Configuración de la base de datos

### Paso 1 — Iniciar MariaDB

**Si usas MAMP:**
1. Abre la aplicación MAMP
2. Haz clic en **Start** (los dos puntos deben ponerse en verde)
3. MariaDB corre en el puerto **8889**

**Si usas XAMPP:**
1. Abre el panel de XAMPP
2. Haz clic en **Start** al lado de **MySQL**
3. MariaDB corre en el puerto **3306**

### Paso 2 — Crear la base de datos

Abre phpMyAdmin en tu navegador:
- MAMP: `http://localhost:8888/phpMyAdmin`
- XAMPP: `http://localhost/phpMyAdmin`

Ejecuta este comando SQL:

```sql
CREATE DATABASE proyecto_g26
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
```

### Paso 3 — Configurar el archivo `.env`

El archivo `.env` se encuentra en la carpeta `backend/`. Ábrelo y configura tus datos:

```env
SECRET_KEY=django-insecure-udec-2025-agencia-empleo
DEBUG=True
DB_NAME=proyecto_g26
DB_USER=root
DB_PASSWORD=           ← tu contraseña de MariaDB (vacío si no tiene)
DB_HOST=localhost
DB_PORT=3306           ← usa 8889 si tienes MAMP
```

---

## ⚙️ Instalación y ejecución del backend (Django)

Abre una **Terminal** y sigue estos pasos uno por uno:

### Paso 1 — Ir a la carpeta del backend

```bash
cd ~/Desktop/flutter_application_pgc_samuel/backend
```

### Paso 2 — Activar el entorno virtual

```bash
source venv/bin/activate
```

> Sabes que está activo cuando ves `(venv)` al inicio de la línea de la terminal.

### Paso 3 — Instalar las dependencias (solo la primera vez)

```bash
pip install -r requirements.txt
```

Si no tienes el archivo `requirements.txt`, instala manualmente:

```bash
pip install django djangorestframework PyMySQL django-cors-headers python-decouple
```

### Paso 4 — Crear las tablas en la base de datos

```bash
python manage.py makemigrations
python manage.py migrate
```

> Si todo sale bien verás una lista de tablas aplicadas sin errores en rojo.

### Paso 5 — Iniciar el servidor Django

```bash
python manage.py runserver
```

El backend está corriendo en: `http://127.0.0.1:8000`

Para verificar que funciona, abre en el navegador:
```
http://127.0.0.1:8000/api/empleos/
```
Deberías ver `[]` o una lista de empleos en formato JSON.

>  **Importante:** deja esta terminal abierta mientras usas la app. No la cierres.

---

##  Instalación y ejecución del frontend (Flutter)

Abre una **segunda Terminal** (sin cerrar la del backend) y sigue estos pasos:

### Paso 1 — Ir a la carpeta del proyecto Flutter

```bash
cd ~/Desktop/flutter_application_pgc_samuel
```

### Paso 2 — Instalar las dependencias Flutter (solo la primera vez)

```bash
flutter pub get
```

### Paso 3 — Habilitar soporte web (solo la primera vez)

```bash
flutter config --enable-web
```

### Paso 4 — Ejecutar la aplicación en Chrome

```bash
flutter run -d chrome
```

 Chrome se abre automáticamente con la aplicación.

> Si tienes varios dispositivos disponibles y te pregunta cuál usar, escribe el número correspondiente a **Chrome**.

---

##  Cómo usar la aplicación

Una vez que tanto Django como Flutter estén corriendo:

### Para estudiantes
1. Abre Chrome con la app corriendo
2. Haz clic en **Registrarse** y crea tu cuenta como estudiante
3. Completa tus datos: carrera, semestre, habilidades
4. Busca empleos por título o ciudad en la pantalla principal
5. Filtra por categoría o días disponibles
6. Entra al detalle de un empleo y presiona **Postularme**
7. Guarda tus empleos favoritos con el 
8. Ve tus postulaciones en **Mi Perfil**

### Para empresas
1. Inicia sesión con la cuenta de empresa
2. Haz clic en **Mis ofertas** en el menú superior
3. Presiona **Nueva oferta** o el botón flotante ➕
4. Completa el formulario: título, tipo, lugar, salario, horario y días
5. Publica la oferta — los estudiantes podrán verla inmediatamente
6. Desde **Mis ofertas** puedes **editar**  o **eliminar**  cualquier oferta

### Para administradores
1. Inicia sesión con la cuenta de administrador
2. Accede al **Panel Admin** desde el menú
3. Visualiza estadísticas de empleos por categoría
4. Consulta la lista completa de usuarios registrados

---

## Funcionalidades

| # | Funcionalidad | Rol |
|---|--------------|-----|
| 1 | Registro de estudiantes y empresas | Todos |
| 2 | Inicio de sesión con roles | Todos |
| 3 | Ver lista de empleos disponibles | Todos |
| 4 | Filtrar por categoría | Todos |
| 5 | Filtrar por días disponibles | Todos |
| 6 | Búsqueda por ciudad o municipio | Todos |
| 7 | Ver detalle completo de un empleo | Todos |
| 8 | Postularse a un empleo | Estudiante |
| 9 | Ver mis postulaciones | Estudiante |
| 10 | Guardar empleos favoritos | Estudiante |
| 11 | Publicar oferta laboral | Empresa |
| 12 | Editar oferta laboral | Empresa |
| 13 | Eliminar oferta laboral | Empresa |
| 14 | Aceptar o rechazar postulantes | Empresa |
| 15 | Panel de administrador | Admin |
| 16 | Estadísticas por categoría | Admin |
| 17 | Modo oscuro / claro | Todos |
| 18 | Editar perfil de usuario | Todos |

---

##  Usuarios de prueba

Puedes usar estas cuentas para probar la aplicación sin registrarte:

| Rol | Correo | Contraseña |
|-----|--------|-----------|
| Estudiante | `estudiante@universidad.edu` | `123456` |
| Empresa | `empresa@negocio.com` | `123456` |
| Administrador | `admin@unitrabajo.com` | `admin123` |

---

## Endpoints principales de la API

| Método | Endpoint | Descripción |
|--------|---------|-------------|
| `POST` | `/api/auth/registro/estudiante/` | Registrar estudiante |
| `POST` | `/api/auth/registro/empresa/` | Registrar empresa |
| `POST` | `/api/auth/login/` | Iniciar sesión |
| `GET` | `/api/empleos/` | Listar empleos |
| `POST` | `/api/empleos/publicar/` | Publicar empleo |
| `POST` | `/api/empleos/<id>/postular/` | Postularse |
| `GET` | `/api/mis-postulaciones/<id>/` | Ver mis postulaciones |
| `GET/PUT` | `/api/empleos/<id>/postulaciones/` | Gestionar postulantes |

---

##  Solución de problemas frecuentes

| Error | Solución |
|-------|---------|
| `python: command not found` | Usa `python3` en lugar de `python` |
| `(venv) no aparece` | Ejecuta `source venv/bin/activate` primero |
| `Can't connect to MySQL` | Verifica que MAMP o XAMPP esté corriendo |
| `SECRET_KEY not found` | Verifica que el archivo `.env` existe en `backend/` |
| `flutter: command not found` | Agrega Flutter al PATH del sistema |
| Error de puerto en BD | Cambia `DB_PORT=8889` en `.env` si usas MAMP |

---

##  Autores

| Nombre | Rol |
|--------|-----|
| Julian Fernando Correa Cardozo | Desarrollador |
| Samuel Santiago Narváez Martínez | Desarrollador |

**Programa:** Ingeniería de Software  
**Universidad:** Universidad de Cundinamarca — Sede Girardot  
**Año:** 2025

---

*Proyecto académico desarrollado con fines educativos — Universidad de Cundinamarca 2025*
