// models/lookup_model.dart
class LookupModel {
  final int id;
  final String? name;

  LookupModel({
    required this.id,
    required this.name,
  });

  factory LookupModel.fromJson(Map<String, dynamic> json) {
    return LookupModel(
      id: json['id'] as int,
      name: json['name'] ??"",
    );
  }


}

