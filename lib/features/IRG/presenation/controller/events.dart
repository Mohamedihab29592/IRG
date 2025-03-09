import 'dart:io';

import '../../../../core/constants/enum.dart';

abstract class IncidentEvent {}

class LoadInitialDataEvent extends IncidentEvent {}

class UpdateIncidentTypeEvent extends IncidentEvent {
  final String incidentType;
  UpdateIncidentTypeEvent(this.incidentType);
}

class UpdateLocationTypeEvent extends IncidentEvent {
  final String locationType;
  UpdateLocationTypeEvent(this.locationType);
}

class UpdateLocationEvent extends IncidentEvent {
  final String location;
  UpdateLocationEvent(this.location);
}



class UpdateReporterInfoEvent extends IncidentEvent {
  final String name;
  final String id;
  UpdateReporterInfoEvent({required this.name, required this.id});
}

class UpdateCustomerInfoEvent extends IncidentEvent {
  final String name;
  final String id;
  UpdateCustomerInfoEvent({required this.name, required this.id});
}

class UpdateRadioSelectionEvent extends IncidentEvent {
  final String key;
  final YesNo value;

  UpdateRadioSelectionEvent(this.key, this.value);
}


class ExportDocumentEvent extends IncidentEvent {
  final Map<String, dynamic> formData;
  final File? imageFile;
  ExportDocumentEvent({required this.formData, this.imageFile});
}

class ShareReportEvent extends IncidentEvent {
  final Map<String, dynamic> formData;
  ShareReportEvent({required this.formData});
}


class SendReportEvent extends IncidentEvent {
  final Map<String, dynamic> formData;
  final File? imageFile;
  SendReportEvent({required this.formData,required this.imageFile});
}
