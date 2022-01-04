import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:uber_driver_app/features/uber_auth_feature/data/models/vehicle_model.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/entities/driver_entity.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_add_profile_image_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_check_user_status_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_get_user_uid_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_is_sign_in_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_otp_verification_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/use_cases/uber_auth_phone_verification_usecase.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/pages/uber_auth_register_page.dart';
import 'package:uber_driver_app/features/uber_profile_feature/domain/use_cases/uber_profile_update_driver_usecase.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/available_for_ride/user_req_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/driver_live_location/driver_location_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/cubit/internet/internet_cubit.dart';
import 'package:uber_driver_app/features/uber_trip_feature/presentation/pages/user_req.dart';
import 'package:uber_driver_app/features/uber_trips_history_feature/presentation/pages/uber_trips_history_page.dart';
import '/injection_container.dart' as di;

class UberAuthController extends GetxController {
  final UberAuthIsSignInUseCase uberAuthIsSignInUseCase;
  final UberAuthPhoneVerificationUseCase uberAuthPhoneVerificationUseCase;
  final UberAuthOtpVerificationUseCase uberAuthOtpVerificationUseCase;
  final UberAuthCheckUserStatusUseCase uberAuthCheckUserStatusUseCase;
  final UberAuthGetUserUidUseCase uberAuthGetUserUidUseCase;
  final UberProfileUpdateDriverUsecase uberProfileUpdateDriverUsecase;
  final UberAddProfileImgUseCase uberAddProfileImgUseCase;
  var isSignIn = false.obs;
  var profileImgUrl =
      "https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png"
          .obs;

  UberAuthController(
      {required this.uberAuthIsSignInUseCase,
      required this.uberAuthPhoneVerificationUseCase,
      required this.uberAuthOtpVerificationUseCase,
      required this.uberAuthCheckUserStatusUseCase,
      required this.uberAuthGetUserUidUseCase,
      required this.uberProfileUpdateDriverUsecase,
      required this.uberAddProfileImgUseCase});

  checkIsSignIn() async {
    bool uberAuthIsSignIn = await uberAuthIsSignInUseCase.call();
    isSignIn.value = uberAuthIsSignIn;
  }

  verifyPhoneNumber(String phoneNumber) async {
    await uberAuthPhoneVerificationUseCase.call(phoneNumber);
    Get.snackbar("Verifying Number", "Please wait ..");
  }

  verifyOtp(String otp, BuildContext context) async {
    Get.snackbar("Validating Otp", "Please wait ..");
    await uberAuthOtpVerificationUseCase.call(otp).whenComplete(() async {
      String driverId = await uberAuthGetUserUidUseCase.call();
      if (driverId.isNotEmpty) {
        final userStatus = await checkUserStatus();
        if (userStatus) {
          Get.offAll(() => MultiBlocProvider(
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
            child:  const UserReq(),
          ),);
        } else {
          Get.offAll(() => const UberAuthRegistrationPage());
        }
      }
    });
  }

  Future<bool> checkUserStatus() async {
    String driverId = await uberAuthGetUserUidUseCase.call();
    return uberAuthCheckUserStatusUseCase.call(driverId);
  }

  pickProfileImg() async {
    String driverId = await uberAuthGetUserUidUseCase.call();
    String profileUrl = await uberAddProfileImgUseCase.call(driverId);
    Get.snackbar("please wait", "Uploading Image....");
    profileImgUrl.value = profileUrl;
  }

  addDriverProfile(String name, String email,String city,int vehicle_type,String company,String model,String number_plate) async {
    final vehicle=checkVehicleType(vehicle_type);
    final String driverId = await uberAuthGetUserUidUseCase.call();

 final path=  FirebaseFirestore.instance.collection(vehicle).doc(driverId);

    final driverEntity = DriverEntity(
        name: name,
        email: email,
        driver_id: driverId,
        wallet: 50.0,
        is_online: true,
        overall_rating: "2",
        current_location: GeoPoint(27.65, 26.56),
        mobile: FirebaseAuth.instance.currentUser!.phoneNumber,
        profile_img: profileImgUrl.value,
        total_trips: "0",
        vehicle: path,city: city);

    await uberProfileUpdateDriverUsecase.call(driverEntity, driverId);
    path.update(VehicleModel(comapany: company,model: model,number_plate: number_plate,color: "black").toMap());
    Get.snackbar("Welcome.", "registration successful!");
    Get.offAll(() => const TripHistory());
  }

  Future<String?> getUidOfCurrentUser() async {
    final String driverId = await uberAuthGetUserUidUseCase.call();
    if (driverId == null) {
      return null;
    }
    return driverId;
  }
}

String checkVehicleType(int vehicle_type) {
  if(vehicle_type==1){
    return "bikes";
  }
  else if(vehicle_type==2){
    return "auto";
  }
  else{
    return "cars";
  }
}
