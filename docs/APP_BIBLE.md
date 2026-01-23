# APP BIBLE: US Visa Processing Center 🇺🇸

> **Última Actualización:** 2026-01-21
> **Estado:** En Desarrollo Activo (Phase 9)

## 1. Visión & Negocio
**Propósito:** Simplificar y democratizar el proceso de solicitud de visas americanas (DS-160) mediante IA avanzada y automatización.
**Usuario Objetivo:** Solicitantes latinos (énfasis en soporte ES/EN) que necesitan guía experta y sin errores.
**Goal Final:** Que el usuario complete su DS-160 sin tocar el formulario oficial hasta la exportación final.

## 2. Arquitectura Técnica
*   **Frontend:** Flutter (Mobile).
*   **State Management:** Riverpod (Providers, StateNotifiers).
*   **Backend:** Supabase (Auth, Postgres DB, Edge Functions).
*   **AI:** Integración via `AiRepository`.
*   **Filosofía:** "Zero Tolerance" (Sin fallbacks, Fail Fast, Asserts en Modelos).
*   **Infraestructura:**
    *   **Supabase Project ID:** `inaxjdmofqbcoljxgnwr` (Production & Dev).
    *   **Hosting:** Netlify / App Distribution.

## 3. Mapa de la App (Sitemap)

### 🔐 Auth
*   **Login (`/login`)**: Entrada principal. Requiere email/pass.
    *   *Conexión:* -> `/dashboard` (Éxito).

### 🏠 Dashboard
*   **Dashboard (`/dashboard`)**: Vista general de solicitudes.
    *   *Estado:* Carga solicitudes de `applications` table.

### 🆔 KYC / OCR (Flujo Crítico)
*   **Landing (`/identity/start`)**: Selección de método (Cámara vs Galería).
    *   *Regla:* Navega a `/identity/capture` (Cámara) o gestiona Galería localmente.
*   **Scanner (`/identity/capture`)**: Cámara en vivo con MLKit.
    *   *Validación:* Zero Tolerance. Si no hay `documentNumber` + `lastName`, no avanza.
*   **Confirmación (`/kyc/confirm`)**: **PANTALLA OBLIGATORIA**.
    *   *Propósito:* Usuario verifica/corrige datos OCR.
    *   *Data:* Recibe parámetros por URL (Query Params).
    *   *Conexión:* -> `/kyc/chat` solo al guardar.

### 🤖 Chat Intake
*   **Chat (`/kyc/chat`)**: Entrevista IA tipo "Consultor Experto".
    *   *Contexto:* Se inyecta `System Prompt` invisible con datos verificados.
    *   *Persistencia:* Extrae JSON `[[UPDATE: {...}]]` para guardar en DB.

## 4. Diccionario de Datos

### Tabla: `applications`
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | PK |
| `user_id` | UUID | FK -> `auth.users` |
| `form_data` | JSONB | Almacén principal de respuestas DS-160 |
| `status` | Text | Estado (`ocr_complete`, `in_progress`, etc.) |

## 5. Reglas de Negocio
1.  **Integridad de Datos:** No se puede iniciar el chat sin haber pasado por Confirmación de Pasaporte (OCR).
2.  **Cero Fallbacks:** Si un dato crítico falta, la app debe detener el flujo y pedirlo, nunca inventarlo.
3.  **Persistencia Atómica:** Cada respuesta del chat que contenga datos debe guardarse inmediatamente en Supabase.

## 6. Design System & Typography (EL DOCUMENTO RECTOR)
**Regla de Oro:** La consistencia visual es obligatoria. No se permiten "Hardcoded Styles".

### 🎨 Paleta de Colores "Navy First"
*   **Primary:** `Navy (#112E51)` (Único color principal. Prohibido el azul estándar).
*   **Accent:** `Gold (#D4AF37)` (Solo para bordes premium y detalles finos).
*   **Background:** `White (#FFFFFF)` o `Grey (#F9FAFB)`.
*   **Error:** `Mature Red (#D32F2F)` (Nunca rojo brillante).

### 📝 Tipografía (Public Sans) - SISTEMA ESTRICTO
**Regla Absoluta:** El tamaño MÁXIMO es **18px** (AppBar). Nada puede ser mayor.

| Nivel | Tamaño | Peso | Uso | Clase CSS Equiv. |
| :--- | :--- | :--- | :--- | :--- |
| **H1 (Max)** | `18px` | Bold | AppBar, Pantallas Principales | `.h1-bold` |
| **H2** | `16px` | Bold | Subtítulos de Sección | `.h2-bold` |
| **H3** | `15px` | SemiBold | Tarjetas Destacadas | `.h3-semibold` |
| **Body** | `14px` | Regular | Texto General | `.body-regular` |
| **Small** | `12px` | Regular | Metadata, Captions | `.small-regular` |

**Variantes de Color Obligatorias:**
Cada nivel debe tener sus versiones predefinidas en `AppTheme`:
*   Navy (`.navy`)
*   White (`.white`)
*   Grey (`.grey`)
*   Error (`.red`)

**Implementación:**
Todo se define estáticamente en `lib/core/theme/app_theme.dart` para funcionar como una hoja de estilos CSS centralizada.
