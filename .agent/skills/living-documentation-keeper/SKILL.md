---
name: living-documentation-keeper
description: Guardián de la Verdad del Proyecto. Mantiene y actualiza un archivo maestro (APP_BIBLE.md) con cada cambio de código. Asegura que el contexto de negocio, flujos y arquitectura estén siempre sincronizados con la realidad del código.
---

# Living Documentation Keeper Skill

## La Misión: "El Código es Volátil, la Biblia es Eterna"
Tu responsabilidad es asegurar que exista una **Única Fuente de Verdad** que describa el funcionamiento exacto, el propósito de negocio y la estructura técnica de la app.
Este documento no es un "readme" estático. Es un ente viviente que crece con cada feature.

## El Artefacto Sagrado: `docs/APP_BIBLE.md`
Debes crear y mantener este archivo en la raíz del proyecto. Su estructura es INNEGOCIABLE:

1.  **Visión & Negocio:** ¿Qué hace la app? ¿Cuál es el "Goal Final"? ¿Quién es el usuario?
2.  **Arquitectura Técnica:** Stack actual (Flutter, Riverpod, Supabase), versiones y decisiones de diseño (ej. "Zero Fallbacks").
3.  **Mapa de la App (Sitemap):** Lista detallada de pantallas.
    * *Screen:* Login
    * *Goal:* Autenticar usuarios.
    * *Conexiones:* Va a Home si éxito, muestra error si falla.
    * *Estado:* `authProvider`.
4.  **Diccionario de Datos:** Explicación de las tablas de Supabase y sus relaciones clave.
5.  **Reglas de Negocio:** Lógica dura (ej. "Un usuario no puede tener dos roles").

## Protocolo de "Sincronización Atómica"
Cada vez que generes, modifiques o elimines código, debes actualizar la Biblia SIMULTÁNEAMENTE.

* **Si creas una pantalla:** Agregala al "Mapa de la App" con su descripción funcional.
* **Si cambias una regla (ej. validación):** Actualiza la sección "Reglas de Negocio".
* **Si conectas una API:** Documenta el endpoint y el flujo de datos en "Diccionario de Datos".

**ESTRICTAMENTE PROHIBIDO:** Entregar código nuevo sin el diff correspondiente en `APP_BIBLE.md`.

## Flujo de "Lectura Previa" (Context Loading)
Al iniciar cualquier tarea compleja, tu primer paso interno debe ser:
1.  Leer `docs/APP_BIBLE.md`.
2.  Entender el impacto del cambio solicitado en el "Gran Esquema".
3.  Si la solicitud del usuario contradice la Biblia, **ALERTA**: *"Usuario, pides X, pero la Biblia dice que el objetivo es Y. ¿Actualizamos la Biblia o corregimos la solicitud?"*

## Mantenimiento de la Integridad
Si detectas que el código actual contradice la documentación (drift):
* Tu prioridad #1 es arreglar la documentación para que refleje la realidad (o arreglar el código si la realidad es incorrecta).

## Ejemplo de Ejecución
**Solicitud:** "Agrega fecha de nacimiento al registro."
**Tu Respuesta incluye:**
1.  Código modificado (`user_model.dart`, `register_screen.dart`, `migration.sql`).
2.  **ACTUALIZACIÓN DE BIBLIA:**
    ```markdown
    // Cambio en docs/APP_BIBLE.md
    ### Entidad Usuario
    - `birth_date` (Date, Required): Necesario para validación de edad legal (Regla #4).
    ```
