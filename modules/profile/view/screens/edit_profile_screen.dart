import 'dart:io';
import 'package:adgo_mobile/services/providers/user_provider.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:adgo_mobile/validation/providers/bio_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/email_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/name_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/phone_validation_provider.dart';
import 'package:adgo_mobile/widgets/CustomAddressWidget.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _addressLine3Controller = TextEditingController();

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _addressLine3Controller.dispose();
    super.dispose();
  }
  
  bool _validateFields() {
    // Only validate fields that have content (selective validation)
    
    if (_nameController.text.trim().isNotEmpty) {
      final nameValidation = ref.read(nameValidationProvider);
      if (!nameValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(nameValidation.error ?? 'Invalid name')),
        );
        return false;
      }
    }

    if (_emailController.text.trim().isNotEmpty) {
      final emailValidation = ref.read(emailValidationProvider);
      if (!emailValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(emailValidation.error ?? 'Invalid email')),
        );
        return false;
      }
    }

    if (_phoneController.text.trim().isNotEmpty) {
      final phoneValidation = ref.read(phoneValidationProvider);
      if (!phoneValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phoneValidation.error ?? 'Invalid phone number')),
        );
        return false;
      }
    }

    // Check if at least one field has content or profile image is selected
    bool hasContent = _nameController.text.trim().isNotEmpty ||
                      _emailController.text.trim().isNotEmpty ||
                      _phoneController.text.trim().isNotEmpty ||
                      _addressLine1Controller.text.trim().isNotEmpty ||
                      _addressLine2Controller.text.trim().isNotEmpty ||
                      _addressLine3Controller.text.trim().isNotEmpty ||
                      _profileImage != null;

    if (!hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one field to update')),
      );
      return false;
    }

    return true;
  }

  void _saveProfile() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }


      final repo = ref.read(userRepoProvider);
      String? updatedProfilePictureKey;

      // Upload profile image ONLY if user selected a new one
      if (_profileImage != null) {
        try {
          final profilePicName = _profileImage!.path.split('/').last;

          // Get upload URL
          final uploadProfPicResponse = await repo.getProfilePicUploadUrl(
              userId: userId, profilePicName: profilePicName);

          final uploadUrl = uploadProfPicResponse.data['uploadUrl'];
          final profileKey = uploadProfPicResponse.data['profilePicKey'];

          // Prepare file for upload
          List<int> imageBytes = await _profileImage!.readAsBytes();
          var request = http.Request('PUT', Uri.parse(uploadUrl));

          // Set proper content type for images
          request.headers['Content-Type'] = 'image/jpeg';
          request.bodyBytes = imageBytes;

          // Upload to S3
          var response = await request.send();

          if (response.statusCode == 200) {
            updatedProfilePictureKey = profileKey;
            
            // Save profile picture key to SharedPreferences
            await prefs.setString('profilePictureOBjectKey', profileKey);
          } else {
            throw Exception('Failed to upload image to S3');
          }
        } catch (uploadError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $uploadError')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Determine which fields to update based on user input
      String? nameToUpdate = _nameController.text.trim().isNotEmpty 
          ? _nameController.text.trim() : null;
          
      String? emailToUpdate = _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() : null;
          
      String? addressToUpdate;
      if (_addressLine1Controller.text.trim().isNotEmpty ||
          _addressLine2Controller.text.trim().isNotEmpty ||
          _addressLine3Controller.text.trim().isNotEmpty) {
        addressToUpdate = [
          _addressLine1Controller.text.trim(),
          _addressLine2Controller.text.trim(),
          _addressLine3Controller.text.trim(),
        ].where((line) => line.isNotEmpty).join(', ');
      }

      // Call updateUser with selective parameters
      final response = await repo.updateUser(
        userId: userId,
        userName: nameToUpdate,
        email: emailToUpdate,
        shopId: addressToUpdate, // Using shopId field for address storage
        dob: null, // Don't update DOB unless specifically provided
        gender: null, // Don't update gender unless specifically provided
        profilePictureOBjectKey: updatedProfilePictureKey,
        state: null, // Don't change state unless specifically needed
      );

      if (!mounted) return;

      final success = response.statusCode == 200;

      // Build success message showing what was updated
      if (success) {
        List<String> updatedFields = [];
        if (nameToUpdate != null) updatedFields.add('Name');
        if (emailToUpdate != null) updatedFields.add('Email');
        if (addressToUpdate != null) updatedFields.add('Address');
        if (updatedProfilePictureKey != null) updatedFields.add('Profile Picture');
        
        String message = updatedFields.isNotEmpty 
            ? "${updatedFields.join(', ')} updated successfully"
            : "Profile updated successfully";
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }

      if (success) {
        Navigator.of(context).pop(true); // Return true to indicate successful update
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void pickProfilePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // prevent full-resolution image
      maxHeight: 800,
      imageQuality: 85, // compress JPEG
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _profileImage = imageFile;
      });
    } else {
      setState(() {
        _profileImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile',
            style: TextStyle(
              color: primaryDarkColor,
            )),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: primaryLightColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        
                        // Profile Photo
                        const SizedBox(height: 12),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                      child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                  ))),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: pickProfilePhoto,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryLightColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: whiteColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: pickProfilePhoto,
                          child: Text(
                            'Change Profile Photo',
                            style: TextStyle(
                              color: primaryLightColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Form Fields
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Full Name',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          icon: Icons.person,
                          hintText: "Full Name",
                          controller: _nameController,
                          validationProvider: nameValidationProvider,
                          onChanged: (value) {
                            ref.read(nameProvider.notifier).state = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name cannot be empty';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Email Address',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          icon: Icons.email,
                          hintText: "myemail@example.com",
                          controller: _emailController,
                          validationProvider: emailValidationProvider,
                          onChanged: (value) {
                            ref.read(emailProvider.notifier).state = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email cannot be empty';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Phone Number',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                          hintText: "555-123-4567",
                          controller: _phoneController,
                          validationProvider: phoneValidationProvider,
                          maxLength: 13,
                          onChanged: (value) {
                            ref.read(phoneProvider.notifier).state = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number cannot be empty';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Address',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        ),
                        const SizedBox(height: 12),

                        CustomAddressWidget(
                          addressLine1Controller: _addressLine1Controller,
                          addressLine2Controller: _addressLine2Controller,
                          addressLine3Controller: _addressLine3Controller,
                          label: null,
                          isRequired: true,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Bio',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: "Tell us about yourself",
                          controller: _bioController,
                          maxLines: 3,
                          onChanged: (value) {
                            ref.read(bioProvider.notifier).state = value;
                          },
                          validator: (value) {
                            return null; // Bio is optional
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _saveProfile,
          elevation: 0,
          backgroundColor: primaryLightColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          label: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Save Profile',
              style: TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}