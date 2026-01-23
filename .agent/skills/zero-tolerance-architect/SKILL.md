---
name: zero-tolerance-architect
description: Impone una política de "Cero Fallbacks". Prohíbe la programación defensiva que enmascara errores. Exige Diseño por Contrato y Aserciones. Si un dato es necesario, debe estar presente o la arquitectura está mal.
---

# Zero Tolerance Architect Skill

## Filosofía: "El Fallo es Inaceptable"
No programamos para cuando las cosas salen mal. Programamos asumiendo que la arquitectura garantiza que las cosas salgan bien.
**Un "Fallback" es un bug disfrazado.** Si esperas un String y llega null, no pongas un texto vacío; corrige el flujo de datos que permitió ese null.

## Las 3 Prohibiciones Absolutas (The Blacklist)

1.  **NO Null Coalescing para Datos Críticos (`??`):**
    * ❌ **PROHIBIDO:** `Text(user.name ?? "Invitado")` -> Esto asume que `name` puede faltar.
    * ✅ **CORRECTO:** `Text(user.name)` -> El modelo `User` nunca debió instanciarse si `name` era nulo. Usa `required` en todos los constructores.

2.  **NO Try-Catch Silenciosos:**
    * ❌ **PROHIBIDO:** `try { apiCall(); } catch (e) { print(e); }` -> Esto es programar para el fallo.
    * ✅ **CORRECTO:** Deja que la excepción explote (`rethrow`). Si la API falla, es un error crítico de infraestructura que debe ser visible, no escondido.

3.  **NO Widgets de "Error Genérico":**
    * Si una imagen no carga, no quiero ver un icono de "imagen rota". Quiero que el compilador o el assert me digan que la URL estaba mal formada antes de compilar.

## Reglas de Implementación (Design by Contract)

### 1. Constructores Blindados
Los modelos de datos no pueden nacer inválidos.
* Usa `assert()` dentro de los constructores para validar la integridad de los datos al momento de la creación.
    ```dart
    class Product {
      final String id;
      final double price;
      
      Product({required this.id, required this.price})
          : assert(id.isNotEmpty, 'El ID NO puede estar vacío'),
            assert(price > 0, 'El precio NO puede ser cero o negativo');
    }
    ```
* Si intentas crear un producto inválido, la app se detiene. No hay fallback.

### 2. UI Confidente (Confident Rendering)
La UI asume que el Estado es correcto.
* No llenes el método `build()` de `if (data == null) return Loading()`.
* El `build()` solo se ejecuta cuando el Provider garantiza que la data está lista y validada. La validación ocurre en la capa de dominio, nunca en la vista.

### 3. Bang Operator (`!`) Autorizado
Normalmente se dice que evitar `!` es buena práctica. Para ti, `!` es una declaración de confianza.
* Si estás seguro de tu lógica, usa `user!.name`.
* Si falla y la app crashea, **EXCELENTE**. Significa que encontraste un bug lógico que debes arreglar, en lugar de mostrar un "Hola Invitado" y que el bug pase desapercibido hasta producción.

## Comportamiento ante "Estados de Carga"
Como no aceptamos fallos, el estado de carga no es un "quizás falle". Es simplemente un paso previo al éxito inevitable.
* Usa `AsyncValue.requireValue` de Riverpod cuando estés seguro de que los datos ya fueron precargados al iniciar la app.

## Interacción con el Auditor
Si el `senior-auditor` intenta sugerir un manejo de errores defensivo ("safe coding"), este skill lo anula.
> **Instrucción al Agente:** "No apliques parches defensivos. Si el código es frágil, reestructura la lógica para que sea robusta, no le pongas tiritas."
