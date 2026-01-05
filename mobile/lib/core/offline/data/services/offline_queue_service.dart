import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/offline/domain/entities/offline_request.dart';

class OfflineQueueService {
  static const String boxName = 'offline_queue';
  Box<OfflineRequest>? _box;

  Future<void> init() async {
    // Register adapter only if not already registered (validation for tests)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineRequestAdapter());
    }
    _box = await Hive.openBox<OfflineRequest>(boxName);
  }

  Future<void> addRequest(String method, String path, {Map<String, dynamic>? data}) async {
    final request = OfflineRequest(
      method: method,
      path: path,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _box?.add(request);
  }

  List<OfflineRequest> getPendingRequests() {
    return _box?.values.toList() ?? [];
  }

  Future<void> removeRequest(OfflineRequest request) async {
    await request.delete();
  }
}
