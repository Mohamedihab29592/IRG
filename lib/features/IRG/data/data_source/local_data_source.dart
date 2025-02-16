import 'package:dartz/dartz.dart';

import '../../../../core/services/data_base_helper.dart';
import '../Model/location_model.dart';
import '../Model/lookup_data_model.dart';
import '../Model/lookup_model.dart';



class IncidentLocalDataSource {
  final DatabaseHelper dbHelper;

  IncidentLocalDataSource({required this.dbHelper});

  Future<Either<String, List<LookupModel>>> getIncidentTypes() async {
    try {
      final result = await dbHelper.getIncidentTypes();
      print('Incident Types Result: $result');
      return Right(result.map((item) => LookupModel.fromJson(item)).toList());
    } catch (e) {
      return Left('Error fetching incident types: $e');
    }
  }

  Future<Either<String, List<LookupModel>>> getLocationTypes() async {
    try {
      final result = await dbHelper.getLocationTypes();
      print('Location Types Result: $result');
      return Right(result.map((item) => LookupModel.fromJson(item)).toList());
    } catch (e) {
      return Left('Error fetching location types: $e');
    }
  }

  Future<Either<String, List<LocationModel>>> getLocationsByType(String locationType) async {
    try {
      // Use the actual locationType parameter instead of 'all'
      final result = await dbHelper.getLocationsByType(locationType);
      print('Locations for type $locationType: $result');

      if (result.isEmpty) {
        print('No locations found for type: $locationType');
        return const Right([]);
      }

      return Right(result.map((item) => LocationModel.fromJson(item)).toList());
    } catch (e) {
      print('Error in getLocationsByType: $e');
      return Left('Error fetching locations: $e');
    }
  }

  Future<Either<String, LookupDataModel>> getAllLookupData() async {
    try {
      final incidentTypes = await dbHelper.getIncidentTypes();
      final locationTypes = await dbHelper.getLocationTypes();

      // We don't want to get locations here as they should be filtered by type
      // when requested specifically
      final actionItems = await dbHelper.getActionItems();
      final leaMembers = await dbHelper.getLeaMembers();
      final socTeam = await dbHelper.getSocTeam();
      final incidentDetails = await dbHelper.getIncidentDetails();
      final closureStatus = await dbHelper.getClosureStatus();

      return Right(
        LookupDataModel(
          incidentTypes: incidentTypes.map((item) => LookupModel.fromJson(item)).toList(),
          locationTypes: locationTypes.map((item) => LookupModel.fromJson(item)).toList(),
          // Initialize with empty list - locations will be fetched when type is selected
          locations: [],
          actionItems: actionItems.map((item) => LookupModel.fromJson(item)).toList(),
          leaMembers: leaMembers.map((item) => LookupModel.fromJson(item)).toList(),
          socTeam: socTeam.map((item) => LookupModel.fromJson(item)).toList(),
          incidentDetails: incidentDetails.map((item) => LookupModel.fromJson(item)).toList(),
          closureStatus: closureStatus.map((item) => LookupModel.fromJson(item)).toList(),
        ),
      );
    } catch (e) {
      print('Error in getAllLookupData: $e');
      return Left('Error fetching lookup data: $e');
    }
  }
}