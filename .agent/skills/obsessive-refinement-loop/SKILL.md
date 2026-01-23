---
name: obsessive-refinement-loop
description: Motor de autocrítica y perfeccionamiento. Ejecuta un bucle de revisión interna antes de responder para asegurar: 1. Lógica sólida, 2. Arquitectura correcta, 3. Interactividad funcional al 100% (cero enlaces rotos).
---

# Obsessive Refinement Loop Skill (Merged)

## Filosofía: "El primer borrador es basura, el código final es arte"
Nunca entregues la primera versión que generes. Tu trabajo es iterar internamente, criticar tu propio código y corregirlo antes de que el usuario lo vea.

## El Protocolo "Quadruple Check" (4 Filtros Obligatorios)
Antes de emitir cualquier respuesta, pasa el código por estos 4 filtros. Si falla alguno, vuelve a generar el código.

### 🔄 Filtro 1: Funcionalidad y Lógica (Logic Gate)
- ¿El código compila?
- ¿Están todos los imports?
- ¿Cerraste todas las llaves `}`?

### 🛡️ Filtro 2: Arquitectura y Estándares (Compliance Gate)
- **Supabase:** ¿Usaste `.withConverter` y RLS? (Ver `supabase-backend-master`)
- **i18n:** ¿Extrajiste los textos a ARB? (Ver `multilingual-architect`)
- **Riverpod:** ¿Estás usando `ConsumerWidget` y `ref.watch` correctamente?

### 🖱️ Filtro 3: Fidelidad Interactiva (Interaction Fidelity Gate)
**Aquí es donde mueren los errores de UX:**
- **Cero Dead-Links:** ¿Hay algún `onPressed: () {}` vacío? -> **PROHIBIDO.**
- **Navegación Real:** Si hay un botón "Ir al Perfil", ¿existe la ruta y la pantalla de destino? Si no, **créalas**.
- **Feedback Visual:** ¿Cada acción tiene un `CircularProgressIndicator`, `SnackBar` o transición?
- **Regla de Oro:** Si el elemento se ve y se puede tocar, **tiene que hacer lo que dice que hace**.

### 🧪 Filtro 4: Casos Borde (Nightmare Gate)
- ¿Qué pasa si la lista viene vacía de Supabase? -> Agrega `EmptyStateWidget`.
- ¿Qué pasa si no hay internet? -> Maneja el error en el Repo.

## Regla de Recursividad (No "TODOs")
Si para pasar el **Filtro 3** necesitas crear un nuevo archivo (ej. `settings_screen.dart` para que el botón de ajustes funcione), **HAZLO**.
No dejes comentarios como `// TODO: Implementar pantalla`. Implementa la pantalla, aunque sea básica.

## Salida Visible (Sello de Calidad)
Al final de tu respuesta, firma con el reporte de tu auto-revisión:

> **🔍 REFINAMIENTO & QA**
> - **Iteraciones:** 3
> - **Interacciones:** Se verificaron 4 botones; se creó la pantalla `ProfileScreen` para evitar un enlace roto.
> - **Estado:** ✅ 100% Funcional y Testeable.

## Comportamiento de Pausa
Si detectas que cumplir con el Filtro 3 requiere demasiado código, advierte:
*"Para que el botón 'Ver Historial' funcione al 100%, necesito crear la tabla de historial y su vista. Procedo a generar todo el stack..."*
