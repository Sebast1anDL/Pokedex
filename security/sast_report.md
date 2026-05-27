# Informe SAST — Pokédex App
**Tipo:** Static Application Security Testing (Análisis Estático)  
**Herramienta:** `flutter analyze` + `analysis_options.yaml` personalizado  
**Fecha:** 2026-05-26  
**Proyecto:** `pokedex_app` (Flutter 3.44.0 / Dart 3.12.0)  
**Branch:** `register`

---

## Resumen Ejecutivo

| Categoría            | Cantidad | Severidad  |
|----------------------|----------|------------|
| `avoid_dynamic_calls`| 96       | ⚠️ Warning  |
| `avoid_catches_without_on_clauses` | 10 | ⚠️ Warning |
| `unawaited_futures`  | 6        | ⚠️ Warning  |
| `deprecated_member_use` | 1     | ℹ️ Info     |
| `unnecessary_lambdas`| 1        | ℹ️ Info     |
| `avoid_redundant_argument_values` | 3 | ℹ️ Info |
| **Total**            | **111**  |             |

> ℹ️ No se encontraron **errores de compilación** ni hallazgos de severidad **crítica** en el análisis estático post-corrección. La vulnerabilidad de contraseñas en texto plano fue **remediada** antes de este análisis.

---

## Hallazgos por Categoría

### 🔴 Remediado — Contraseñas en texto plano (previo al análisis)

| Campo | Detalle |
|-------|---------|
| **Archivo** | `lib/core/database/database_helper.dart` |
| **Descripción** | Las contraseñas de usuarios se almacenaban y comparaban en texto plano en la base de datos SQLite local. |
| **Riesgo** | Un atacante con acceso físico al dispositivo podría extraer el archivo `.db` y leer todas las contraseñas. |
| **Remediación** | Se implementó hashing con **SHA-256 + salt compuesto** (appSalt + username) usando el paquete `crypto`. Ver `lib/core/security/security_helper.dart`. |
| **Estado** | ✅ **CORREGIDO** |

---

### ⚠️ avoid_dynamic_calls — 96 ocurrencias

| Campo | Detalle |
|-------|---------|
| **Archivo principal** | `lib/core/services/api_service.dart` |
| **Descripción** | Acceso a propiedades/métodos sobre valores de tipo `dynamic` sin conversión de tipo explícita. Las respuestas JSON de la PokeAPI se manipulan mediante índices dinámicos (`response.data['key']`). |
| **Riesgo** | Si la API devuelve una estructura inesperada, el acceso dinámico puede lanzar excepciones no controladas en runtime. En combinación con `catch (e)` genérico, los errores quedan silenciados y el estado de la app es indefinido. |
| **Remediación sugerida** | Tipar explícitamente las respuestas con `as Map<String, dynamic>` y usar modelos `fromJson()` en lugar de acceso directo al mapa dinámico. |
| **Estado** | ⚠️ Pendiente de refactor (no bloquea funcionalidad actual) |

**Ejemplo de ocurrencias:**
```
lib/core/services/api_service.dart:35 — response.data['count']
lib/core/services/api_service.dart:37 — response.data['results']
lib/core/services/api_service.dart:54 — data['id']
lib/core/services/api_service.dart:55 — data['name']
... (96 ocurrencias en total)
```

---

### ⚠️ avoid_catches_without_on_clauses — 10 ocurrencias

| Campo | Detalle |
|-------|---------|
| **Archivos** | `api_service.dart`, `home_screen.dart`, `detail_screen.dart`, `favorites_screen.dart` |
| **Descripción** | Uso de bloques `catch (e)` genéricos que capturan **cualquier** tipo de excepción, incluyendo errores de sistema como `OutOfMemoryError` o `StackOverflowError`. |
| **Riesgo** | Mascara errores críticos de la aplicación, dificulta el diagnóstico y puede ocultar problemas de seguridad como fallos de validación de certificados TLS. |
| **Remediación sugerida** | Reemplazar `catch (e)` por `on DioException catch (e)` o `on Exception catch (e)` según el contexto. |
| **Estado** | ⚠️ Pendiente |

**Ejemplo:**
```dart
// ANTES (inseguro)
} catch (e) {
  return null;
}

// DESPUÉS (recomendado)
} on DioException catch (e) {
  debugPrint('API error: ${e.message}');
  return null;
}
```

---

### ⚠️ unawaited_futures — 6 ocurrencias

| Campo | Detalle |
|-------|---------|
| **Archivos** | `login_screen.dart:53`, `register_screen.dart:64`, `settings_screen.dart:72`, `splash_screen.dart:44`, `splash_screen.dart:59`, `splash_screen.dart:61` |
| **Descripción** | Llamadas a funciones `async` sin `await`, lo que puede causar race conditions o que errores en operaciones asíncronas no sean capturados. |
| **Riesgo** | En pantallas de autenticación (`login_screen`, `register_screen`), un Future no esperado podría resultar en que el flujo continúe antes de que el login/registro se complete, creando estados inconsistentes de sesión. |
| **Remediación sugerida** | Agregar `await` o `unawaited()` explícito de `package:flutter/foundation.dart`. |
| **Estado** | ⚠️ Pendiente |

---

### ℹ️ Informativo — 5 ocurrencias

| Regla | Archivo | Descripción |
|-------|---------|-------------|
| `deprecated_member_use` | `settings_screen.dart:146` | `activeColor` deprecado, usar `activeThumbColor` |
| `unnecessary_lambdas` | `detail_screen.dart:505` | Closure reemplazable por tearoff |
| `avoid_redundant_argument_values` (×3) | `home_screen.dart`, `home_styles.dart`, `main.dart` | Argumentos con valor por defecto redundante |

---

## Configuración SAST Aplicada

El archivo `analysis_options.yaml` fue extendido con **75+ reglas** adicionales de calidad y seguridad sobre la base de `package:flutter_lints/flutter.yaml`, incluyendo:

- `avoid_dynamic_calls` — detección de acceso dinámico sin tipo
- `avoid_catches_without_on_clauses` — catch genérico
- `unawaited_futures` — Futures no esperados
- `avoid_print` — logging en producción
- `cancel_subscriptions` — memory leaks por streams
- `close_sinks` — memory leaks por sinks
- `prefer_final_fields` / `prefer_final_locals` — inmutabilidad

---

## Conclusión

El análisis estático no reveló vulnerabilidades críticas en el código **post-remediación**. El hallazgo más significativo (contraseñas en texto plano) fue **corregido** durante este proceso. Los warnings restantes son mejoras de calidad de código que no representan riesgos de seguridad inmediatos pero que se recomienda corregir en iteraciones futuras.
