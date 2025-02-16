import 'package:dartz/dartz.dart';

import '../../domain/repo.dart';
import '../Model/location_model.dart';
import '../Model/lookup_data_model.dart';
import '../Model/lookup_model.dart';
import '../data_source/local_data_source.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentLocalDataSource localDataSource;

  IncidentRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<String, List<LookupModel>>> getIncidentTypes() async {
    return await localDataSource.getIncidentTypes();
  }

  @override
  Future<Either<String, List<LookupModel>>> getLocationTypes() async {
    return await localDataSource.getLocationTypes();
  }

  @override
  Future<Either<String, List<LocationModel>>> getLocationsByType(String locationType) async {
    return await localDataSource.getLocationsByType(locationType);
  }

  @override
  Future<Either<String, LookupDataModel>> getAllLookupData() async {
    final result = await localDataSource.getAllLookupData();
    print(result);
    return result;
  }
}