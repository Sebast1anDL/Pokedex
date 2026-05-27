# Informe Dependency Check — Pokédex App
**Tipo:** Análisis de Vulnerabilidades en Dependencias  
**Herramienta:** OSV API (osv.dev) + `dart pub outdated`  
**Fuente de datos:** [Open Source Vulnerabilities Database](https://osv.dev) — Google  
**Fecha:** 2026-05-26  
**Proyecto:** `pokedex_app` (Flutter 3.44.0 / Dart 3.12.0)  

---

## Resumen Ejecutivo

| Estado | Paquetes | Descripción |
|--------|----------|-------------|
| ✅ Sin CVEs conocidos | 17 | Sin vulnerabilidades registradas en OSV |
| ⚠️ CVE presente (mitigado) | 1 | `dio` — GHSA-9324-jv53-9cc8 (versión usada ≥ fix) |
| 🔴 Discontinuados | 2 | `build_resolvers`, `build_runner_core` |
| 🟡 Versión EOL disponible | 1 | `sqlite3_flutter_libs` |
| 🟡 Con actualizaciones mayores | 5 | `drift`, `flutter_riverpod`, `go_router`, etc. |

> ✅ **Ninguna vulnerabilidad activa afecta la versión instalada** de las dependencias directas del proyecto.

---

## Análisis de Vulnerabilidades (OSV)

### ⚠️ `dio` — CVE-2021-31402 / GHSA-9324-jv53-9cc8

| Campo | Detalle |
|-------|---------|
| **ID** | GHSA-9324-jv53-9cc8 / CVE-2021-31402 |
| **Severidad** | Medium |
| **Descripción** | CRLF Injection en el string del método HTTP. Si un atacante controla el método HTTP enviado al cliente `dio`, puede inyectar caracteres `\r\n` para manipular cabeceras HTTP. |
| **Versiones afectadas** | `< 5.0.0` |
| **Versión instalada** | `5.4.0` (ver `pubspec.lock`) |
| **Estado** | ✅ **MITIGADO** — la versión instalada es posterior al fix (commit `927f79e` en v5.0.0) |
| **Referencia** | https://github.com/cfug/dio/security/advisories/GHSA-9324-jv53-9cc8 |

---

## Paquetes sin Vulnerabilidades Conocidas

Los siguientes paquetes directos e indirectos relevantes fueron consultados en la base de datos OSV y **no presentan vulnerabilidades conocidas**:

| Paquete | Versión instalada | Estado OSV |
|---------|-------------------|------------|
| `flutter_riverpod` | 2.6.1 | ✅ Limpio |
| `riverpod_annotation` | 2.6.1 | ✅ Limpio |
| `go_router` | 14.8.1 | ✅ Limpio |
| `drift` | 2.28.2 | ✅ Limpio |
| `sqlite3_flutter_libs` | 0.5.42 | ✅ Limpio |
| `path_provider` | 2.1.x | ✅ Limpio |
| `path` | 1.9.x | ✅ Limpio |
| `shared_preferences` | 2.2.x | ✅ Limpio |
| `cached_network_image` | 3.3.x | ✅ Limpio |
| `crypto` | 3.0.3 | ✅ Limpio |
| `build_runner` | 2.5.4 | ✅ Limpio |
| `drift_dev` | 2.28.0 | ✅ Limpio |
| `flutter_lints` | 3.0.2 | ✅ Limpio |
| `riverpod` | 2.6.1 | ✅ Limpio |
| `sqlite3` | 2.9.4 | ✅ Limpio |
| `build_runner_core` | 9.1.2 | ✅ Limpio |
| `build_resolvers` | 2.5.4 | ✅ Limpio |

---

## Paquetes Discontinuados

| Paquete | Versión | Estado | Acción recomendada |
|---------|---------|--------|--------------------|
| `build_resolvers` | 2.5.4 | 🔴 Discontinuado | Dependencia transitiva de `build_runner`; actualizar `build_runner` a v3+ cuando sea compatible |
| `build_runner_core` | 9.1.2 | 🔴 Discontinuado | Ídem — dependencia transitiva |

> ⚠️ Estos paquetes son **dependencias transitivas** (no directas) y son utilizados exclusivamente en tiempo de desarrollo para generación de código (`drift`, `riverpod_generator`). No impactan la app en producción.

---

## Paquetes con Actualizaciones Mayores Disponibles

| Paquete | Versión actual | Versión latest | Notas |
|---------|---------------|----------------|-------|
| `drift` | 2.28.2 | 2.33.0 | Mejoras de rendimiento |
| `flutter_riverpod` | 2.6.1 | 3.3.1 | Breaking changes en v3 |
| `go_router` | 14.8.1 | 17.2.3 | Breaking changes en v15+ |
| `flutter_lints` | 3.0.2 | 6.0.0 | Nuevas reglas de lint |
| `sqlite3_flutter_libs` | 0.5.42 | 0.6.0+eol | La versión 0.6.0 está marcada EOL; migrar cuando esté disponible versión estable |

> Las versiones actuales son **funcionales y seguras**. Las actualizaciones mayores requieren ajustes de API y están fuera del alcance de esta entrega.

---

## Metodología

1. **Herramienta principal:** [OSV API v1](https://osv.dev/docs/) — base de datos de vulnerabilidades Open Source mantenida por Google, que agrega datos de GitHub Advisory, NVD, y otras fuentes.

2. **Comando ejecutado:**
   ```
   dart pub outdated
   ```
   Para identificar versiones instaladas vs. disponibles.

3. **Consulta OSV:** Para cada paquete del `pubspec.yaml` (18 paquetes analizados), se realizó una consulta POST a:
   ```
   POST https://api.osv.dev/v1/query
   {"package": {"name": "<pkg>", "ecosystem": "Pub"}}
   ```

4. **Script de análisis:** `security/check_deps.py`

---

## Conclusión

El análisis de dependencias no reveló vulnerabilidades activas en las versiones instaladas del proyecto. La única CVE encontrada (`dio` GHSA-9324-jv53-9cc8) **no aplica** a la versión en uso (`5.4.0 ≥ 5.0.0 fixed`). Se recomienda planificar la actualización de dependencias mayores en próximas iteraciones del proyecto.
