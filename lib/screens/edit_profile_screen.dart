import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager_1/controllers/update_profile_controller.dart';
import 'package:task_manager_1/data/model/user_modal.dart';
import 'package:task_manager_1/widgets/body_background.dart';
import '../controllers/auth_controller.dart';
import '../widgets/profile_summary_card.dart';

class EditProfileScreen extends StatefulWidget {
  final user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? photoInBase64;

  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _mobileTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final EditProfileController _editProfileController =
      Get.find<EditProfileController>();

  updateProfile() async {
    Map<String, dynamic> inputData = {
      "email": _emailTEController.text.trim(),
      "firstName": _firstNameTEController.text.trim(),
      "lastName": _lastNameTEController.text.trim(),
      "mobile": _mobileTEController.text.trim(),
      "photo": ""
    };

    if (_passwordTEController.text.isNotEmpty) {
      inputData["password"] = _passwordTEController.text;
    }

    if (_editProfileController.photo != null) {
      List<int> imageBytes = await _editProfileController.photo!.readAsBytes();
      photoInBase64 = base64Encode(imageBytes);
      inputData["photo"] = photoInBase64;
    }

    var response = await _editProfileController.updateProfile(inputData);

    if (response == true) {
      await Get.find<AuthController>().updateUserInformation(UserModel(
          email: _emailTEController.text.trim(),
          firstName: _firstNameTEController.text.trim(),
          lastName: _lastNameTEController.text.trim(),
          mobile: _mobileTEController.text.trim(),
          photo: photoInBase64 ?? AuthController.user!.photo));

      Get.back();

      Get.snackbar("Update Succesful", "Profile Updated",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', '',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void initState() {
    _emailTEController.text = widget.user.email;
    _firstNameTEController.text = widget.user.firstName;
    _lastNameTEController.text = widget.user.lastName;
    _mobileTEController.text = widget.user.mobile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ProfileSummeryCard(ignoreOnTap: false),
            Expanded(
              child: BodyBackground(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Update Profile',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          photoContainer(),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _emailTEController,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _firstNameTEController,
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'First Name Required';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'First Name',
                              hintStyle: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _lastNameTEController,
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Last Name Required';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Last Name',
                              hintStyle: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _mobileTEController,
                            validator: (String? value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Mobile Required';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'Mobile',
                              hintStyle: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          TextFormField(
                            controller: _passwordTEController,
                            decoration: const InputDecoration(
                              hintText: 'Password (Optional)',
                              hintStyle: TextStyle(fontFamily: 'poppins'),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          GetBuilder<EditProfileController>(
                            builder: (controller) {
                              return Visibility(
                                visible: controller.loading == false,
                                replacement: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        updateProfile();
                                      }
                                    },
                                    child: const Icon(
                                        Icons.arrow_forward_ios_rounded)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container photoContainer() {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.white),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                height: 50,
                color: Colors.grey,
                child: const Text(
                  'Photo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w300),
                ),
              )),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                await _editProfileController.selectPhoto();
              },
              child: Container(
                color: Colors.white,
                child: GetBuilder<EditProfileController>(
                  builder: (controller) {
                    return Visibility(
                      visible: controller.photo == null,
                      replacement: Text(
                        (_editProfileController.photo?.path) ?? '',
                        style: const TextStyle(
                            fontFamily: 'poppins', fontSize: 11),
                      ),
                      child: const Center(
                        child: Text(
                          "Select a Photo",
                          style: TextStyle(fontFamily: 'poppins'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _mobileTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}
