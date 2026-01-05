import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile/core/offline/data/services/offline_queue_service.dart';
import 'package:mobile/core/offline/domain/entities/offline_request.dart';

void main() {
  late OfflineQueueService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);
    
    // Register Adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(OfflineRequestAdapter());
    }

    service = OfflineQueueService();
    await service.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('addRequest adds item to hive box', () async {
    await service.addRequest('POST', '/api/v1/test', data: {'foo': 'bar'});
    
    final requests = service.getPendingRequests();
    expect(requests.length, 1);
    expect(requests.first.method, 'POST');
    expect(requests.first.path, '/api/v1/test');
    expect(requests.first.data?['foo'], 'bar');
  });

  test('removeRequest deletes item from hive box', () async {
    await service.addRequest('DELETE', '/api/v1/item');
    var requests = service.getPendingRequests();
    expect(requests.length, 1);

    await service.removeRequest(requests.first);
    
    requests = service.getPendingRequests();
    expect(requests.isEmpty, true);
  });
}
