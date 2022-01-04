
import 'package:uber_driver_app/features/uber_trip_feature/data/models/trip_history/rider_model.dart';
import 'package:uber_driver_app/features/uber_trips_history_feature/data/models/uber_trips_history_model.dart';

class TripDriver {
final TripHistoryModel tripHistoryModel;
final RiderModel riderModel;

  TripDriver(this.tripHistoryModel, this.riderModel);
}