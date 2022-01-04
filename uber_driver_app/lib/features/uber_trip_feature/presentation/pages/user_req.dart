import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_driver_app/features/uber_profile_feature/presentation/pages/uber_profile_page.dart';
import 'package:uber_driver_app/features/uber_trip_feature/data/models/driver_location/driver_model.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/controller/driver_location/driver_location_controller.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/available_for_ride/user_req_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/driver_live_location/driver_location_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/internet/internet_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/driver_location/functional_button.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/driver_location/is_online_widget.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/driver_location/profile_widget.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/trip_history/custom_elevated_button.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/trip_history/loading_widget.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/widgets/trip_history/message_display.dart';

import '../../../../injection_container.dart' as di;

class UserReq extends StatefulWidget {
  const UserReq({Key? key}) : super(key: key);

  @override
  _UserReqState createState() => _UserReqState();
}

class _UserReqState extends State<UserReq> {
  late final Completer<GoogleMapController> _mapController = Completer();
  static const CameraPosition _initialLocation = CameraPosition(
    target: LatLng(23.35125, 72.956),
    zoom: 17.0,
  );
  late bool is_online;
  Set<Marker> _markers = {};
  final c = Get.put(di.sl<DriverLocationController>());
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();

    BlocProvider.of<DriverLocationCubit>(context).getDriverLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetState>(
      builder: (context, state) {
        if (state is InternetConnected) {
          return Scaffold(
            bottomNavigationBar:
                BlocBuilder<DriverLocationCubit, DriverLocationState>(
              builder: (context, state) {
                if (state is DriverLocationLoaded) {
                  is_online = state.driverModel.is_online!;
                  if (state.driverModel.is_online == true) {
                    startTimer(state.driverModel);
                  } else {
                    try {
                      _timer!.cancel();
                    } catch (e) {
                      print(e);
                    }
                  }
                  return Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 11,
                            offset: Offset(3.0, 4.0))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: show,
                          child: Container(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.keyboard_arrow_up),
                          ),
                        ),
                        Text(
                            state.driverModel.is_online == true
                                ? "You're online"
                                : "You're offline",
                            style: TextStyle(
                                fontSize: 30, color: Colors.blueAccent)),
                        Container(
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.list)),
                      ],
                    ),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            resizeToAvoidBottomInset: false,
            bottomSheet: Container(
              height: 300,
              decoration: BoxDecoration(color: Colors.black),
              child: Column(),
            ),
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: _initialLocation,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  markers: _markers,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      child:
                          BlocBuilder<DriverLocationCubit, DriverLocationState>(
                        builder: (context, state) {
                          if (state is DriverLocationLoaded) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FunctionalButton(
                                  icon: Icons.search,
                                  title: "",
                                  onPressed: () {},
                                ),
                                IsOnlineWidget(
                                  online: state.driverModel.is_online == true
                                      ? "Online"
                                      : "Offline",
                                  onPressed: () {
                                    if (state.driverModel.is_online != null) {
                                      print("user is online"+state.driverModel.is_online.toString());
                                      BlocProvider.of<DriverLocationCubit>(
                                              context)
                                          .updateDriver(
                                              !state.driverModel.is_online!,
                                              state.driverModel);
                                    }else{
                                      print("user is offline"+state.driverModel.is_online.toString());
                                    }
                                  },
                                ),
                                ProfileWidget(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const UberProfilePage()));
                                  },
                                  imgUrl:
                                      state.driverModel.profile_img.toString(),
                                ),
                              ],
                            );
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          FunctionalButton(
                            icon: Icons.my_location,
                            title: "",
                            onPressed: () {
                              //   _getCurrentLocation();
                            },
                          ),
                          Container(
                            width: 50,
                            height: 50,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        } else if (state is InternetDisconnected) {
          return const MessageDisplay(
            message: 'Check Your Internet Connection.',
          );
        }
        return LoadingWidget();
      },
    );
  }

  // Method for retrieving the current location
  void _getCurrentLocation() async {
    final GoogleMapController controller = await _mapController.future;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      c.changePosition(position, controller, context);
      print('CURRENT POS: ${c.currentPosition}');
    }).catchError((e) {
      print(e);
    });
  }

  void show() {
    showModalBottomSheet(
        isScrollControlled: true,
        barrierColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        context: context,
        builder: (builder) {
          BlocProvider.of<UserReqCubit>(context).getUserReq();
          final cubit = BlocProvider.of<UserReqCubit>(context);
          return BlocProvider.value(
            value: cubit,
            child: BlocBuilder<UserReqCubit, UserReqState>(
              builder: (context, state) {
                if (state is UserReqInitial) {
                  return const MessageDisplay(
                    message: 'User Request',
                  );
                } else if (state is UserReqLoading) {
                  return LoadingWidget();
                } else if (state is UserReqLoaded) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    margin: EdgeInsets.only(top: 16),
                    child: state.tripHistoryList.isEmpty == true
                        ? const MessageDisplay(
                            message: 'No request available',
                          )
                        : ListView.builder(
                            itemCount: state.tripHistoryList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  state.tripHistoryList[index].riderModel.name
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'source: ${state.tripHistoryList[index].tripHistoryModel.source}',
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'destination: ${state.tripHistoryList[index].tripHistoryModel.destination}',
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'travelling time: ${state.tripHistoryList[index].tripHistoryModel.travellingTime}',
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                leading: Text(
                                    '${state.tripHistoryList[index].tripHistoryModel.tripAmount}\u{20B9}'),
                                trailing: CustomElevatedButton(
                                  onPressed: () {
                                    BlocProvider.of<UserReqCubit>(context)
                                        .isAccept(state.tripHistoryList[index],
                                            true, false);
                                  },
                                  text: 'ACCEPT',
                                ),
                              );
                            }),
                  );
                } else if (state is UserReqFailureState) {
                  return MessageDisplay(
                    message: state.message,
                  );
                } else if (state is UserReqDisplayOne) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 4,
                    margin: EdgeInsets.only(top: 16),
                    child: ListTile(
                      title: Text(
                        state.tripDriver.riderModel.name.toString(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'source: ${state.tripDriver.tripHistoryModel.source}',
                              overflow: TextOverflow.ellipsis),
                          Text(
                              'destination: ${state.tripDriver.tripHistoryModel.destination}',
                              overflow: TextOverflow.ellipsis),
                          Text(
                              'travelling time: ${state.tripDriver.tripHistoryModel.travellingTime}',
                              overflow: TextOverflow.ellipsis),
                          CustomElevatedButton(
                            onPressed: () {
                              // update is_arrived = true
                              if (state.tripDriver.tripHistoryModel
                                      .isCompleted ==
                                  false) {
                                BlocProvider.of<UserReqCubit>(context)
                                    .isAccept(state.tripDriver, false, false);
                              } else {
                                BlocProvider.of<UserReqCubit>(context)
                                    .isAccept(state.tripDriver, false, false);
                              }
                            },
                            text: state.tripDriver.tripHistoryModel.isArrived ==
                                    false
                                ? 'ARRIVED'
                                : state.tripDriver.tripHistoryModel
                                            .isCompleted ==
                                        true
                                    ? 'ACCEPT PAYMENT'
                                    : 'COMPLETED',
                          ),
                        ],
                      ),
                      leading: Text(
                          '${state.tripDriver.tripHistoryModel.tripAmount}\u{20B9}'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        //arrived true and completed false -> ongoing
                        child: const Text(
                          'CALL',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                        ),
                      ),
                    ),
                  );
                }
                return const MessageDisplay(
                  message: 'History',
                );
              },
            ),
          );
        });
  }

  void startTimer(DriverModel driverModel) {
    if (is_online == true) {
      _timer = Timer(const Duration(seconds: 10), () async {
        await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high)
            .then((Position position) async {
          BlocProvider.of<DriverLocationCubit>(context).updateDriverSec(
              GeoPoint(position.latitude, position.longitude),
              driverModel,
              is_online);
          print(position.latitude);
          print(position.longitude);
        }).catchError((e) {
          print(e);
        });
        _timer!.cancel();
        if (is_online == true) {
          startTimer(driverModel);
        }
      });
    } else {
      try {
        _timer!.cancel();
      } catch (e) {
        print(e);
      }
    }
  }
}
