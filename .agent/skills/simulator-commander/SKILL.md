---
name: simulator-commander
description: Operador de despliegue local. Se encarga de compilar, limpiar procesos antiguos y lanzar la aplicación en el emulador Android al finalizar una tarea para validación visual inmediata.
---

# Simulator Commander Skill

## Filosofía: "Build First, Then Talk"
El trabajo no está terminado cuando se cierra el archivo de código. Está terminado cuando la app corre en el simulador sin errores rojos.
Tu misión es asegurar que cada cambio resulte en una build ejecutable.

## Protocolo "Auto-Launch" (Post-Task)
Al finalizar cualquier modificación de código (UI, Lógica o Database), debes ejecutar la siguiente secuencia de comandos en la terminal integrada sin esperar solicitud:

1.  **Kill Switch (Limpieza):**
    Asegura que no haya instancias colgadas bloqueando puertos.
    * *Comando:* `pkill -f 'flutter'` (o buscar el PID y matarlo).

2.  **Build Verification (Compilación Silenciosa):**
    Antes de lanzar, verifica que compile.
    * *Comando:* `flutter build apk --debug --target-platform android-arm64`
    * *Si falla:* **DETENTE.** No intentes lanzar. Reporta el error de compilación y arréglalo inmediatamente (invocando al `senior-auditor`).

3.  **Launch (El Lanzamiento):**
    Lanza la app en el dispositivo conectado (Android Emulator).
    * *Comando:* `flutter run -t lib/main_dev.dart -d android` (o el ID específico del emulador).
    * *Nota:* Si el entorno lo permite, usa Hot Restart (`Shift+R` o `r` mayúscula) si la sesión ya estaba viva, pero ante cambios estructurales (nuevos paquetes, cambios en `main.dart`), fuerza un reinicio completo.

## Verificación de Salud (Health Check)
Al lanzar la app, monitorea el `stdout` (logs) por los primeros 10 segundos buscando:
* `Exception`
* `Error`
* `Grey Screen of Death` (implícito por errores de renderizado).

Si detectas un error en el arranque, tu tarea NO ha terminado. Debes aplicar un fix y volver al paso 1.

## Protocolo de Rescate (Splash Screen Stuck)
Si la app se queda pegada en el logo de Flutter (Splash Screen) por más de 15 segundos:
1.  **Abortar:** Mata el proceso (`Ctrl+C` o `pkill`).
2.  **Limpieza Profunda:**
    * `flutter clean`
    * `flutter pub get`
3.  **Re-Lanzamiento:** Ejecuta `flutter run` nuevamente.
4.  **Verificación:** Si falla 2 veces seguidas, es un error de código en `main.dart`. NO sigas intentando. Debuggea la inicialización.

## Integración con Integration Tests (Modo Pro)
Si el usuario definió un test de integración (`integration_test`), en lugar de solo abrir la app, ejecútalo para que el robot "use" la app frente al usuario.
* *Comando:* `flutter test integration_test/app_test.dart -d android`

## Salida Esperada
Al final de tu respuesta, confirma el estado del despliegue:

> **🚀 SIMULATOR COMMANDER**
> * **Build:** ✅ Exitosa
> * **Action:** App lanzada en `emulator-5554`
> * **Logs:** Sin excepciones en el arranque.
> * **Estado:** La app está lista en pantalla para tu revisión visual.
