import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/pages/uber_splash_screen.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/driver_live_location/driver_location_cubit.dart';

import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/available_for_ride/user_req_cubit.dart';
import 'features/uber_trip_feature/presentation/cubit/internet/internet_cubit.dart';

import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Uber Driver',
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<DriverLocationCubit>(
            create: (BuildContext context) => di.sl<DriverLocationCubit>(),
          ),
          BlocProvider<InternetCubit>(
            create: (BuildContext context) => di.sl<InternetCubit>(),
          ),

          BlocProvider<UserReqCubit>(
            create: (BuildContext context) => di.sl<UserReqCubit>(),
          ),

        ],
        child: const UberSplashScreen(),
      ),

    );
  }

}