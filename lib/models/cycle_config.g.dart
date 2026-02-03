// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleConfigAdapter extends TypeAdapter<CycleConfig> {
  @override
  final int typeId = 0;

  @override
  CycleConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CycleConfig(
      partnerName: fields[0] as String?,
      lastPeriodDate: fields[1] as DateTime,
      cycleLength: fields[2] as int,
      periodLength: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CycleConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.partnerName)
      ..writeByte(1)
      ..write(obj.lastPeriodDate)
      ..writeByte(2)
      ..write(obj.cycleLength)
      ..writeByte(3)
      ..write(obj.periodLength);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
