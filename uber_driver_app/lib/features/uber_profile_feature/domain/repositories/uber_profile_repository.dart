

import 'package:uber_driver_app/features/uber_auth_feature/domain/entities/driver_entity.dart';

abstract class UberProfileRepository {
  Stream<DriverEntity> getDriverProfile(String driverId);
  Future<void> updateDriverProfile(DriverEntity driverEntity, String driverId);

}
