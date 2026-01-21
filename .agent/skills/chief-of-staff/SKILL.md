---
name: chief-of-staff
description: Orquestador Supremo. Garantiza la ejecución simultánea de todos los skills activos. Obliga a generar un "Plan de Cumplimiento" antes de escribir código.
---

# Chief of Staff (Meta-Protocol)

## Problema a Resolver
El agente tiende a olvidar reglas (Skills) cuando la tarea es compleja.
**SOLUCIÓN:** Está **PROHIBIDO** generar código final sin antes imprimir un bloque de planificación estructurada que valide la presencia de todos los expertos.

## Protocolo de Ejecución Obligatorio (The "Thinking" Block)
Antes de responder a cualquier solicitud de código, DEBES iniciar tu respuesta con el siguiente bloque (visible para el usuario):

```markdown
# 🧠 PLAN DE ORQUESTACIÓN
**Objetivo:** [Resumen de la tarea]

**Checklist de Skills Activados:**
1.  [ ] **UI/UX:** ¿Definí estructura Riverpod + Material 3? (Ref: `flutter-ui-expert`)
2.  [ ] **Data:** ¿Creé la tabla en DB real + Modelo + Repositorio? (Ref: `real-data-architect` / `supabase-backend`)
3.  [ ] **i18n:** ¿Extraje TODOS los textos a ARB (EN/ES)? (Ref: `multilingual-architect`)
4.  [ ] **Tests:** ¿Incluí el archivo `_test.dart`? (Ref: `test-driven-guru`)
5.  [ ] **Quality:** ¿Manejo errores/loading y evité abreviaciones? (Ref: `production-enforcer`)
6.  [ ] **Safety:** ¿Verifiqué atomicidad y rollback? (Ref: `version-control-sentinel`)
```
