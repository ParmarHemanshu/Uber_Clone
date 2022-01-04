import 'package:uber_driver_app/features/uber_trip_feature/data/models/driver_location/driver_model.dart';
import 'package:uber_driver_app/features/uber_trip_feature/domain/entities/trip_driver.dart';

abstract class TripHistoryRepository{
  Stream<List<TripDriver>> tripDriverStream(bool isHistory,String driverId, String? tripId);
  Future<void> updateDriverAndTrip(TripDriver tripDriver,DriverModel driverModel,bool isDriver);
}