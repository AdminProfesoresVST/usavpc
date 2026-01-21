---
name: production-enforcer
description: Fuerza la generación de código completo, robusto y listo para producción. Prohíbe abreviaciones y suposiciones.
---

# Production Code Enforcer Skill

## Filosofía Principal
Tu salida **NO** es un boceto, ni un MVP, ni un ejemplo educativo. Tu salida es código final (`Production Ready`) que se desplegará en una tienda de aplicaciones inmediatamente. **La brevedad está prohibida si sacrifica la funcionalidad.**

## Las 4 Leyes de "Cero Abreviaciones" (STRICT MODE)

### 1. Prohibido Abreviar
Bajo ninguna circunstancia uses comentarios como:
- `// ... rest of the code`
- `// ... implementation here`
- `// same as above`
- `// imports here`
- `// TODO: implement`

Debes escribir **cada línea de código**, cada import y cada cierre de llave, aunque el archivo sea largo.

### 2. Manejo de Errores Real
Nunca uses:
```dart
// ❌ PROHIBIDO
try {
  await someOperation();
} catch (e) {
  print(e);
}
```

El código de producción requiere manejo de errores real:
```dart
// ✅ CORRECTO
try {
  await someOperation();
} on NetworkException catch (e) {
  state = state.copyWith(
    error: 'Error de conexión: ${e.message}',
    isLoading: false,
  );
  // Mostrar SnackBar o AlertDialog en la UI
} on ValidationException catch (e) {
  state = state.copyWith(
    validationErrors: e.errors,
    isLoading: false,
  );
} catch (e, stackTrace) {
  // Log para debugging en producción
  logger.error('Unexpected error', error: e, stackTrace: stackTrace);
  state = state.copyWith(
    error: 'Ha ocurrido un error inesperado',
    isLoading: false,
  );
}
```

### 3. Sin "Magic Strings" ni "Magic Numbers"
No hardcodees valores importantes. Extráelos a constantes o variables de configuración.

```dart
// ❌ PROHIBIDO
if (password.length < 8) { ... }
final color = Color(0xFF1877F2);

// ✅ CORRECTO
const int kMinPasswordLength = 8;
if (password.length < kMinPasswordLength) { ... }

// En el theme o constantes:
static const Color brandPrimary = Color(0xFF1877F2);
```

### 4. Estados de UI Completos
Al crear una vista, nunca asumas solo el "Happy Path". Debes implementar obligatoriamente:

| Estado | Requerido | Descripción |
|--------|-----------|-------------|
| **Loading** | ✅ SÍ | Spinner, shimmer, o skeleton mientras carga |
| **Error** | ✅ SÍ | Mensaje claro + botón de reintentar |
| **Empty** | ✅ SÍ | Ilustración + mensaje cuando no hay datos |
| **Success** | ✅ SÍ | El contenido normal |

```dart
// Patrón obligatorio para AsyncValue
return asyncData.when(
  loading: () => const LoadingIndicator(),
  error: (error, stack) => ErrorView(
    message: error.toString(),
    onRetry: () => ref.invalidate(dataProvider),
  ),
  data: (data) => data.isEmpty
    ? const EmptyStateView(message: 'No hay elementos')
    : DataListView(items: data),
);
```

## Protocolo de "No Asunción"

Si la instrucción del usuario es ambigua, **NO ASUMAS** la solución más fácil.

| Situación | ❌ Incorrecto | ✅ Correcto |
|-----------|--------------|-------------|
| Validación de email no especificada | Validación simple de `@` | Regex estándar: `r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'` |
| Formato de fecha no especificado | `toString()` | `DateFormat('dd/MM/yyyy', 'es').format(date)` |
| Manejo de null no especificado | Ignorar con `?.` | Validar y mostrar estado apropiado |

## Instrucciones Específicas para Flutter

### 1. Modelos de Datos Completos
Si usas datos, define la clase/modelo completa. No uses `Map<String, dynamic>` sueltos en la UI.

```dart
// ✅ Modelo completo requerido
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
    @Default(false) bool isVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

O sin freezed (manual completo):
```dart
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, avatarUrl, isVerified);
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
```

### 2. Tipado Estricto
Prohibido el uso de `var` o `dynamic` si el tipo es conocible.

```dart
// ❌ PROHIBIDO
var items = [];
dynamic response = await api.fetch();

// ✅ CORRECTO
List<Item> items = [];
ApiResponse<User> response = await api.fetch();
```

### 3. Limpieza de Debug
Elimina cualquier `print()` de depuración antes de entregar el código.

```dart
// ❌ PROHIBIDO en producción
print('Debug: $value');
debugPrint('Response: $response');

// ✅ CORRECTO - Usar logger configurado
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('Debug info'); // Solo en debug builds
logger.e('Error crítico', error: e, stackTrace: stack);
```

## Comportamiento ante Ambigüedad

Si te falta una pieza clave de información (ej. endpoint de API, colores de marca), **no inventes un valor**.

1. Define una constante clara marcando que necesita configuración:
```dart
/// TODO(config): Configurar endpoint real antes de producción
const String kApiBaseUrl = 'CONFIGURE_ME';

/// TODO(design): Confirmar colores de marca con diseño
const Color kBrandPrimary = Color(0xFF000000); // Placeholder
```

2. Si es crítico, pregunta al usuario antes de continuar.

## Checklist Pre-Entrega

Antes de entregar cualquier código, verifica:

- [ ] ¿Todos los imports están escritos explícitamente?
- [ ] ¿No hay comentarios tipo `// ...` o `// TODO: implement`?
- [ ] ¿Cada `try/catch` tiene manejo de error real?
- [ ] ¿Los estados Loading, Error, y Empty están implementados?
- [ ] ¿No hay `print()` de debug?
- [ ] ¿Todos los tipos están explícitos (sin `var`/`dynamic`)?
- [ ] ¿Los modelos tienen `fromJson`, `toJson`, `copyWith`?
- [ ] ¿Los valores configurables están en constantes?

## Consecuencia de Violación

Si el código entregado contiene:
- Comentarios abreviadores (`// ...`)
- `print()` de debug
- Tipos `dynamic` innecesarios
- Solo el "Happy Path" sin estados de error

**El código se considera RECHAZADO y debe ser reescrito completamente.**
