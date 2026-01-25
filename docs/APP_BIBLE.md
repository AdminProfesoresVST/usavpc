# APP BIBLE: US Visa Processing Center 🇺🇸

> **Última Actualización:** 2026-01-24
> **Estado:** En Desarrollo Activo (Phase 10)

## 1. Visión & Negocio
**Propósito:** Simplificar y democratizar el proceso de solicitud de visas americanas (DS-160/DS-260) mediante IA avanzada y automatización.
**Usuario Objetivo:** Solicitantes latinos (énfasis en soporte ES/EN) que necesitan guía experta y sin errores.
**Goal Final:** Que el usuario complete su DS-160/DS-260 sin tocar el formulario oficial hasta la exportación final.

## 2. Arquitectura Técnica
*   **Frontend:** Flutter (Mobile).
*   **State Management:** Riverpod 3.x (NotifierProvider pattern - NO StateProvider).
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

### 📋 Visa Service (NEW 2026-01-24)
*   **Category Selector (`/visa/select`)**: Selección de tipo de visa DS-160 o DS-260.
    *   *Features:* Tabs Non-Immigrant/Immigrant, agrupación por tarifa, badges (SEVIS, Petition).
*   **Prerequisite Checker (`/visa/prerequisites`)**: Checklist de documentos prerrequisito.
    *   *Validación:* Progreso por documento, extracción de datos críticos (SEVIS ID, etc.).
*   **Restriction Check (`/travel-ban/check`)**: Verificación de restricciones por nacionalidad.
    *   *Niveles:* Total Ban, Partial Restriction, Immigrant Pause.
*   **Cost Calculator (`/cost/calculate`)**: Calculadora de tarifas completa.
    *   *Breakdown:* MRV ($185-$315), Integrity Fee ($250), SEVIS ($220-$350), I-94 Land ($24), Reciprocity.

## 4. Diccionario de Datos

### Tabla: `applications`
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | PK |
| `user_id` | UUID | FK -> `auth.users` |
| `form_data` | JSONB | Almacén principal de respuestas DS-160/DS-260 |
| `status` | Text | Estado (`ocr_complete`, `in_progress`, etc.) |

### Tabla: `visa_categories` (NEW)
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `id` | UUID | PK |
| `code` | Text | Código de visa (B1, F1, H1B, IR1, etc.) |
| `name` | Text | Nombre descriptivo |
| `type` | Enum | `immigrant`, `non_immigrant` |
| `form_engine` | Enum | `DS-160`, `DS-260` |
| `base_fee_usd` | Integer | Tarifa MRV ($185-$315) |
| `requires_sevis` | Boolean | Requiere pago SEVIS (F, M, J) |
| `requires_petition` | Boolean | Requiere petición aprobada (H, L, O, P) |

### Tabla: `country_restrictions` (NEW)
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `country_code` | Text | ISO 3166-1 alpha-2 |
| `restriction_level` | Enum | `total_ban`, `partial_restriction`, `immigrant_pause`, `none` |
| `restricted_categories` | Text[] | Categorías restringidas si `partial` |
| `effective_date` | Date | Fecha efectiva de restricción |

### Tabla: `visa_fees` (NEW)
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `fee_type` | Enum | `mrv_base`, `integrity_fee`, `sevis_i901`, `i94_land`, `reciprocity` |
| `amount_usd` | Integer | Monto en dólares |
| `visa_category_code` | Text | Aplica a categoría específica (nullable) |
| `country_code` | Text | Para reciprocidad (nullable) |
| `is_refundable` | Boolean | Integrity Fee puede ser reembolsable |

### Tabla: `inadmissibility_flags` (NEW)
| Columna | Tipo | Descripción |
| :--- | :--- | :--- |
| `flag_type` | Enum | `unlawful_presence`, `visa_overstay`, `criminal_record`, `public_charge` |
| `severity` | Enum | `critical`, `high`, `medium`, `low` |
| `suggested_waiver` | Text | I-601, I-212, etc. |
| `detected_from_field` | Text | Campo del formulario que activó alerta |

## 5. Reglas de Negocio
1.  **Integridad de Datos:** No se puede iniciar el chat sin haber pasado por Confirmación de Pasaporte (OCR).
2.  **Cero Fallbacks:** Si un dato crítico falta, la app debe detener el flujo y pedirlo, nunca inventarlo.
3.  **Persistencia Atómica:** Cada respuesta del chat que contenga datos debe guardarse inmediatamente en Supabase.
4.  **Travel Ban Logic (NEW):** 
    - Total Ban: Bloquea TODAS las visas para esa nacionalidad.
    - Immigrant Pause: Bloquea solo DS-260 (inmigrante).
    - Partial: Bloquea categorías específicas listadas en `restricted_categories`.
5.  **Cost Calculation (NEW):**
    - Base MRV + Integrity Fee ($250) + SEVIS (si aplica) + I-94 (si cruza por tierra) + Reciprocidad (por país).
6.  **Inadmissibility Detection (NEW):**
    - Analiza campos del formulario buscando patrones de riesgo.
    - Sugiere waivers apropiados (I-601, I-212, etc.).

## 6. Design System & Typography (EL DOCUMENTO RECTOR)
**Regla de Oro:** La consistencia visual es obligatoria. No se permiten "Hardcoded Styles".

### 🎨 Paleta de Colores "Navy First"
*   **Primary:** `Navy (#112E51)` (Único color principal. Prohibido el azul estándar).
*   **Accent:** `Gold (#D4AF37)` (Solo para bordes premium y detalles finos).
*   **Background:** `White (#FFFFFF)` o `Grey (#F9FAFB)`.
*   **Error:** `Mature Red (#D32F2F)` (Nunca rojo brillante).
*   **Warning:** `Orange (#F57C00)` (Para restricciones parciales).
*   **Success:** `Green (#388E3C)` (Para validaciones completadas).

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

## 7. Feature Structure (NEW)

### Feature Folder Pattern
Cada feature sigue la estructura Clean Architecture:
```
features/
└── [feature_name]/
    ├── [feature_name].dart           # Barrel export
    ├── data/
    │   ├── models/                   # Data classes con fromJson/toJson
    │   └── repositories/             # Supabase implementations
    └── presentation/
        ├── providers/                # Riverpod NotifierProviders
        ├── screens/                  # Full page widgets
        └── widgets/                  # Reusable UI components
```

### Current Features
| Feature | Barrel Export | Purpose |
| :--- | :--- | :--- |
| `visa` | `visa.dart` | Categorías, prerrequisitos, selección DS-160/DS-260 |
| `travel_ban` | `travel_ban.dart` | Verificación de restricciones por nacionalidad |
| `cost_calculator` | `cost_calculator.dart` | Cálculo de tarifas con breakdown |
| `inadmissibility` | `inadmissibility.dart` | Detección de alertas y waivers |
| `social_audit` | `social_audit.dart` | Auditoría de perfiles sociales vs DS-160 |

