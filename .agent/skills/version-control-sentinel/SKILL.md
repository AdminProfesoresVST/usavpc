---
name: version-control-sentinel
description: Gestor de cambios y estabilidad. Mantiene un registro detallado de modificaciones, asegura la reversibilidad (atomicidad) y protege el código funcional existente contra refactorizaciones innecesarias.
---

# Version Control Sentinel Skill

## Filosofía: "Primero, no hacer daño" (Primum non nocere)

El código que funciona es **sagrado**. Nunca se modifica una función que ya cumple su propósito solo por "estética" o "preferencia", a menos que sea una optimización crítica solicitada explícitamente.

> [!CAUTION]
> Antes de tocar código funcional, pregúntate: "¿Esto ya funciona?" 
> Si la respuesta es SÍ y no hay bug reportado → **NO TOCAR.**

## Regla 1: La Bitácora de Cambios (The Why-Log)

Cada vez que generes código modificado, debes incluir al final un bloque **"CHANGELOG DE SESIÓN"** con este formato estricto:

```markdown
## 📝 CHANGELOG DE SESIÓN

| Archivo | Cambio | Por qué | Riesgo |
|---------|--------|---------|--------|
| `lib/auth/login_screen.dart` | Agregada validación de longitud en password | Evitar errores 400 de Supabase antes de enviar | 🟢 Bajo - Solo afecta formulario local |
| `lib/core/api/client.dart` | Añadido retry con exponential backoff | Mejorar resiliencia ante fallos de red | 🟡 Medio - Puede afectar tiempos de respuesta |
```

### Niveles de Riesgo

| Icono | Nivel | Descripción |
|-------|-------|-------------|
| 🟢 | Bajo | Cambio aislado, sin dependencias |
| 🟡 | Medio | Afecta múltiples componentes, requiere testing |
| 🔴 | Alto | Cambio estructural, puede causar regresiones |

## Regla 2: Atomicidad para Reversibilidad (Rollback Ready)

Para que un cambio sea fácil de deshacer:

### 2.1 Cambios Pequeños y Aislados

```
❌ PROHIBIDO: Una respuesta con
   - Bugfix en Login
   - Rediseño de Perfil  
   - Nueva feature de Chat
   
✅ CORRECTO: Tres respuestas separadas
   1. Solo Bugfix en Login
   2. Solo Rediseño de Perfil
   3. Solo feature de Chat
```

### 2.2 Conventional Commits Obligatorios

Provee siempre el mensaje de commit sugerido siguiendo el estándar [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Formato
<type>(<scope>): <description>

# Ejemplos
git commit -m "fix(auth): add password length validation to prevent api error"
git commit -m "feat(profile): add avatar upload functionality"
git commit -m "refactor(ui): extract common button styles to theme"
git commit -m "perf(list): implement pagination to reduce memory usage"
git commit -m "docs(readme): update installation instructions"
```

| Type | Uso |
|------|-----|
| `fix` | Corrección de bug |
| `feat` | Nueva funcionalidad |
| `refactor` | Cambio de código sin cambiar comportamiento |
| `perf` | Mejora de rendimiento |
| `style` | Cambios de formato (espacios, comas, etc.) |
| `test` | Agregar o corregir tests |
| `docs` | Solo documentación |
| `chore` | Mantenimiento (deps, configs) |

### 2.3 Backup Mental

Si vas a reescribir una lógica compleja, tienes dos opciones:

**Opción A - Deprecar en lugar de borrar:**
```dart
// DEPRECATED: 2026-01-21 - Reemplazado por validatePasswordV2
// Mantener hasta verificar que la nueva versión funciona en prod
// String? _validatePasswordOld(String value) {
//   return value.length < 6 ? 'Too short' : null;
// }

/// Nueva implementación con validación mejorada
String? validatePassword(String value) {
  if (value.length < 8) return 'Minimum 8 characters';
  if (!value.contains(RegExp(r'[A-Z]'))) return 'Needs uppercase';
  if (!value.contains(RegExp(r'[0-9]'))) return 'Needs number';
  return null;
}
```

**Opción B - Instruir commit previo:**
```markdown
> ⚠️ **ANTES DE APLICAR ESTE CAMBIO**
> Ejecuta: `git add -A && git commit -m "checkpoint: before auth refactor"`
> Esto te permite hacer rollback con: `git revert HEAD`
```

## Regla 3: Protección de Código Funcional (The Immutable Core)

Antes de modificar una función existente, sigue este flujo:

```
┌─────────────────────────────────────────────┐
│ ¿Este código ya funciona?                   │
└─────────────────┬───────────────────────────┘
                  │
         ┌───────▼───────┐
         │      SÍ       │
         └───────┬───────┘
                  │
    ┌─────────────▼─────────────┐
    │ ¿Hay bug reportado?       │
    └─────────────┬─────────────┘
                  │
         ┌───────▼───────┐
         │      NO       │ ──────▶ 🛑 NO TOCAR
         └───────┬───────┘
                  │
         ┌───────▼───────┐
         │      SÍ       │
         └───────┬───────┘
                  │
    ┌─────────────▼─────────────┐
    │ Arreglar bug mínimamente  │
    │ sin reestructurar         │
    └───────────────────────────┘
```

### Principio Open/Closed

Si se requiere nueva funcionalidad, **EXTENDER (No Modificar)**:

```dart
// ❌ PROHIBIDO - Modificar clase existente funcional
class UserRepository {
  Future<User> getUser(String id) async {
    // Lógica original que FUNCIONA
    // ...modificarla es peligroso
  }
}

// ✅ CORRECTO - Extender con nueva funcionalidad
class UserRepository {
  // Mantener original intacta
  Future<User> getUser(String id) async { ... }
  
  // NUEVA función separada
  Future<User> getUserWithCache(String id) async {
    final cached = await _cache.get(id);
    if (cached != null) return cached;
    final user = await getUser(id); // Reutiliza original
    await _cache.set(id, user);
    return user;
  }
}
```

## Procedimiento de "Quirófano Limpio"

Si detectas que una instrucción del usuario puede romper algo que ya funciona:

### Paso 1: DETENTE

No escribas código todavía.

### Paso 2: Emite Alerta de Regresión

```markdown
> ⚠️ **ALERTA DE REGRESIÓN POTENCIAL**
> 
> El cambio solicitado puede afectar:
> - `AuthService.login()` - Usado en 12 lugares
> - `TokenStorage.get()` - Dependencia crítica
> 
> **Riesgo:** 🔴 Alto - Cambio en lógica de autenticación
> 
> **Alternativa Segura:**
> En lugar de modificar `login()`, sugiero crear `loginWithBiometrics()` 
> como método separado que internamente llame al original.
> 
> ¿Deseas proceder con la alternativa segura o confirmas el cambio original?
```

### Paso 3: Esperar Confirmación

Solo procede si el usuario confirma explícitamente.

## Ejemplo de Salida Esperada

Al entregar un archivo modificado, el formato completo es:

```dart
// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... implementación ...
  }
  
  /// Validates password meets security requirements.
  /// Added: 2026-01-21 - Prevents API 400 errors
  String? _validatePassword(String value) {
    if (value.length < 8) {
      return context.l10n.passwordTooShort;
    }
    return null;
  }
}
```

Seguido del changelog:

```markdown
## 📝 CHANGELOG DE SESIÓN

| Archivo | Cambio | Por qué | Riesgo |
|---------|--------|---------|--------|
| `login_screen.dart` | Añadida `_validatePassword()` | Prevenir errores 400 de Supabase | 🟢 Bajo |

### Commit Sugerido
```bash
git commit -m "fix(auth): add password validation to prevent API errors"
```

### Rollback
Si causa problemas, eliminar el método `_validatePassword` y 
remover la referencia en el `TextFormField.validator`.
```

## Checklist del Sentinel

Antes de entregar código modificado:

- [ ] ¿Incluí el CHANGELOG de sesión?
- [ ] ¿Los cambios son atómicos (un solo propósito)?
- [ ] ¿Proporcioné el commit message en formato Conventional Commits?
- [ ] ¿Verifiqué que el código existente funciona antes de tocarlo?
- [ ] ¿Usé extensión en lugar de modificación cuando fue posible?
- [ ] ¿Alerté sobre posibles regresiones si las hay?
- [ ] ¿Proporcioné instrucciones de rollback?

## Consecuencia de Violación

Si el código entregado:
- No incluye CHANGELOG con justificación
- Mezcla múltiples cambios no relacionados
- Modifica código funcional sin razón documentada
- No proporciona commit message sugerido

**El código se considera INESTABLE y debe ser reestructurado en cambios atómicos.**
