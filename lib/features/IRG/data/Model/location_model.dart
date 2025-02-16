import 'lookup_model.dart';

class LocationModel extends LookupModel {
  final int locationTypeId;

  LocationModel({
    required super.id,
    required super.name,
    required this.locationTypeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      locationTypeId: json['location_type_id'] as int,
    );
  }


}
