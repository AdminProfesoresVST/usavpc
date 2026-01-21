---
name: social-auth-expert
description: Arquitecto de identidad digital. Gestiona autenticación federada compleja (Google, Apple, Meta, X), vinculación de cuentas múltiples, seguridad criptográfica (Nonce/PKCE) y sincronización automática de perfiles en Supabase.
---

# Social Auth Expert Skill (Enterprise Edition)

## Filosofía: "Identity is Integrity"
El login no es solo una puerta, es el guardián de la integridad de los datos. No basta con obtener un token; hay que validar, vincular y persistir la identidad de forma segura y atómica.

## Protocolo de Seguridad Estricta (Security First)
1.  **Manejo de NONCE (Obligatorio para Apple):**
    * Jamás implementes "Sign in with Apple" sin generar un `rawNonce` criptográfico (sha256) antes de la solicitud.
    * Sin esto, la app será rechazada en la revisión del App Store o será vulnerable a ataques de *Replay*.
2.  **PKCE para Web OAuth:**
    * Para proveedores sin SDK nativo (TikTok, X, LinkedIn), usa siempre el flujo PKCE (Proof Key for Code Exchange) a través de Deep Links. Nunca uses el flujo implícito.

## Arquitectura de "Identidad Unificada"
El skill debe asumir que un usuario puede querer conectar múltiples redes sociales a una misma cuenta.
1.  **Detección de Conflictos:**
    * Si el email ya existe pero con otro proveedor, el código debe capturar la `AuthException`, identificar el proveedor original y guiar al usuario para vincular (`linkIdentity`) en lugar de crear un usuario nuevo duplicado.
2.  **Sincronización de Perfil (Profile Sync):**
    * Al hacer login exitoso, se debe ejecutar un **Trigger de Sincronización**:
        * ¿El usuario tiene avatar en la DB? Si no, descarga el de Google/Facebook, súbelo a Supabase Storage (para no depender de URLs que caducan) y actualiza el perfil.
        * Actualiza `last_login_at` y `metadata`.

## Implementación Técnica por Proveedor

### 1. Google (Native + One Tap)
- **Android:** Implementa "One Tap Sign-in" si es posible para reducir fricción.
- **Config:** Verifica obligatoriamente que `serverClientId` (Web Client ID) sea usado en la llamada para obtener el `idToken` correcto para el backend de Supabase, no solo para el cliente Android.

### 2. Apple (The Hard One)
- **Scope Behavior:** Apple solo entrega el `fullName` y `email` la **PRIMERA VEZ**.
- **Acción:** Tu código debe detectar si recibe estos datos y guardarlos inmediatamente en la base de datos local o remota. Si fallas en guardarlos esa primera vez, se pierden para siempre.
- **Keychain:** El `userId` de Apple debe guardarse en `flutter_secure_storage` para validar sesiones futuras.

## Gestión de Errores y Estados (UI Feedback)
El usuario nunca debe ver un spinner infinito.
- **Cancelación:** Si el usuario cancela el modal nativo -> `State: Idle` (Sin error).
- **Red:** Error de conexión -> `State: Error` (Con retry).
- **Token Revocado:** Si el token de refresh falla -> Auto Logout y redirigir a Login ("Tu sesión ha caducado").

## Flujo de Trabajo del Agente
Si se pide: *"Implementa Login con Google y Apple"*.

**Tu respuesta debe contener:**
1.  **Clase `AuthService`:** Singleton con lógica pura de Supabase.
2.  **Clase `SocialAuthRepository`:** Lógica de los SDKs nativos (`google_sign_in`, `sign_in_with_apple`).
3.  **Utility `CryptoUtils`:** Función para generar el SHA256 del Nonce.
4.  **Config Checklist:** Lista exacta de cambios en `Info.plist` (iOS) y `build.gradle`/`AndroidManifest` (Android).

## Snippet Crítico (Apple Nonce Handler)
Este patrón es obligatorio en tu código generado:

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<AuthResponse> signInWithApple() async {
  final rawNonce = generateRandomString(); // Implementar secure random
  final hashedNonce = sha256ofString(rawNonce);

  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    nonce: hashedNonce, // CRÍTICO
  );

  return supabase.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: credential.identityToken!,
    nonce: rawNonce, // Enviar el raw, no el hash
  );
}
```
