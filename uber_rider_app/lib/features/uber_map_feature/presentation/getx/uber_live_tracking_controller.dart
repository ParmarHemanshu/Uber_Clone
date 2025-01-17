import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_rider_app/features/uber_map_feature/domain/entities/uber_map_direction_entity.dart';
import 'package:uber_rider_app/features/uber_map_feature/domain/use_cases/uber_map_direction_usecase.dart';

class UberLiveTrackingController extends GetxController {
  var liveLocLatitude = 0.0.obs;
  var liveLocLongitude = 0.0.obs;
  var destinationLat = 0.0.obs;
  var destinationLng = 0.0.obs;
  var vehicleTypeName = ''.obs;

  final UberMapDirectionUsecase uberMapDirectionUsecase;
  var uberMapDirectionData = <UberMapDirectionEntity>[].obs;
  var isLoading = true.obs;
  var markers = <Marker>[].obs;

  var polylineCoordinates = <LatLng>[].obs;
  PolylinePoints polylinePoints = PolylinePoints();

  final Completer<GoogleMapController> controller = Completer();

  UberLiveTrackingController({required this.uberMapDirectionUsecase});

  getDirectionData(double destinationLatitude, double destinationLongitude,
      String vehicleType) async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    liveLocLatitude.value = position.latitude;
    liveLocLongitude.value = position.longitude;
    destinationLat.value = destinationLatitude;
    destinationLng.value = destinationLongitude;
    vehicleTypeName.value = vehicleType;
    final directionData = await uberMapDirectionUsecase.call(position.latitude,
        position.longitude, destinationLatitude, destinationLongitude);
    uberMapDirectionData.value = directionData;
    isLoading.value = false;
    addMarkers(
        BitmapDescriptor.fromBytes(await getBytesFromAsset(
            vehicleTypeName.value == "cars"
                ? 'assets/car.png'
                : vehicleTypeName.value == "bikes"
                    ? 'assets/bike.png'
                    : 'assets/auto.png',
            85)),
        "live_marker",
        liveLocLatitude.value,
        liveLocLongitude.value);
    addMarkers(BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        "destination_marker", destinationLat.value, destinationLng.value);
    addMarkers(
        BitmapDescriptor.fromBytes(await getBytesFromCanvas(200, 100)),
        "text_marker",
        (liveLocLatitude.value + 0.000300),
        liveLocLongitude.value);
    addPolyLine();
  }

  addPolyLine() async {
    List<PointLatLng> result = polylinePoints
        .decodePolyline(uberMapDirectionData[0].enCodedPoints.toString());
    polylineCoordinates.clear();
    result.forEach((PointLatLng point) {
      polylineCoordinates.value.add(LatLng(point.latitude, point.longitude));
    });
    final GoogleMapController _controller = await controller.future;
    CameraPosition liveLoc = CameraPosition(
      target: LatLng(liveLocLatitude.value, liveLocLongitude.value),
      zoom: 16,
    );
    _controller.animateCamera(CameraUpdate.newCameraPosition(liveLoc));
  }

  addMarkers(icon, String markerId, double lat, double lng) async {
    Marker marker = Marker(
        icon: icon, markerId: MarkerId(markerId), position: LatLng(lat, lng));
    markers.add(marker);
  }

  Future<Uint8List> getBytesFromCanvas(int width, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.transparent;
    const Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = const TextSpan(
      text: 'You are Here ->',
      style: TextStyle(
          fontSize: 25.0, color: Colors.black, fontWeight: FontWeight.w700),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
