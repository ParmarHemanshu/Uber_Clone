
import 'package:uber_driver_app/features/uber_profile_feature/data/models/uber_profile_driver_model.dart';

abstract class UberProfileDataSource {
  Stream<DriverProfileModel> getDriverProfile(String driverId);
  Future<void> updateDriverProfile(DriverProfileModel driverModel, String driverId);
  Future<void> walletAddMoney(String driverId, int avlAmt, int addAmt);
}
