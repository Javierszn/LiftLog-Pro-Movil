# LiftLog Pro

Aplicación Flutter para organizar rutinas de fuerza y llevar un registro personal de entrenamiento.

## Funciones

- Pantalla de acceso y panel principal.
- Plan semanal con rutinas por día.
- Sesión de entrenamiento con lista de ejercicios y control de avance.
- Catálogo de ejercicios: agregar, consultar, editar y eliminar.
- Registro de peso corporal con historial.
- Perfil con meta semanal.

El acceso valida los campos y muestra el panel; no crea usuarios ni envía credenciales a un servicio. Los ejercicios, mediciones y meta semanal se mantienen en memoria durante la sesión. El proyecto está desarrollado con widgets de Flutter como `StatefulWidget`, `setState`, `ListView.builder`, `AlertDialog`, `DropdownButton`, `Dismissible`, `SnackBar` y `Navigator`.

## Ejecutar en Chrome

```powershell
flutter pub get
flutter run -d chrome
```

## Ejecutar en Android

```powershell
flutter pub get
flutter run
```
