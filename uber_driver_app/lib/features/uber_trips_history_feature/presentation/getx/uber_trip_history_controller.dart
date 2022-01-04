import 'package:get/get.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_get_user_uid_usecase.dart';
import 'package:uber_driver_app/features/uber_trips_history_feature/domain/entities/uber_trips_history_entity.dart';
import 'package:uber_driver_app/features/uber_trips_history_feature/domain/use_cases/uber_get_trip_history_usecase.dart';

class UberTripsHistoryController extends GetxController {
  final UberGetTripHistoryUsecase uberGetTripHistoryUsecase;
  final UberAuthGetUserUidUseCase uberAuthGetUserUidUseCase;

  UberTripsHistoryController(
      {required this.uberGetTripHistoryUsecase,
      required this.uberAuthGetUserUidUseCase});

  var isTripLoaded = false.obs;
  var tripsHistory = <TripHistoryEntity>[].obs;

  getTripsHistory() async {
    String driverId = await uberAuthGetUserUidUseCase.call();
    final tripsHistoryData = uberGetTripHistoryUsecase.call(driverId);
    tripsHistoryData.listen((data) {
      tripsHistory.value = data;
      isTripLoaded.value = true;
    });
  }


}
