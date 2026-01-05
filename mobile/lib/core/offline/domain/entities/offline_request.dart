import 'package:hive/hive.dart';

part 'offline_request.g.dart';

@HiveType(typeId: 0)
class OfflineRequest extends HiveObject {
  @HiveField(0)
  final String method;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final Map<String, dynamic>? data;

  @HiveField(3)
  final int timestamp;

  OfflineRequest({
    required this.method,
    required this.path,
    this.data,
    required this.timestamp,
  });
}
