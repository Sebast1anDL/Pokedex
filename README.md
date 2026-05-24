# Pokédex App

Una aplicación móvil interactiva de Pokédex desarrollada con Flutter. Permite explorar información sobre Pokémon, filtrar por tipos, buscar por nombre y guardar tus favoritos.

## Características

- Autenticación de usuarios con registro e inicio de sesión
- Listado completo de Pokémon consumido desde una API REST
- Búsqueda y filtrado por nombre y tipo de Pokémon
- Sistema de favoritos 
- Base de datos local SQLite, para almacenamiento de datos

##  Estructura del Proyecto

### `/lib`
Código fuente principal de la aplicación

- **`main.dart`** - Punto de entrada de la app y configuración de rutas

- **`core/`** - Funcionalidad central reutilizable
  - `database/` - Configuración de SQLite y manejo de base de datos
  - `services/` - Servicios principales como API REST

- **`features/`** - Características específicas organizadas por módulo
  - `splash/` - Pantalla de inicio/carga
  - `auth/` - Autenticación (login, registro)
  - `home/` - Pantalla principal con listado de Pokémon
  - `detail/` - Detalles específicos de cada Pokémon
  - `favorites/` - Gestión de Pokémon favoritos
  - `settings/` - Configuración de la app

- **`models/`** - Modelos de datos (clases Pokémon, para que funcionew la API)

### `/assets`
Recursos estáticos
- `images/` -  GIFs utilizados en la UI

### `/android`
Configuración específica para Android

## Requisitos Previos

- **Flutter SDK**: Versión 3.0.0 o superior
- **Dart SDK**: Incluido con Flutter
- **Android Studio**: Para ejecutar en emulador
- **Java JDK**: 11 o superior
- **Android SDK**: API Level 21 o superior

## Instalación

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Generar archivos necesarios (si es la primera vez)
```bash
flutter pub run build_runner build
```

## Cómo ejecutar

### En Emulador (Android Studio)

1. **Abre Android Studio**
2. **Inicia un emulador** desde el botón "AVD Manager"
3. **En la terminal**, desde la carpeta del proyecto, ejecuta:
   ```bash
   flutter run
   ```
   O si tienes múltiples dispositivos:
   ```bash
   flutter run -d emulator-5554
   ```

### En un Celular (dispositivo físico)

1. **Conecta tu celular por USB** a tu computadora
2. **Activa el modo de depuración USB**:
   - Ve a Configuración > Opciones de desarrollador (tócalo 7 veces en "Versión de compilación" si no ves esta opción)
   - Activa "Depuración USB"

3. **Verifica la conexión**:
   ```bash
   flutter devices
   ```
   Deberías ver tu dispositivo en la lista

4. **Ejecuta la app**:
   ```bash
   flutter run
   ```

### Desde Android Studio (interfaz gráfica)

1. **Abre el proyecto** en Android Studio
2. **Selecciona tu dispositivo** en el dropdown superior
3. **Haz clic en el botón "Run"** (ícono de play verde)

##  Dependencias principales

- **flutter_riverpod**: Gestión de estado
- **dio**: Peticiones HTTP a la API
- **drift**: ORM para SQLite
- **shared_preferences**: Almacenamiento local simple
- **cached_network_image**: Caché de imágenes de red

### El app no corre en el celular
- Verifica que el depuración USB esté activada
- Prueba desconectar y reconectar el USB
- Reinicia el servidor Dart con `flutter clean && flutter run`

### Errores de dependencias
Ejecuta:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build
```

## Puntos a tener en cuenta

- La app requiere conexión a internet para cargar la lista de Pokémon
- Los datos de favoritos se guardan localmente en el dispositivo(sqlite)

Esto se desarrollo con FLUTTER.
