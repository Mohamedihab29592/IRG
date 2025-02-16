import 'package:dartz/dartz.dart';

import '../data/Model/location_model.dart';
import '../data/Model/lookup_data_model.dart';
import '../data/Model/lookup_model.dart';

abstract class IncidentRepository {
  Future<Either<String, List<LookupModel>>> getIncidentTypes();
  Future<Either<String, List<LookupModel>>> getLocationTypes();
  Future<Either<String, List<LocationModel>>> getLocationsByType(String locationType);
  Future<Either<String, LookupDataModel>> getAllLookupData();
}