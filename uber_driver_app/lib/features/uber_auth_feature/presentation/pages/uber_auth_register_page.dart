import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/getx/auth_controller.dart';
import 'package:uber_driver_app/features/uber_auth_feature/presentation/widgets/uber_auth_register_textfield_widget.dart';

class UberAuthRegistrationPage extends StatefulWidget {
  const UberAuthRegistrationPage({Key? key}) : super(key: key);

  @override
  _UberAuthRegistrationPageState createState() =>
      _UberAuthRegistrationPageState();
}

class _UberAuthRegistrationPageState extends State<UberAuthRegistrationPage> {
  int selected_vehicle=1;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();

  final UberAuthController _uberAuthController = Get.find();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    companyController.dispose();
    modelController.dispose();
    numberPlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage:
                          NetworkImage(_uberAuthController.profileImgUrl.value),
                      //FileImage(_profileImage!),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            _uberAuthController.pickProfileImg();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ))
                  ],
                ),
                buildStaticRegisterPageBody(
                    nameController, emailController,cityController,companyController,modelController,numberPlateController),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: 1,
                          groupValue: selected_vehicle,
                          onChanged: (value) {
                            setState(() {
                           selected_vehicle=1;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Image.asset("assets/bike.png",scale: 8,)
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 2,
                          groupValue: selected_vehicle,
                          onChanged: (value) {
                            setState(() {
                            selected_vehicle=2;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Image.asset("assets/auto.png",scale: 5,)
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 3,
                          groupValue: selected_vehicle,
                          onChanged: (value) {
                            setState(() {
                              selected_vehicle=3;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                          Image.asset("assets/car.png",scale: 22,)
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          emailController.text.isNotEmpty &&
                          GetUtils.isEmail(emailController.text)) {
                        print("profile uploaded");
                        _uberAuthController.addDriverProfile(
                          nameController.text,
                          emailController.text,
                          cityController.text.trim(),
                          selected_vehicle,
                          companyController.text.trim(),
                          modelController.text.trim(),
                          numberPlateController.text.trim()
                        );
                      } else {
                        Get.snackbar("error", "invalid values!");
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildStaticRegisterPageBody(TextEditingController name,
    TextEditingController email,TextEditingController city,TextEditingController company,TextEditingController model,TextEditingController number_plate) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(10.0),
        child: const Text(
          "Let's start with creating your account",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
        ),
      ),
      TextFieldWidget(
        labelText: 'Full Name*',
        textType: 'Enter your name',
        inputType: TextInputType.text,
        controller: name,
      ),
      //Spacer(),
      const SizedBox(
        height: 10,
      ),
      TextFieldWidget(
        labelText: 'Email Address',
        textType: 'Enter your email',
        inputType: TextInputType.emailAddress,
        controller: email,
      ),
      const SizedBox(
        height: 10,
      ),
      TextFieldWidget(
        labelText: 'City*',
        textType: 'Enter your current city',
        inputType: TextInputType.text,
        controller: city,
      ),
      const SizedBox(
        height: 10,
      ),
      TextFieldWidget(
        labelText: 'Vehicle Company*',
        textType: 'Enter Company name',
        inputType: TextInputType.text,
        controller: company,
      ),
      const SizedBox(
        height: 10,
      ),
      TextFieldWidget(
        labelText: 'Vehicle Model*',
        textType: 'Enter your vehicle model name',
        inputType: TextInputType.text,
        controller: model,
      ),
      const SizedBox(
        height: 10,
      ),
      TextFieldWidget(
        labelText: 'Number Plate*',
        textType: 'Enter your vehicle Number plate',
        inputType: TextInputType.text,
        controller: number_plate
        ,
      ),
      const SizedBox(
        height: 20,
      ),

    ],
  );
}
