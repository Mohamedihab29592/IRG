import 'location_model.dart';
import 'lookup_model.dart';

class LookupDataModel {
  final List<LookupModel> incidentTypes;
  final List<LookupModel> locationTypes;
  final List<LocationModel> locations;
  final List<LookupModel> actionItems;
  final List<LookupModel> leaMembers;
  final List<LookupModel> socTeam;
  final List<LookupModel> incidentDetails;
  final List<LookupModel> closureStatus;

  LookupDataModel({
    required this.incidentTypes,
    required this.locationTypes,
    required this.locations,
    required this.actionItems,
    required this.leaMembers,
    required this.socTeam,
    required this.incidentDetails,
    required this.closureStatus,
  });

  factory LookupDataModel.fromJson(Map<String, dynamic> json) {
    return LookupDataModel(
      incidentTypes: (json['incident_types'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      locationTypes: (json['location_types'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      locations: (json['locations'] as List)
          .map((item) => LocationModel.fromJson(item))
          .toList(),
      actionItems: (json['action_items'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      leaMembers: (json['lea_members'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      socTeam: (json['soc_team'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      incidentDetails: (json['incident_details'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
      closureStatus: (json['closure_status'] as List)
          .map((item) => LookupModel.fromJson(item))
          .toList(),
    );
  }


}
