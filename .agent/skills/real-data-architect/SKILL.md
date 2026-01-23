---
name: real-data-architect
description: Fuerza el patrón de repositorio y prohíbe datos hardcodeados en la UI. Gestiona la inyección de datos mock directamente en la base de datos.
---

# Real Data Architect Skill

## Principio Fundamental: "Zero UI Data"

La interfaz de usuario (UI) es "tonta". Nunca sabe qué datos va a mostrar hasta que se los entrega un Provider conectado a una Base de Datos.

**ESTÁ ESTRICTAMENTE PROHIBIDO:** Declarar listas, mapas o variables con datos de contenido dentro de un Widget o un Controller de UI.

```dart
// ❌ PROHIBIDO - Data en la UI
class ProductListScreen extends StatelessWidget {
  // NUNCA HAGAS ESTO
  final products = [
    {'name': 'Shoe', 'price': 100},
    {'name': 'Shirt', 'price': 50},
  ];
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => Text(products[index]['name']),
    );
  }
}
```

## Reglas de Integridad de Datos

### 1. No Mockups en UI
Nunca escribas datos de prueba dentro de un widget para "ver cómo queda". Si necesitas datos de prueba, van en la base de datos.

### 2. Arquitectura de Capas Obligatoria

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│  ConsumerWidget → ref.watch(provider) → Muestra datos   │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                         │
│  Entity / Model tipado (User, Product, Task, etc.)      │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                          │
│  Repository (IRepository) → DataSource → DB / API       │
└─────────────────────────────────────────────────────────┘
```

| Capa | Responsabilidad | Ejemplo |
|------|-----------------|---------|
| **Data Layer** | Repositorio que habla con DB/API | `TaskRepositoryImpl` |
| **Domain Layer** | Entidad o Modelo tipado | `Task`, `User` |
| **Presentation Layer** | Consume via Riverpod | `ref.watch(tasksProvider)` |

### 3. Manejo de "Mock Data" (Protocolo de Seeding)

Si el usuario pide ver datos de prueba ("Mockup Info"), tu flujo de trabajo es:

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│    PASO A        │───▶│    PASO B        │───▶│    PASO C        │
│  Crear función   │    │  Ejecutar seed   │    │  UI consulta DB  │
│  seedDatabase()  │    │  para insertar   │    │  y muestra datos │
└──────────────────┘    └──────────────────┘    └──────────────────┘
```

**Nunca el Paso C ocurre sin el Paso A y B.**

## Estructura de Archivos Requerida

Para cualquier feature que maneje datos:

```
lib/
└── features/
    └── tasks/
        ├── data/
        │   ├── datasources/
        │   │   ├── task_local_datasource.dart
        │   │   └── task_remote_datasource.dart
        │   ├── models/
        │   │   └── task_model.dart          # Con fromJson/toJson
        │   └── repositories/
        │       └── task_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   └── task.dart                # Entidad pura
        │   └── repositories/
        │       └── i_task_repository.dart   # Interfaz abstracta
        └── presentation/
            ├── providers/
            │   └── tasks_provider.dart
            ├── screens/
            │   └── tasks_screen.dart
            └── widgets/
                └── task_card.dart
```

## Instrucciones para Flutter & Riverpod

### 1. Future/Stream Providers Obligatorios

Usa siempre `FutureProvider` o `StreamProvider` para leer listas de la base de datos. Esto maneja nativamente los estados de `loading` y `error`.

```dart
// ✅ CORRECTO - Provider conectado a repositorio
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getAllTasks();
});

// ✅ CORRECTO - Stream para datos en tiempo real
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});
```

### 2. Repositorios Abstractos

Define siempre una interfaz antes de la implementación concreta. Esto permite cambiar la DB real por otra en el futuro sin romper la UI.

```dart
// domain/repositories/i_task_repository.dart
abstract class ITaskRepository {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Stream<List<Task>> watchAllTasks();
}

// domain/entities/task.dart
class Task {
  final String id;
  final String title;
  
  Task({required this.id, required this.title})
    : assert(id.isNotEmpty, 'Task ID required'),
      assert(title.isNotEmpty, 'Task title required');
}
```

### 3. Manejo de "Mock Data" (Protocolo de Seeding)

```dart
// Inyección de dependencia via Riverpod
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dataSource = ref.watch(taskLocalDataSourceProvider);
  return TaskRepositoryImpl(dataSource);
});
```

## Ejemplo de Flujo Correcto

**Usuario:** "Haz una lista de tareas de prueba."

### ❌ Respuesta PROHIBIDA:
```dart
// BAD - Datos hardcodeados en UI
class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text("Tarea 1"),
        Text("Tarea 2"),
        Text("Tarea 3"),
      ],
    );
  }
}
```

### ✅ Respuesta CORRECTA:

**Paso A - Crear función de seeding:**
```dart
// lib/core/database/seeders/task_seeder.dart
class TaskSeeder {
  final ITaskRepository _repository;
  
  TaskSeeder(this._repository);
  
  Future<void> seedTasks() async {
    final mockTasks = [
      Task(
        id: const Uuid().v4(),
        title: 'Completar documentación DS-160',
        description: 'Llenar todos los campos del formulario',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        isCompleted: false,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Agendar cita en la embajada',
        description: 'Revisar disponibilidad para próximas semanas',
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 14)),
        isCompleted: false,
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Preparar documentos de soporte',
        description: 'Estados de cuenta, cartas de trabajo, etc.',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        isCompleted: true,
      ),
    ];
    
    for (final task in mockTasks) {
      await _repository.createTask(task);
    }
  }
}
```

**Paso B - Ejecutar seed (en main o setup):**
```dart
// Solo en desarrollo
if (kDebugMode) {
  final seeder = TaskSeeder(ref.read(taskRepositoryProvider));
  await seeder.seedTasks();
}
```

**Paso C - UI consume de la base de datos:**
```dart
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tareas')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (tasks) => tasks.isEmpty
          ? const EmptyStateView(
              icon: Icons.task_alt,
              message: 'No hay tareas pendientes',
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskCard(task: tasks[index]),
            ),
      ),
    );
  }
}
```

## Checklist de Validación

Antes de entregar código que muestre datos:

- [ ] ¿Los datos vienen de un `Provider` conectado a un `Repository`?
- [ ] ¿Existe una interfaz `IRepository` abstracta?
- [ ] ¿El modelo/entidad está tipado correctamente?
- [ ] ¿El modelo incluye `asserts` para garantizar integridad (Zero Tolerance)?
- [ ] ¿Los datos de prueba están en un `Seeder`, no en la UI?
- [ ] ¿Se usa `FutureProvider` o `StreamProvider` para la consulta?
- [ ] ¿Los estados loading/error/empty están manejados?

## Consecuencia de Violación

Si el código contiene:
- Listas o mapas con datos hardcodeados en widgets
- Datos de "ejemplo" directamente en la UI
- Widgets que no consumen de un Provider/Repository

**El código se considera RECHAZADO y debe ser reescrito siguiendo el patrón Repository + Seeder.**
