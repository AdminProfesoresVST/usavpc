---
name: global-scale-master
description: Garantiza que la app esté lista para distribución global mediante i18n estricto y accesibilidad universal.
---

# Global Scale Master Skill

## Filosofía: "El Código es Universal, el Contenido es Local"

Para ser una app de clase mundial, el código fuente no puede contener ni una sola palabra en un idioma humano específico. Todo texto visible debe ser una referencia abstracta.

## Reglas de "Zero Hardcoded Strings"

### 1. Prohibido Textos Literales

```dart
// ❌ PROHIBIDO - Texto hardcodeado
Text("Bienvenido a la app")
Text("Welcome to the app")
ElevatedButton(child: Text("Submit"))

// ✅ CORRECTO - Referencia a localización
Text(AppLocalizations.of(context)!.welcomeMessage)
Text(context.l10n.welcomeMessage)
ElevatedButton(child: Text(context.l10n.submitButton))
```

### 2. Generación de Archivos ARB Obligatoria

Cuando generes una nueva pantalla con textos nuevos, **DEBES** proveer también el bloque JSON/ARB correspondiente.

**Ejemplo de entrega completa:**

```dart
// lib/features/auth/presentation/screens/login_screen.dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.loginTitle)),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.emailLabel,
              hintText: context.l10n.emailHint,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.passwordLabel,
            ),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(context.l10n.loginButton),
          ),
          TextButton(
            onPressed: () {},
            child: Text(context.l10n.forgotPasswordLink),
          ),
        ],
      ),
    );
  }
}
```

**Archivo ARB correspondiente (OBLIGATORIO):**

```json
// lib/l10n/app_en.arb
{
  "loginTitle": "Sign In",
  "@loginTitle": {
    "description": "Title of the login screen"
  },
  "emailLabel": "Email Address",
  "@emailLabel": {
    "description": "Label for email input field"
  },
  "emailHint": "Enter your email",
  "@emailHint": {
    "description": "Hint text for email input"
  },
  "passwordLabel": "Password",
  "@passwordLabel": {
    "description": "Label for password input field"
  },
  "loginButton": "Sign In",
  "@loginButton": {
    "description": "Text on login submit button"
  },
  "forgotPasswordLink": "Forgot your password?",
  "@forgotPasswordLink": {
    "description": "Link text for password recovery"
  }
}
```

```json
// lib/l10n/app_es.arb
{
  "loginTitle": "Iniciar Sesión",
  "emailLabel": "Correo Electrónico",
  "emailHint": "Ingresa tu correo",
  "passwordLabel": "Contraseña",
  "loginButton": "Iniciar Sesión",
  "forgotPasswordLink": "¿Olvidaste tu contraseña?"
}
```

### 3. Claves Semánticas

Usa claves descriptivas del propósito, no del contenido:

| ❌ Clave Incorrecta | ✅ Clave Correcta |
|--------------------|-------------------|
| `welcomeText` | `homeGreeting` |
| `cancelButtonText` | `cancelAction` |
| `errorMessage` | `networkErrorMessage` |
| `submitButtonLabel` | `formSubmitAction` |

### 4. Formatos Regionales (Intl)

Nunca asumas formatos de fecha, moneda o números:

```dart
// ❌ PROHIBIDO - Asume formato específico
Text("\$${price}")
Text("${date.day}/${date.month}/${date.year}")
Text("${number.toStringAsFixed(2)}")

// ✅ CORRECTO - Usa Intl para regionalización
import 'package:intl/intl.dart';

// Moneda
Text(NumberFormat.currency(
  locale: Localizations.localeOf(context).toString(),
  symbol: '', // O deja que lo determine el locale
).format(price))

// Fecha
Text(DateFormat.yMMMd(
  Localizations.localeOf(context).toString(),
).format(date))

// Números
Text(NumberFormat.decimalPattern(
  Localizations.localeOf(context).toString(),
).format(number))
```

## Accesibilidad (A11y) - El Estándar Mundial

Las apps globales deben ser usables por personas con discapacidad.

### 1. Semantics para Widgets Complejos

Envuelve widgets interactivos complejos en `Semantics()`:

```dart
// Para widgets custom que no son botones estándar
Semantics(
  button: true,
  label: context.l10n.playVideoButton,
  hint: context.l10n.playVideoHint,
  child: GestureDetector(
    onTap: _playVideo,
    child: CustomPlayIcon(),
  ),
)

// Para imágenes informativas
Semantics(
  image: true,
  label: context.l10n.userAvatarDescription,
  child: CircleAvatar(
    backgroundImage: NetworkImage(user.avatarUrl),
  ),
)
```

### 2. Escalado de Texto

Nunca uses tamaños fijos que impidan el escalado. Verifica que el layout no se rompa con fuente al 200%:

```dart
// ❌ PROHIBIDO - Tamaño fijo que puede romperse
SizedBox(
  height: 48,
  child: Text('Label', style: TextStyle(fontSize: 14)),
)

// ✅ CORRECTO - Flexible y escalable
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 48),
  child: Text(
    context.l10n.label,
    style: Theme.of(context).textTheme.bodyMedium,
  ),
)
```

### 3. Contraste WCAG AA

Asegura que los colores cumplan ratio de contraste mínimo:

| Tipo de Texto | Ratio Mínimo |
|---------------|--------------|
| Texto normal | 4.5:1 |
| Texto grande (18sp+) | 3:1 |
| Iconos/gráficos | 3:1 |

```dart
// Verificar en ThemeData
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    // Verificar contraste automáticamente
    brightness: Brightness.light,
  ),
  // ...
)
```

### 4. Focus y Navegación por Teclado

```dart
// Asegurar orden de foco lógico
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: const NumericFocusOrder(1),
        child: TextField(/* email */),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(2),
        child: TextField(/* password */),
      ),
      FocusTraversalOrder(
        order: const NumericFocusOrder(3),
        child: ElevatedButton(/* submit */),
      ),
    ],
  ),
)
```

## Manejo de RTL (Right-to-Left)

Escribe el código pensando que puede ser usado en árabe o hebreo.

### Padding y Margin Direccionales

```dart
// ❌ PROHIBIDO - Asume LTR
Padding(padding: EdgeInsets.only(left: 16, right: 8))
Container(margin: EdgeInsets.only(left: 10))

// ✅ CORRECTO - Direccional
Padding(padding: EdgeInsetsDirectional.only(start: 16, end: 8))
Container(margin: EdgeInsetsDirectional.only(start: 10))
```

### Alignment Direccional

```dart
// ❌ PROHIBIDO
Align(alignment: Alignment.centerLeft)
Row(mainAxisAlignment: MainAxisAlignment.start) // OK pero cuidado con hijos

// ✅ CORRECTO
Align(alignment: AlignmentDirectional.centerStart)
// Los iconos de flecha deben cambiar dirección
Icon(Directionality.of(context) == TextDirection.rtl 
  ? Icons.arrow_back 
  : Icons.arrow_forward)
```

### Positioned Direccional

```dart
// ❌ PROHIBIDO
Positioned(left: 10, child: widget)

// ✅ CORRECTO
PositionedDirectional(start: 10, child: widget)
```

## Flujo de Trabajo del Agente

**Solicitud del usuario:** *"Crea un botón que diga Cancelar"*

**Tu respuesta debe incluir:**

### 1. Definición en ARB (Español e Inglés)

```json
// lib/l10n/app_en.arb
{
  "cancelAction": "Cancel",
  "@cancelAction": {
    "description": "Generic cancel button text"
  }
}

// lib/l10n/app_es.arb
{
  "cancelAction": "Cancelar"
}
```

### 2. Implementación del Widget

```dart
ElevatedButton(
  onPressed: () => Navigator.of(context).pop(),
  child: Text(context.l10n.cancelAction),
)
```

## Configuración Requerida

Asegurar que `pubspec.yaml` tenga:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

Y `l10n.yaml` en la raíz:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

## Checklist de Globalización

Antes de entregar código con UI:

- [ ] ¿Todo texto visible usa `context.l10n.key`?
- [ ] ¿Se proporcionan los archivos ARB con las claves nuevas?
- [ ] ¿Las claves son semánticas (describen propósito, no contenido)?
- [ ] ¿Los formatos de fecha/moneda usan `Intl`?
- [ ] ¿Los paddings usan `EdgeInsetsDirectional`?
- [ ] ¿Los alignments usan `AlignmentDirectional`?
- [ ] ¿Los widgets complejos tienen `Semantics`?
- [ ] ¿El layout soporta texto escalado al 200%?

## Consecuencia de Violación

Si el código contiene:
- Strings literales en widgets (`Text("Hello")`)
- Formatos de fecha/moneda hardcodeados
- `EdgeInsets.only(left:)` en lugar de direccional
- Falta de archivos ARB para nuevas claves

**El código se considera NO GLOBALIZABLE y debe ser reescrito.**
