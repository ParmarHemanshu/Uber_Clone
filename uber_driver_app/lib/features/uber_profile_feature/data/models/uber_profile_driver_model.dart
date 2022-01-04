import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber_driver_app/features/uber_auth_feature/domain/entities/driver_entity.dart';

class DriverProfileModel extends DriverEntity {
  final String? name;
  final String? email;
  final bool? is_online;
  final String? mobile;
  final String? overall_rating;
  final String? profile_img;
  final String? total_trips;
  final double? wallet;
  final DocumentReference? vehicle;
  final GeoPoint? current_location;
  final String? driver_id;

  const DriverProfileModel(
      {this.name,
      this.email,
      this.mobile,
      this.overall_rating,
      this.profile_img,
      this.total_trips,
      this.wallet,
      this.is_online,
      this.vehicle,
      this.current_location,
      this.driver_id});

  Map<String, dynamic> toDocument() {
    return {
      "name": name,
      "email": email,
      "mobile": mobile,
      "overall_rating": overall_rating,
      "profile_img": profile_img,
      "total_trips": total_trips,
      "wallet": wallet,
      "vehicle": vehicle,
      "current_location": current_location,
      "driver_id": driver_id,
      "is_online":is_online
    };
  }

  factory DriverProfileModel.fromSnapShot(DocumentSnapshot documentSnapshot) {
    return DriverProfileModel(
      name: documentSnapshot.get("name"),
      email: documentSnapshot.get("email"),
      mobile: documentSnapshot.get("mobile"),
      overall_rating: documentSnapshot.get("overall_rating"),
      profile_img: documentSnapshot.get("profile_img"),
      total_trips: documentSnapshot.get("total_trips"),
      wallet: documentSnapshot.get("wallet"),
      vehicle: documentSnapshot.get("vehicle"),
      current_location: documentSnapshot.get("current_location"),
      driver_id: documentSnapshot.get("driver_id"),
      is_online: documentSnapshot.get("is_online"),
    );
  }
}
