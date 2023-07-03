// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biography.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Biography _$BiographyFromJson(Map<String, dynamic> json) => Biography(
      placeOfBirth: json['place-of-birth'] as String,
      aliases:
          (json['aliases'] as List<dynamic>).map((e) => e as String).toList(),
      fullName: json['full-name'] as String,
      alignment: json['alignment'] as String,
    );

Map<String, dynamic> _$BiographyToJson(Biography instance) => <String, dynamic>{
      'alignment': instance.alignment,
      'full-name': instance.fullName,
      'place-of-birth': instance.placeOfBirth,
      'aliases': instance.aliases,
    };
