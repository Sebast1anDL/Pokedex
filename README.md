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
  - `security/` - Utilidades de seguridad (hashing de contraseñas)

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

## Clases Principales

### Modelos
| Clase | Archivo | Descripción |
|-------|---------|-------------|
| `PokemonListItem` | `models/pokemon.dart` | Representa un ítem de la lista (id, nombre, tipos, imagen) |
| `PokemonDetail` | `models/pokemon_detail.dart` | Detalle completo de un Pokémon (stats, habilidades, evoluciones, etc.) |
| `PokedexEntry` | `models/pokemon_detail.dart` | Entrada de la Pokédex de una versión específica |
| `PokemonAbilityDetail` | `models/pokemon_detail.dart` | Habilidad con nombre, descripción y si es oculta |
| `PokemonMoveEntry` | `models/pokemon_detail.dart` | Movimiento con método de aprendizaje y nivel |
| `EvolutionNode` | `models/pokemon_detail.dart` | Nodo de cadena evolutiva (recursivo) |

### Servicios y Helpers
| Clase | Archivo | Descripción |
|-------|---------|-------------|
| `ApiService` | `core/services/api_service.dart` | Singleton que consume la PokeAPI (lista, búsqueda, filtros, detalle completo) |
| `DatabaseHelper` | `core/database/database_helper.dart` | Singleton que expone operaciones CRUD sobre usuarios y favoritos |
| `SharedPreferencesHelper` | `core/services/shared_preferences_helper.dart` | Persistencia de preferencias de usuario (tema, sesión) |
| `SecurityHelper` | `core/security/security_helper.dart` | Hashing SHA-256 + salt para contraseñas |

### Base de Datos (Drift/SQLite)
| Clase | Archivo | Descripción |
|-------|---------|-------------|
| `AppDatabase` | `core/database/app_database.dart` | Clase principal de la base de datos Drift |
| `Usuarios` | `core/database/app_database.dart` | Tabla de usuarios (id, username, password hasheado, createdAt) |
| `Favoritos` | `core/database/app_database.dart` | Tabla de favoritos (userId, pokemonId, nombre, imagen) |

### Pantallas principales
| Clase | Archivo | Descripción |
|-------|---------|-------------|
| `SplashScreen` | `features/splash/splash_screen.dart` | Pantalla de inicio con animación y verificación de sesión |
| `LoginScreen` | `features/auth/login_screen.dart` | Autenticación de usuario existente |
| `RegisterScreen` | `features/auth/register_screen.dart` | Registro de nuevo usuario |
| `HomeScreen` | `features/home/home_screen.dart` | Listado paginado de Pokémon con búsqueda y filtros |
| `DetailScreen` | `features/detail/detail_screen.dart` | Detalle completo con stats, habilidades, movimientos y evoluciones |
| `FavoritesScreen` | `features/favorites/favorites_screen.dart` | Lista de Pokémon marcados como favoritos |
| `SettingsScreen` | `features/settings/settings_screen.dart` | Configuración de tema (claro/oscuro) y cierre de sesión |

---

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

## CI/CD con Fastlane

El proyecto usa [Fastlane](https://fastlane.tools) para automatizar el ciclo de build y pruebas.

### Instalación (primera vez)
```bash
gem install fastlane
```

### Lanes disponibles

| Comando | Descripción |
|---------|-------------|
| `fastlane test` | Ejecuta los tests de Flutter (`flutter test`) |
| `fastlane build` | Genera el APK debug |
| `fastlane release` | Limpia, instala deps y genera APK release optimizado |
| `fastlane ci` | Pipeline completo: analyze → test → build release |

### Uso
```bash
# Desde la raíz del proyecto
fastlane build       # APK debug → build/app/outputs/flutter-apk/app-debug.apk
fastlane release     # APK release → build/app/outputs/flutter-apk/app-release.apk
fastlane ci          # Pipeline completo (ideal para entornos CI)
```

---

## Seguridad y Calidad

### Análisis Estático (SAST)
Se utilizó `flutter analyze` con un `analysis_options.yaml` personalizado que extiende `flutter_lints` con **75+ reglas** adicionales de seguridad y calidad (incluyendo `avoid_dynamic_calls`, `avoid_catches_without_on_clauses`, `unawaited_futures`, `avoid_print`, entre otras).

- **Reporte completo:** [`security/sast_report.md`](security/sast_report.md)

Para ejecutar el análisis:
```bash
flutter analyze
```

### Verificación de Dependencias (Dependency Check)
Se consultó la base de datos [OSV (Open Source Vulnerabilities)](https://osv.dev) de Google para los 18 paquetes del proyecto. Se encontró 1 CVE registrado (`dio` GHSA-9324-jv53-9cc8) que **no aplica** a la versión instalada (`5.4.0 ≥ 5.0.0` donde fue corregido).

- **Reporte completo:** [`security/dependency_check_report.md`](security/dependency_check_report.md)

Para verificar dependencias desactualizadas:
```bash
dart pub outdated
```

### Contraseñas
Las contraseñas de usuarios se almacenan con **hashing SHA-256 + salt compuesto** (nunca en texto plano). Ver `lib/core/security/security_helper.dart`.

---

## Puntos a tener en cuenta

- La app requiere conexión a internet para cargar la lista de Pokémon
- Los datos de favoritos se guardan localmente en el dispositivo (SQLite)

Esto se desarrolló con Flutter.
