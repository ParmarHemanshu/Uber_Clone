import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/getx/auth_controller.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/pages/uber_auth_register_page.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/pages/uber_auth_welcome_page.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/available_for_ride/user_req_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/driver_live_location/driver_location_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/internet/internet_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/pages/user_req.dart';

import '/injection_container.dart' as di;

class UberSplashScreen extends StatefulWidget {
  const UberSplashScreen({Key? key}) : super(key: key);

  @override
  _UberSplashScreenState createState() => _UberSplashScreenState();
}

class _UberSplashScreenState extends State<UberSplashScreen> {
  final UberAuthController _uberAuthController =
      Get.put(di.sl<UberAuthController>());

  @override
  void initState() {
    _uberAuthController.checkIsSignIn();
    Timer(const Duration(seconds: 3), () async {
      if (_uberAuthController.isSignIn.value) {
        if (await _uberAuthController.checkUserStatus()) {
          //BlocProvider.value(value: BlocProvider.of<InternetCubit>(context),child: UserReq(),
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                        value: BlocProvider.of<DriverLocationCubit>(context),
                        child: BlocProvider.value(
                            value: BlocProvider.of<InternetCubit>(context),
                            child: BlocProvider.value(
                                value: BlocProvider.of<UserReqCubit>(context),
                                child: const UserReq())),
                      )));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UberAuthRegistrationPage(),
              ));
        }
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UberAuthWelcomeScreen(),
            ));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Uber",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 48),
          ),
        ],
      )),
    );
  }
}
