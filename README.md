# LiftLog Pro

## Primer parcial

Esta entrega contiene una primera version navegable del proyecto:

- Acceso y registro de muestra con validacion basica de campos.
- Dashboard con accesos a los modulos.
- Ejercicios: alta, consulta, edicion y eliminacion por deslizamiento.
- Detalle de cada ejercicio.
- Progreso visual, preparado para integrar la camara.
- Perfil con una meta semanal temporal.

El acceso es una demostracion y no guarda cuentas. Los ejercicios se conservan en memoria y vuelven a los ejemplos al reiniciar la aplicacion. La pantalla de progreso todavia no captura fotos y la meta del perfil no se guarda permanentemente. La autenticacion local, SQLite y la camara se integraran en las siguientes etapas.

El codigo usa `StatefulWidget`, `setState`, `ListView.builder`, `AlertDialog`, `DropdownButton`, `Dismissible`, `SnackBar` y `Navigator.push`, patrones practicados en clase.

## Ejecutar en Chrome

```powershell
& "C:\src\flutter\bin\flutter.bat" run -d chrome
```

## Ejecutar en Android

```powershell
& "C:\src\flutter\bin\flutter.bat" run
```

## Analisis estatico

```powershell
& "C:\src\flutter\bin\flutter.bat" analyze --no-pub
```