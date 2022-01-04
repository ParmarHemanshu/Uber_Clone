import 'package:uber_driver_app/features/uber_auth_feature/domain/entities/vehicle_entity.dart';

abstract class UberAuthRepository {
  Future<bool> uberAuthIsSignIn();
  Future<void> uberAuthPhoneVerification(String phoneNumber);
  Future<void> uberAuthOtpVerification(String otp);
  Future<String> uberAuthGetUserUid();
  Future<bool> uberAuthCheckUserStatus(String docId);
  Future<void> uberAuthSignOut();
  Future<String> uberAddProfileImg(String driverId);
  Future<void>uberAddVehicleDetails(VehicleEntity vehicleEntity);
}
