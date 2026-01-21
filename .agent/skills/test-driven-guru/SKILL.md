---
name: test-driven-guru
description: Garantiza la estabilidad del código exigiendo Unit Tests y Widget Tests para cada componente generado.
---

# Test Driven Guru Skill

## Filosofía: "If it's not tested, it's broken"

En un entorno de producción real, el código no se considera "terminado" hasta que pasa sus pruebas automatizadas.

**REGLA ABSOLUTA:** Cada archivo `.dart` que contenga lógica (Repositories, Providers, Notifiers) o UI compleja (Screens, Widgets) debe venir acompañado de su archivo `_test.dart`.

## Estructura de Entrega Pareada

Siempre que generes código, la estructura de entrega debe ser pareada:

```
lib/features/auth/presentation/screens/login_screen.dart
test/features/auth/presentation/screens/login_screen_test.dart  ← OBLIGATORIO

lib/features/auth/data/repositories/auth_repository_impl.dart
test/features/auth/data/repositories/auth_repository_impl_test.dart  ← OBLIGATORIO

lib/features/auth/presentation/providers/auth_provider.dart
test/features/auth/presentation/providers/auth_provider_test.dart  ← OBLIGATORIO
```

## Reglas de Cobertura (Flutter & Riverpod)

### 1. Unit Tests (Lógica)

Para cada **Provider** o **Notifier**, debes testear:

| Caso | Descripción | Obligatorio |
|------|-------------|-------------|
| Estado inicial | Verificar el estado por defecto | ✅ SÍ |
| Actualización exitosa | El estado cambia correctamente | ✅ SÍ |
| Manejo de errores | Simular fallo de red/DB | ✅ SÍ |
| Edge cases | Lista vacía, datos inválidos | ✅ SÍ |

```dart
// test/features/tasks/presentation/providers/tasks_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockTaskRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockTaskRepository();
    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TasksProvider', () {
    test('estado inicial es AsyncLoading', () {
      final state = container.read(tasksProvider);
      expect(state, isA<AsyncLoading>());
    });

    test('carga tareas exitosamente', () async {
      // Arrange
      final mockTasks = [
        Task(id: '1', title: 'Test Task', isCompleted: false),
      ];
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => mockTasks);

      // Act
      await container.read(tasksProvider.future);

      // Assert
      final state = container.read(tasksProvider);
      expect(state.value, equals(mockTasks));
    });

    test('maneja error de red correctamente', () async {
      // Arrange
      when(() => mockRepository.getAllTasks())
          .thenThrow(NetworkException('Sin conexión'));

      // Act & Assert
      expect(
        () => container.read(tasksProvider.future),
        throwsA(isA<NetworkException>()),
      );
    });

    test('retorna lista vacía cuando no hay tareas', () async {
      // Arrange
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => <Task>[]);

      // Act
      await container.read(tasksProvider.future);

      // Assert
      final state = container.read(tasksProvider);
      expect(state.value, isEmpty);
    });
  });
}
```

**Regla de Mocking:** Usa `mocktail` o `mockito` para burlar (mock) los Repositorios. **Nunca uses la DB real en un Unit Test.**

### 2. Widget Tests (UI)

Para cada **Screen** o **Widget Reutilizable**:

| Verificación | Descripción | Obligatorio |
|--------------|-------------|-------------|
| Elementos presentes | Títulos, botones, iconos visibles | ✅ SÍ |
| Interacciones | Taps, scrolls, inputs funcionan | ✅ SÍ |
| Respuesta visual | SnackBars, cambios de texto | ✅ SÍ |
| Estados de carga | Loading indicator aparece | ✅ SÍ |
| Estados de error | Mensaje de error visible | ✅ SÍ |

```dart
// test/features/tasks/presentation/screens/tasks_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements ITaskRepository {}

void main() {
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: TasksScreen(),
      ),
    );
  }

  group('TasksScreen', () {
    testWidgets('muestra loading indicator inicialmente', (tester) async {
      // Arrange
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => Future.delayed(
                const Duration(seconds: 1),
                () => <Task>[],
              ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra lista de tareas cuando carga exitosamente', (tester) async {
      // Arrange
      final mockTasks = [
        Task(id: '1', title: 'Tarea de Prueba', isCompleted: false),
      ];
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => mockTasks);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tarea de Prueba'), findsOneWidget);
    });

    testWidgets('muestra empty state cuando no hay tareas', (tester) async {
      // Arrange
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => <Task>[]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No hay tareas pendientes'), findsOneWidget);
    });

    testWidgets('muestra error y botón de reintentar', (tester) async {
      // Arrange
      when(() => mockRepository.getAllTasks())
          .thenThrow(Exception('Error de red'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('tap en tarea navega a detalle', (tester) async {
      // Arrange
      final mockTasks = [
        Task(id: '1', title: 'Tarea Clickeable', isCompleted: false),
      ];
      when(() => mockRepository.getAllTasks())
          .thenAnswer((_) async => mockTasks);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tarea Clickeable'));
      await tester.pumpAndSettle();

      // Assert - verificar navegación o cambio de estado
      // ...
    });
  });
}
```

### 3. Golden Tests (Opcional pero Recomendado)

Si el usuario pide "Pixel Perfect", genera un test de Golden Image para asegurar que el diseño no cambie accidentalmente.

```dart
testWidgets('TaskCard matches golden file', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TaskCard(
          task: Task(id: '1', title: 'Test', isCompleted: false),
        ),
      ),
    ),
  );
  
  await expectLater(
    find.byType(TaskCard),
    matchesGoldenFile('goldens/task_card.png'),
  );
});
```

## Comportamiento del Agente

### 1. Mocking Automático

Si el código depende de una clase externa (ej. `AuthRepository`), genera automáticamente la clase Mock dentro del archivo de test:

```dart
// Al inicio del archivo de test
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockNavigator extends Mock implements NavigatorObserver {}

// Si usas clases con métodos que reciben argumentos tipados
setUpAll(() {
  registerFallbackValue(User(id: '', email: '', name: ''));
});
```

### 2. Pump & Settle Obligatorio

En Widget Tests, **siempre** usa `await tester.pumpAndSettle()` después de interacciones asíncronas:

```dart
// ❌ INCORRECTO - puede fallar por animaciones pendientes
await tester.tap(find.byType(ElevatedButton));
expect(find.text('Success'), findsOneWidget);

// ✅ CORRECTO - espera animaciones
await tester.tap(find.byType(ElevatedButton));
await tester.pumpAndSettle();
expect(find.text('Success'), findsOneWidget);
```

### 3. Casos de Borde Obligatorios

No testes solo el éxito. Escribe tests explícitos para:

| Caso de Borde | Ejemplo |
|---------------|---------|
| Lista vacía | `expect(find.text('No hay datos'), findsOneWidget);` |
| Error de servidor | Simular HTTP 500, verificar mensaje de error |
| Datos inválidos | Campos null, strings vacíos |
| Timeout | Simular delay excesivo |
| Sin conexión | `NetworkException` |

## Patrón AAA (Arrange-Act-Assert)

Todos los tests deben seguir el patrón AAA:

```dart
test('descripción del comportamiento esperado', () async {
  // 1. ARRANGE - Configurar el escenario
  final mockData = [...];
  when(() => repository.fetch()).thenAnswer((_) async => mockData);
  
  // 2. ACT - Ejecutar la acción
  final result = await useCase.execute();
  
  // 3. ASSERT - Verificar el resultado
  expect(result, equals(mockData));
  verify(() => repository.fetch()).called(1);
});
```

## Checklist de Tests

Antes de entregar código:

- [ ] ¿Cada archivo de lógica tiene su `_test.dart` pareado?
- [ ] ¿Los repositorios están mockeados (no DB real)?
- [ ] ¿Se testea el estado inicial?
- [ ] ¿Se testea el happy path (éxito)?
- [ ] ¿Se testea el error path (fallo)?
- [ ] ¿Se testean los edge cases (vacío, inválido)?
- [ ] ¿Los Widget tests usan `pumpAndSettle()`?
- [ ] ¿Se usa el patrón AAA?

## Consecuencia de Violación

Si el código entregado:
- No incluye archivo `_test.dart` para lógica/UI compleja
- Solo testea el "happy path"
- Usa la DB real en lugar de mocks
- Omite `pumpAndSettle()` en Widget tests

**El código se considera INCOMPLETO y debe ser complementado con los tests faltantes.**
