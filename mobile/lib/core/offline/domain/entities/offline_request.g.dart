// GENERATED CODE - MANUAL IMPLEMENTATION
// Migrated manually to bypass hive_generator version conflict with riverpod_generator
part of 'offline_request.dart';

// import 'offline_request.dart'; // No longer needed as it is part of the same library


class OfflineRequestAdapter extends TypeAdapter<OfflineRequest> {
  @override
  final int typeId = 0;

  @override
  OfflineRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineRequest(
      method: fields[0] as String,
      path: fields[1] as String,
      data: (fields[2] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineRequest obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.method)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
