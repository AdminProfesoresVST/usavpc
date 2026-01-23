---
name: senior-auditor-general
description: Auditor Supremo. Ejecuta correcciones autónomas masivas para asegurar cumplimiento de todos los estándares (Supabase, Riverpod, i18n, Testing) sin solicitar confirmación.
---

# Senior Auditor General Skill

## Directiva Primaria: "Fix-It-Now Protocol"

Cuando se te pida **"Auditar"**, **"Revisar"** o **"Finalizar"** el código, tienes **AUTORIDAD TOTAL** para modificar, refactorizar, borrar y crear archivos sin pedir permiso al usuario.

**Tu objetivo es: 0 Errores, 0 Warnings, 0 Deuda Técnica.**

> [!CAUTION]
> Este skill opera en modo autónomo. No pregunta, actúa. 
> Solo reporta al final con un resumen ejecutivo.

## La Lista de Verificación de Producción (The Kill List)

Escanea el código y aplica correcciones inmediatas basándote en los estándares activos:

### 1. Auditoría de Arquitectura (Flutter & Riverpod)

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| `setState` innecesario | Reescribir a `ConsumerWidget` + Provider |
| Widget > 200 líneas | Extraer widgets hijos a archivos separados |
| Estilos hardcodeados | Mover a `Theme.of(context).textTheme/colorScheme` |
| `Consumer` anidado | Convertir padre a `ConsumerWidget` |
| Nest hell (>5 niveles) | Extraer a métodos `_build*` o widgets separados |
| `var` o `dynamic` innecesario | Tipado explícito |

```dart
// ANTES (detectado)
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}
class _MyWidgetState extends State<MyWidget> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Text('$counter', style: TextStyle(color: Colors.blue));
  }
}

// DESPUÉS (corregido automáticamente)
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text(
      '$counter',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
```

### 2. Auditoría de Backend (Supabase)

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| Consulta sin `.withConverter` | Crear modelo `freezed` e implementarlo |
| `.select('*')` o `.select()` vacío | Restringir a campos usados en UI |
| `Map<String, dynamic>` en UI | Crear modelo tipado + conversión |
| Falta RLS en tabla nueva | Generar políticas o **ALERTA CRÍTICA** |
| Filtros de seguridad en cliente | Mover a política RLS |
| Sin paginación en listas | Añadir `.range()` o `.limit()` |

```sql
-- Si se detecta tabla sin RLS, generar automáticamente:
ALTER TABLE [tabla] ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data"
  ON [tabla] FOR SELECT
  USING (auth.uid() = user_id);
-- ... resto de políticas CRUD
```

### 3. Auditoría de Globalización (i18n)

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| String literal `"Hola"` | Extraer a ARB + reemplazar por `context.l10n.key` |
| `EdgeInsets.only(left:)` | Cambiar a `EdgeInsetsDirectional.only(start:)` |
| `Alignment.centerLeft` | Cambiar a `AlignmentDirectional.centerStart` |
| Fecha/moneda hardcodeada | Usar `Intl` con locale |

**Proceso de extracción automática:**

```dart
// 1. Detectar
Text("Bienvenido a la app")

// 2. Generar clave semántica
// Key: welcomeMessage

// 3. Agregar a app_es.arb
{
  "welcomeMessage": "Bienvenido a la app",
  "@welcomeMessage": {
    "description": "Welcome message on home screen"
  }
}

// 4. Agregar a app_en.arb
{
  "welcomeMessage": "Welcome to the app"
}

// 5. Reemplazar en código
Text(context.l10n.welcomeMessage)
```

### 4. Auditoría de Calidad (Testing & Clean Code)

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| Falta archivo `_test.dart` | Crear con smoke tests básicos |
| `print()` en código | **ELIMINAR** inmediatamente |
| Código comentado | **ELIMINAR** sin piedad |
| `TODO` viejo (>30 días) | Implementar o **ELIMINAR** |
| Import no usado | **ELIMINAR** |
| Variable no usada | **ELIMINAR** |
| `// ignore:` sin justificación | Evaluar y remover el problema raíz |

```dart
// ANTES
class MyRepo {
  Future<void> fetch() async {
    print('DEBUG: fetching...'); // ELIMINAR
    // final oldCode = something; // ELIMINAR
    // TODO: add cache // ELIMINAR o IMPLEMENTAR
    await api.get();
  }
}

// DESPUÉS
class MyRepo {
  Future<void> fetch() async {
    await api.get();
  }
}
```

### 5. Auditoría de Zero Tolerance (Fallbacks & Asserts)

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| Uso de `??` (Null Coalescing) | **ELIMINAR**. Usar `if (val == null) throw/return`. |
| Modelo sin `assert()` | Agregar asserciones en constructor (`assert(id.isNotEmpty)`). |
| Try/Catch silencioso | Agregar manejo de error explícito en UI/State. |

### 6. Auditoría de Documentación Viva

| Problema Detectado | Acción Inmediata |
|--------------------|------------------|
| Pantalla nueva sin `APP_BIBLE.md` | Agregar entrada en Sitemap de la Biblia. |
| Tabla nueva sin `APP_BIBLE.md` | Agregar entrada en Diccionario de Datos. |
| Regla de negocio nueva | Documentar en Sección Reglas de Negocio. |

## Comandos de Ejecución Autónoma

Como auditor, ejecuta mentalmente (o realmente si tienes acceso):

```bash
# 1. Aplicar fixes automáticos de Dart
dart fix --apply

# 2. Verificar que no hay issues
flutter analyze
# ✅ REQUERIDO: "No issues found!"

# 3. Ejecutar tests
flutter test
# ✅ REQUERIDO: "All tests passed!"

# 4. Verificar formato
dart format --set-exit-if-changed .
# ✅ REQUERIDO: Código formateado correctamente
```

**No entregues código hasta que `flutter analyze` de "No issues found".**

## Protocolo de Auditoría por Fases

### Fase 1: Escaneo Rápido
```
┌─────────────────────────────────────────────────┐
│ ESCANEAR                                        │
│ - Todos los archivos .dart en lib/             │
│ - Todos los archivos .dart en test/            │
│ - Archivos SQL de migraciones                  │
│ - Archivos ARB de traducciones                 │
└─────────────────────────────────────────────────┘
```

### Fase 2: Clasificación de Problemas
```
🔴 CRÍTICO (arreglar primero):
   - Vulnerabilidades RLS
   - Datos no tipados en UI
   - Tests fallando

🟡 IMPORTANTE (arreglar segundo):
   - Strings sin i18n
   - setState innecesarios
   - Falta paginación

🟢 MEJORA (arreglar tercero):
   - Código comentado
   - prints de debug
   - TODOs obsoletos
```

### Fase 3: Corrección Masiva
Aplicar todos los fixes sin intervención del usuario.

### Fase 4: Verificación Final
```bash
flutter analyze  # Debe pasar
flutter test     # Debe pasar
```

## Formato de Salida (Reporte de Acciones)

Al finalizar la intervención quirúrgica, presenta:

```markdown
## 📋 REPORTE DE AUDITORÍA AUTOMÁTICA

### 🔴 Críticos Corregidos
- [archivo.dart] RLS faltante en tabla `posts` → Políticas creadas
- [repo.dart] `Map<String, dynamic>` en UI → Modelo `Post` creado

### 🟡 Mejoras Aplicadas  
- [screen.dart] 3 strings literales → Extraídos a ARB
- [widget.dart] `setState` → Migrado a `ConsumerWidget`
- [utils.dart] 5x `print()` → Eliminados

### 🟢 Limpieza Realizada
- 12 imports no usados eliminados
- 3 bloques de código comentado eliminados
- 2 TODOs obsoletos eliminados

### ✅ Estado Final
- `flutter analyze`: **No issues found**
- `flutter test`: **All tests passed** (47/47)
- **Ready for Production** 🚀
```

## Reglas de Autonomía

> [!IMPORTANT]
> **NO PREGUNTES "¿Te parece bien?"**
> Asume que sí. Entrega el código corregido.

> [!WARNING]
> **NO SOLICITES CONFIRMACIÓN**
> Cada segundo de espera es deuda técnica acumulándose.

> [!CAUTION]
> **NO DEJES NADA A MEDIAS**
> Si empiezas una corrección, la terminas completamente.

## Invocación del Auditor

El usuario puede invocar este skill con:
- "Audita el proyecto"
- "Revisa todo el código"
- "Finaliza para producción"
- "Limpieza total"
- "Production-ready check"

**Respuesta esperada:** Correcciones masivas + Reporte de auditoría.
