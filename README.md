# LiftLog Pro

Aplicación Flutter para crear rutinas, registrar entrenamientos y consultar el progreso personal.

## Módulos

- Acceso local con registro e inicio de sesión.
- Inicio con rutina del día, meta semanal y actividad reciente.
- Rutinas por día con alta, consulta, edición y eliminación de ejercicios o del día completo.
- Sesiones con control de ejercicios completados e historial de levantamientos.
- Progreso con mediciones corporales y fotos capturadas con la cámara.
- Perfil con nombre, meta semanal, tema claro/oscuro y cierre de sesión.

La app móvil guarda sus datos en SQLite. Las cuentas se mantienen en el dispositivo y la contraseña se guarda como resumen SHA-256 con sal aleatoria. En Chrome se usa el almacenamiento local del navegador para revisar las pantallas y conservar los datos en ese navegador; el botón de fotos abre el selector de archivos.

La interfaz usa Material 3 y se adapta con contenido desplazable y un ancho máximo en pantallas grandes. El proyecto usa widgets y patrones trabajados en clase: `StatefulWidget`, `setState`, `ListView.builder`, `AlertDialog`, `DropdownButton`, `Dismissible`, `SnackBar` y `Navigator`.

## Ejecutar en Chrome

```powershell
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5000
```

Abre `http://127.0.0.1:5000` en el navegador.

## Ejecutar en Android

```powershell
flutter pub get
flutter run
```

Al crear una cuenta, podrás agregar ejercicios y rutinas. En Android, la pantalla de progreso abre la cámara del dispositivo.

## Revisar el proyecto

```powershell
flutter analyze
```
