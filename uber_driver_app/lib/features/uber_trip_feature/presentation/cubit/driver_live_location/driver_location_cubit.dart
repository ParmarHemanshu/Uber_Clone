import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_get_user_uid_usecase.dart';
import 'package:uber_driver_app/features/uber_trip_feature/data/models/driver_location/driver_model.dart';
import 'package:uber_driver_app/features/uber_trip_feature/domain/use_cases/driver_location/driver_location_usecase.dart';

part 'driver_location_state.dart';

class DriverLocationCubit extends Cubit<DriverLocationState> {
  final DriverLocationUseCase driverLocationUseCase;
  final UberAuthGetUserUidUseCase getUserUidUseCase;

  DriverLocationCubit(
      {required this.driverLocationUseCase, required this.getUserUidUseCase})
      : super(DriverLocationInitial());

  getDriverLocation() async {
    try {
      emit(DriverLocationLoading());
      final String driverId =
          await getUserUidUseCase.uberAuthRepository.uberAuthGetUserUid();
      final Stream<DriverModel> driverStream =
          driverLocationUseCase.repository.tripDriverStream(driverId);
      driverStream.listen((event) {
        emit(DriverLocationLoaded(driverModel: event));
      });
    } catch (e) {
      print(e);
      emit(DriverLocationFailureState(e.toString()));
    }
  }

  updateDriver(bool isOnline, DriverModel driverModel) async {
    final String driverId =
        await getUserUidUseCase.uberAuthRepository.uberAuthGetUserUid();
    try {
      final model = DriverModel(
          is_online: isOnline,
          driver_id: driverId,
          current_location: driverModel.current_location,
          profile_img: driverModel.profile_img);
      await driverLocationUseCase.repository.updateDriver(model);
      getDriverLocation();
     // emit(DriverLocationLoaded(driverModel: model));
    } catch (e) {
      emit(DriverLocationFailureState("update driver failure"));
    }
  }

  updateDriverSec(
      GeoPoint geoPoint, DriverModel driverModel, bool is_online) async {
    try {
      final model = DriverModel(
          is_online: is_online,
          current_location: geoPoint,
          driver_id: driverModel.driver_id,
          profile_img: driverModel.profile_img);
      await driverLocationUseCase.repository.updateDriver(model);
      getDriverLocation();
     // emit(DriverLocationLoaded(driverModel: model));
    } catch (e) {
      print("update 10 sec driver failure");
      print(e);
    }
  }
}
