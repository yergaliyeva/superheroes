import 'package:json_annotation/json_annotation.dart';

part 'biography.g.dart';

@JsonSerializable(fieldRename: FieldRename.kebab, explicitToJson: true)
class Biography {
  final String alignment;
  final String fullName;
  final String placeOfBirth;
  final List<String> aliases;

  Biography(
      {required this.placeOfBirth,
      required this.aliases,
      required this.fullName,
      required this.alignment});
  factory Biography.fromJson(final Map<String, dynamic> json) =>
      _$BiographyFromJson(json);

  Map<String, dynamic> toJson() => _$BiographyToJson(this);
}
