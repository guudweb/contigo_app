// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryEntryAdapter extends TypeAdapter<HistoryEntry> {
  @override
  final int typeId = 1;

  @override
  HistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryEntry(
      date: fields[0] as DateTime,
      phase: fields[1] as String,
      category: fields[2] as String,
      prompt: fields[3] as String,
      message: fields[4] as String?,
      shareMethod: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.phase)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.prompt)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.shareMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
