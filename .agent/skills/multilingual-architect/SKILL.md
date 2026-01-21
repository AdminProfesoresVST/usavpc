---
name: multilingual-architect
description: Arquitecto de internacionalización. Implementa el cambio dinámico de idioma con Riverpod y fuerza la generación simultánea de archivos ARB (Inglés/Español) para cada nuevo texto.
---

# Multilingual Architect Skill

## Filosofía: "Bilingüe desde el Nacimiento"

Una app nunca "se traduce después". **Nace traducida.** Cada vez que agregues un texto a la UI, debes definir su existencia simultánea en Inglés (`en`) y Español (`es`) como mínimo.

> [!IMPORTANT]
> **ESTRICTAMENTE PROHIBIDO** entregar código UI con una nueva clave 
> `context.l10n.nuevaClave` sin entregar inmediatamente el bloque JSON/ARB 
> para `app_en.arb` y `app_es.arb`.

## Reglas de Implementación (The Engine)

### 1. Motor de Cambio (Riverpod)

Implementar un `StateNotifierProvider` que maneje el idioma actual y persista la preferencia:

```dart
// lib/core/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider del locale actual de la aplicación
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Notifier que maneja el cambio de idioma con persistencia
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(const Locale('es')) {
    _loadSavedLocale();
  }

  /// Carga el idioma guardado en preferencias
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      state = Locale(languageCode);
    }
  }

  /// Cambia el idioma y lo persiste
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Alterna entre inglés y español
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' 
        ? const Locale('es') 
        : const Locale('en');
    await setLocale(newLocale);
  }

  /// Lista de idiomas soportados
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Español
  ];
}
```

### 2. Configuración en MaterialApp

El `MaterialApp` debe escuchar el provider:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      // Idioma actual reactivo
      locale: locale,
      
      // Idiomas soportados
      supportedLocales: LocaleNotifier.supportedLocales,
      
      // Delegados de localización
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Resolver locale
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return locale;
          }
        }
        return supportedLocales.first;
      },
      
      home: const HomeScreen(),
    );
  }
}
```

### 3. Widget Selector de Idioma

Siempre que diseñes una pantalla de "Ajustes" o "Perfil", incluye proactivamente:

```dart
// lib/core/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.languageSettingTitle),
      subtitle: Text(_getLanguageName(currentLocale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguageTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              locale: const Locale('en'),
              name: 'English',
              flag: '🇺🇸',
            ),
            _LanguageOption(
              locale: const Locale('es'),
              name: 'Español',
              flag: '🇪🇸',
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  const _LanguageOption({
    required this.locale,
    required this.name,
    required this.flag,
  });
  
  final Locale locale;
  final String name;
  final String flag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isSelected = currentLocale.languageCode == locale.languageCode;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected 
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }
}
```

## Estructura de Archivos Requerida

```
lib/
├── l10n/
│   ├── arb/
│   │   ├── app_en.arb    ← Fuente de verdad (Inglés)
│   │   └── app_es.arb    ← Español
│   └── l10n.dart         ← Configuración opcional
├── core/
│   ├── providers/
│   │   └── locale_provider.dart
│   └── widgets/
│       └── language_selector.dart
└── main.dart
```

**Archivo `l10n.yaml` en raíz:**
```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

## Nomenclatura Semántica de Claves

Las claves en el ARB deben describir **qué es**, no **qué dice**:

| ❌ Incorrecto | ✅ Correcto | Razón |
|--------------|-------------|-------|
| `helloWorld` | `onboardingWelcomeTitle` | Describe la ubicación y propósito |
| `blueButton` | `saveAction` | Describe la acción, no el estilo |
| `text1` | `profileBioLabel` | Descriptivo y ubicable |
| `error` | `networkTimeoutError` | Específico al tipo de error |

### Convenciones de Nombres

```
<screen/feature><element><type>

Ejemplos:
- loginEmailLabel        (pantalla + campo + tipo)
- profileSaveAction      (pantalla + acción)
- checkoutTotalPrice     (pantalla + dato)
- commonCancelButton     (genérico + elemento)
- errorNetworkTimeout    (categoría + específico)
```

## Regla de la "Doble Entrada" (ARB)

Cada vez que crees UI con texto, la entrega tiene **3 partes obligatorias**:

### Parte 1: Código Dart (UI)

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: l10n.loginEmailLabel,
              hintText: l10n.loginEmailHint,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.loginPasswordLabel,
            ),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text(l10n.loginSubmitAction),
          ),
        ],
      ),
    );
  }
}
```

### Parte 2: Addendum ARB (Inglés)

```json
// lib/l10n/arb/app_en.arb
{
  "loginTitle": "Welcome Back",
  "@loginTitle": {
    "description": "Title of the login screen"
  },
  "loginEmailLabel": "Email Address",
  "@loginEmailLabel": {
    "description": "Label for email input on login"
  },
  "loginEmailHint": "Enter your email",
  "@loginEmailHint": {
    "description": "Hint text for email input on login"
  },
  "loginPasswordLabel": "Password",
  "@loginPasswordLabel": {
    "description": "Label for password input on login"
  },
  "loginSubmitAction": "Sign In",
  "@loginSubmitAction": {
    "description": "Submit button text on login form"
  }
}
```

### Parte 3: Addendum ARB (Español)

```json
// lib/l10n/arb/app_es.arb
{
  "loginTitle": "Bienvenido de nuevo",
  "loginEmailLabel": "Correo Electrónico",
  "loginEmailHint": "Ingresa tu correo",
  "loginPasswordLabel": "Contraseña",
  "loginSubmitAction": "Iniciar Sesión"
}
```

## Extensión de Contexto (Opcional pero Recomendado)

Para sintaxis más limpia:

```dart
// lib/core/extensions/build_context_extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  /// Acceso rápido a localizaciones
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  /// Locale actual
  Locale get locale => Localizations.localeOf(this);
}

// Uso:
Text(context.l10n.loginTitle)  // En lugar de AppLocalizations.of(context)!.loginTitle
```

## Checklist del Multilingual Architect

Antes de entregar código con UI:

- [ ] ¿Cada texto visible usa `context.l10n.key`?
- [ ] ¿Se incluye el bloque JSON para `app_en.arb`?
- [ ] ¿Se incluye el bloque JSON para `app_es.arb`?
- [ ] ¿Las claves son semánticas (describen qué, no contenido)?
- [ ] ¿Se incluyen descripciones `@key` en el ARB inglés?
- [ ] ¿Existe el `LanguageSelector` en pantalla de ajustes?
- [ ] ¿El `localeProvider` está configurado en MaterialApp?

## Consecuencia de Violación

Si el código contiene:
- Texto en UI sin clave de localización
- Nueva clave sin su entrada en AMBOS archivos ARB
- Claves no semánticas (`text1`, `button`, `error`)

**El código se considera INCOMPLETO y debe ser complementado con las traducciones faltantes.**
