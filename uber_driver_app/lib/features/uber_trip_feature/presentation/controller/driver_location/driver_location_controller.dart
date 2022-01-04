


import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_driver_app/features/uber_trip_feature/domain/use_cases/driver_location/driver_location_usecase.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/driver_live_location/driver_location_cubit.dart';
import 'package:uber_driver_app/injection_container.dart';

class DriverLocationController extends GetxController  {
final DriverLocationUseCase driverLocationUseCase;


DriverLocationController({required this.driverLocationUseCase});

RxDouble pickupPointLatitude = 0.0.obs;
  RxDouble pickupPointLatitudeLongitude = 0.0.obs;

  RxDouble driverCurrentLatitude = 0.0.obs;
  RxDouble driverCurrentLongitude = 0.0.obs;
  // polyline
  var polylineCoordinates = <LatLng>[].obs;
  PolylinePoints polylinePoints = PolylinePoints();
  var isPoliLineDraw = false.obs;
  var markers = <Marker>[].obs;
  late Position currentPosition;

  changePosition(Position position, GoogleMapController controller, BuildContext context){
    currentPosition = position;
   // BlocProvider.of<DriverLocationCubit>(context).updateDriver(isOnline);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
        ),
      ),
    );
  }

//   getRiderPickUpPoint(){
//     // driverLocationUseCase.call(sl());
//   addMarkers();
//   drawPolyLine();
// animateCameraPolyline();
//   }
//   addMarkers(double latitude, double longitude, String markerId, icon) {
//     Marker marker = Marker(
//         icon: icon,
//         markerId: MarkerId(markerId),
//         position: LatLng(latitude, longitude));
//
//     markers.add(marker);
//   }
//
// drawPolyLine() async {
//   List<PointLatLng> result = polylinePoints
//       .decodePolyline();
//   polylineCoordinates.clear();
//   result.forEach((PointLatLng point) {
//     polylineCoordinates.value.add(LatLng(point.latitude, point.longitude));
//   });
//   isPoliLineDraw.value = true;
// }
// animateCameraPolyline() async {
//   final GoogleMapController _controller = await controller.future;
//   _controller.animateCamera(CameraUpdate.newLatLngBounds(
//       LatLngBounds(
//           southwest: LatLng(sourceLatitude.value, sourceLongitude.value),
//           northeast:
//           LatLng(destinationLatitude.value, destinationLongitude.value)),
//       25));
// }

}