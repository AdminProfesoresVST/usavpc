---
name: supabase-backend-master
description: Experto en integración de Supabase con Flutter, priorizando seguridad (RLS), tipado fuerte y performance.
---

# Supabase Backend Master Skill

## Filosofía: "Postgres es el Rey, Dart es el Siervo"

Supabase no es solo una base de datos, es un Backend completo. Tu código en Flutter debe reflejar eso respetando la seguridad y la estructura relacional.

## Reglas de Oro (Supabase x Flutter)

### 1. Tipado Estricto (The Converter Rule)

```dart
// ❌ PROHIBIDO - Map crudo en la UI
final response = await supabase.from('users').select();
final users = response as List<Map<String, dynamic>>; // MAL

// ✅ CORRECTO - Conversión tipada en el repositorio
final response = await supabase
    .from('users')
    .select('id, email, name, avatar_url')
    .withConverter<User>((data) => User.fromJson(data));
```

**Obligatorio:** Generar modelos con `fromJson` usando `freezed` o `json_serializable` y mapear los datos *dentro* de la capa de repositorio, nunca en la UI.

### 2. Seguridad & RLS (Row Level Security)

Asume **SIEMPRE** que RLS está activado. La seguridad es responsabilidad de Postgres, no de Dart.

```dart
// ❌ PROHIBIDO - Filtrar en cliente (inseguro)
final myPosts = await supabase
    .from('posts')
    .select()
    .eq('user_id', currentUserId); // NO confíes en esto para seguridad

// ✅ CORRECTO - RLS filtra automáticamente
// La política RLS ya garantiza que solo veas TUS posts
final myPosts = await supabase
    .from('posts')
    .select('id, title, content, created_at');
// Postgres filtra por auth.uid() automáticamente
```

**Si generas código SQL para tablas, DEBES incluir las políticas RLS:**

```sql
-- Crear tabla
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL DEFAULT auth.uid(),
  title TEXT NOT NULL,
  content TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Políticas OBLIGATORIAS
CREATE POLICY "Users can view own posts"
  ON posts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own posts"
  ON posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE
  USING (auth.uid() = user_id);
```

### 3. Performance de Consultas

| Regla | ❌ Prohibido | ✅ Correcto |
|-------|-------------|-------------|
| No `select('*')` | `.select()` o `.select('*')` | `.select('id, name, avatar_url')` |
| Paginación | Traer todo sin límite | `.range(0, 19)` o `.limit(20)` |
| Relaciones | Múltiples queries | `.select('*, cities(*)')` |

```dart
// ❌ PROHIBIDO - Trae TODAS las columnas y filas
final users = await supabase.from('users').select();

// ✅ CORRECTO - Columnas específicas + paginación
final users = await supabase
    .from('users')
    .select('id, name, avatar_url')
    .order('created_at', ascending: false)
    .range(0, 19); // Primeros 20 registros
```

**Joins eficientes con PostgREST:**

```dart
// ✅ Un solo query con relaciones
final postsWithAuthor = await supabase
    .from('posts')
    .select('''
      id,
      title,
      content,
      created_at,
      author:users!user_id (
        id,
        name,
        avatar_url
      )
    ''')
    .order('created_at', ascending: false)
    .limit(10);
```

### 4. Realtime vs Future

| Caso de Uso | Método | Razón |
|-------------|--------|-------|
| Chat en vivo | `.stream()` | Mensajes instantáneos |
| Tracking GPS | `.stream()` | Ubicación en tiempo real |
| Lista de productos | `.get()` (Future) | Datos estáticos, ahorra recursos |
| Perfil de usuario | `.get()` (Future) | Cambia raramente |
| Dashboard | `.get()` + refresh manual | Control del usuario |

```dart
// ✅ Stream solo para tiempo real crítico
final messagesStream = supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('chat_id', chatId)
    .order('created_at');

// ✅ Future para datos normales
Future<List<Product>> getProducts() async {
  final response = await supabase
      .from('products')
      .select('id, name, price, image_url')
      .eq('is_active', true)
      .order('name');
  return (response as List).map((e) => Product.fromJson(e)).toList();
}
```

## Arquitectura con Riverpod

El cliente de Supabase debe ser inyectado, nunca instanciado globalmente en los widgets.

### 1. Provider del Cliente

```dart
// lib/core/providers/supabase_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider del cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider del usuario actual (reactivo)
final currentUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Provider de la sesión actual
final sessionProvider = Provider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentSession;
});
```

### 2. Repository con Inyección

```dart
// lib/features/posts/data/repositories/post_repository_impl.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PostRepositoryImpl(client);
});

class PostRepositoryImpl implements IPostRepository {
  final SupabaseClient _client;
  
  PostRepositoryImpl(this._client);
  
  @override
  Future<List<Post>> getPosts({int page = 0, int limit = 20}) async {
    final start = page * limit;
    final end = start + limit - 1;
    
    final response = await _client
        .from('posts')
        .select('id, title, content, created_at, user:users!user_id(id, name)')
        .order('created_at', ascending: false)
        .range(start, end);
    
    return (response as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }
  
  @override
  Future<Post> createPost(CreatePostDto dto) async {
    final response = await _client
        .from('posts')
        .insert(dto.toJson())
        .select('id, title, content, created_at')
        .single();
    
    return Post.fromJson(response);
  }
  
  @override
  Future<void> deletePost(String id) async {
    await _client
        .from('posts')
        .delete()
        .eq('id', id);
  }
}
```

### 3. Provider de Datos

```dart
// lib/features/posts/presentation/providers/posts_provider.dart
final postsProvider = FutureProvider.autoDispose
    .family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPosts(page: page);
});

// Para realtime
final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, chatId) {
  final client = ref.watch(supabaseClientProvider);
  
  return client
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('chat_id', chatId)
      .order('created_at')
      .map((data) => data.map((e) => Message.fromJson(e)).toList());
});
```

## Manejo de Errores Supabase

```dart
// ✅ Manejo específico de errores
Future<Either<Failure, User>> updateProfile(UpdateProfileDto dto) async {
  try {
    final response = await _client
        .from('profiles')
        .update(dto.toJson())
        .eq('id', dto.userId)
        .select()
        .single();
    
    return Right(User.fromJson(response));
  } on PostgrestException catch (e) {
    // Error de base de datos
    if (e.code == '23505') {
      return Left(DuplicateEmailFailure());
    }
    if (e.code == '42501') {
      return Left(PermissionDeniedFailure());
    }
    return Left(DatabaseFailure(e.message));
  } on AuthException catch (e) {
    // Error de autenticación
    return Left(AuthFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}
```

## Storage (Archivos)

```dart
// ✅ Subir archivo con path seguro
Future<String> uploadAvatar(String userId, File file) async {
  final ext = file.path.split('.').last;
  final path = 'avatars/$userId/avatar.$ext';
  
  await _client.storage
      .from('profiles')
      .upload(
        path,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true, // Reemplazar si existe
        ),
      );
  
  return _client.storage
      .from('profiles')
      .getPublicUrl(path);
}
```

## Edge Functions

```dart
// ✅ Invocar Edge Function
Future<Map<String, dynamic>> processPayment(PaymentDto dto) async {
  final response = await _client.functions.invoke(
    'process-payment',
    body: dto.toJson(),
    headers: {'x-custom-header': 'value'},
  );
  
  if (response.status != 200) {
    throw PaymentException(response.data['error']);
  }
  
  return response.data;
}
```

## Checklist de Integración Supabase

Antes de entregar código con Supabase:

- [ ] ¿Los datos se convierten a modelos tipados (no `Map<String, dynamic>` en UI)?
- [ ] ¿Se especifican columnas explícitas en `select()` (no `*`)?
- [ ] ¿Las listas usan paginación (`.range()` o `.limit()`)?
- [ ] ¿Las tablas nuevas tienen políticas RLS definidas?
- [ ] ¿El cliente se inyecta via Provider (no global)?
- [ ] ¿Los errores se manejan específicamente (`PostgrestException`, `AuthException`)?
- [ ] ¿Se usa `.stream()` solo para datos que requieren tiempo real?
- [ ] ¿Los joins usan la sintaxis de PostgREST (no queries múltiples)?

## Consecuencia de Violación

Si el código contiene:
- `Map<String, dynamic>` pasados a la UI
- `.select('*')` o `.select()` sin columnas específicas
- Listas sin paginación
- Tablas sin políticas RLS
- Filtros de seguridad en cliente en lugar de RLS

**El código se considera INSEGURO/INEFICIENTE y debe ser reescrito.**
