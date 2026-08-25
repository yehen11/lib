import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/social.dart';
import 'package:adgo_mobile/modules/shop/view/screens/preview_screen.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:adgo_mobile/validation/providers/address_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/email_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/hours_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/phone_validation_provider.dart';
import 'package:adgo_mobile/widgets/CustomAddressWidget.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactInformationScreen extends ConsumerStatefulWidget {
  const ContactInformationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactInformationScreen> createState() =>
      _ContactInformationScreenState();
}

class _ContactInformationScreenState extends ConsumerState<ContactInformationScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _addressLine3Controller = TextEditingController();


  bool _isLoading = false;

  bool get isEditMode {
    final form = ref.read(shopFormProvider);
    return form.shopId != null && form.shopId!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Load any existing data from the provider when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void save() async {
    if (!_validateFields()) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      final shopForm = ref.read(shopFormProvider.notifier);
      shopForm.updateEmail(_emailController.text);
      shopForm.updatePhone(_phoneController.text);

      // Save address and business hours to SharedPreferences
      await _saveContactDraft();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ReviewPublishScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error saving contact info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadExistingData() {
    final shopForm = ref.read(shopFormProvider);

    // Load existing contact data into text controllers AND update validators
    if (shopForm.email != null && shopForm.email!.isNotEmpty) {
      _emailController.text = shopForm.email!;
      // Update the state provider so validation works
      ref.read(emailProvider.notifier).state = shopForm.email!;
    }
    if (shopForm.phone != null && shopForm.phone!.isNotEmpty) {
      _phoneController.text = shopForm.phone!;
      // Update the state provider so validation works
      ref.read(phoneProvider.notifier).state = shopForm.phone!;
    }

    // Load draft address and business hours
    _loadDraftAddressAndBusinessHours();
  }

  Future<void> _loadDraftAddressAndBusinessHours() async {
    final prefs = await SharedPreferences.getInstance();

    // Load address lines
    final addressLine1 = prefs.getString('draft_address_line1') ?? '';
    final addressLine2 = prefs.getString('draft_address_line2') ?? '';
    final addressLine3 = prefs.getString('draft_address_line3') ?? '';

    if (addressLine1.isNotEmpty) {
      _addressLine1Controller.text = addressLine1;
      ref.read(addressLine1Provider.notifier).state = addressLine1;
    }
    if (addressLine2.isNotEmpty) {
      _addressLine2Controller.text = addressLine2;
      ref.read(addressLine2Provider.notifier).state = addressLine2;
    }
    if (addressLine3.isNotEmpty) {
      _addressLine3Controller.text = addressLine3;
      ref.read(addressLine3Provider.notifier).state = addressLine3;
    }

    // Load business hours selection details
    final selectedDaysString = prefs.getString('draft_selected_days') ?? '';
    final openTimeMinutes = prefs.getInt('draft_open_time_minutes');
    final closeTimeMinutes = prefs.getInt('draft_close_time_minutes');

    if (selectedDaysString.isNotEmpty &&
        openTimeMinutes != null &&
        closeTimeMinutes != null) {
      // Restore selected days
      final selectedDaysList = selectedDaysString.split(',');
      setState(() {
        // Reset all days to false first
        selectedDays = {
          'Monday': false,
          'Tuesday': false,
          'Wednesday': false,
          'Thursday': false,
          'Friday': false,
          'Saturday': false,
          'Sunday': false,
        };

        // Set selected days to true
        for (String day in selectedDaysList) {
          if (selectedDays.containsKey(day)) {
            selectedDays[day] = true;
          }
        }

        // Restore open and close times
        openTime = TimeOfDay(
          hour: openTimeMinutes ~/ 60,
          minute: openTimeMinutes % 60,
        );
        closeTime = TimeOfDay(
          hour: closeTimeMinutes ~/ 60,
          minute: closeTimeMinutes % 60,
        );
      });

      // Update business hours provider with formatted string
      String businessHours = _formatBusinessHours();
      ref.read(hoursProvider.notifier).state = businessHours;
    }

    // Show success message if any data was loaded
    if (addressLine1.isNotEmpty ||
        addressLine2.isNotEmpty ||
        addressLine3.isNotEmpty ||
        selectedDaysString.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Draft contact details and business hours loaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Business hours data
  Map<String, bool> selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  TimeOfDay openTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay closeTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _addressLine3Controller.dispose();
    super.dispose();
  }
  
  bool _validateFields() {
    final emailValidation = ref.read(emailValidationProvider);
    final phoneValidation = ref.read(phoneValidationProvider);
    final addressValidation = ref.read(addressValidationProvider);

    if (!emailValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(emailValidation.error ?? 'Invalid email')),
      );
      return false;
    }

    if (!phoneValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(phoneValidation.error ?? 'Invalid phone number')),
      );
      return false;
    }

    // if (!addressValidation.isValid) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //         content:
    //             Text(addressValidation.error ?? 'Invalid address')),
    //   );
    // }

    // Validate business hours
    // bool hasSelectedDays = selectedDays.values.any((isSelected) => isSelected);
    // if (!hasSelectedDays) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //         content: Text('Please select at least one business day')),
    //   );
    //   return false;
    // }

    return true;
  }

  String _formatBusinessHours() {
    List<String> activeDays = selectedDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.substring(0, 3))
        .toList();
    
    String daysStr = activeDays.join(', ');
    String openStr = openTime.format(context);
    String closeStr = closeTime.format(context);
    
    return '$daysStr: $openStr - $closeStr';
  }

  Future<void> _saveContactDraft() async {
    final prefs = await SharedPreferences.getInstance();

    // Save address lines
    await prefs.setString('draft_address_line1', _addressLine1Controller.text);
    await prefs.setString('draft_address_line2', _addressLine2Controller.text);
    await prefs.setString('draft_address_line3', _addressLine3Controller.text);

    // Save business hours formatted string (current formatted value)
    final currentBusinessHours = ref.read(hoursProvider);
    await prefs.setString('draft_business_hours', currentBusinessHours);

    // Save detailed business hours selection for proper restoration
    // Save selected days as JSON string
    final selectedDaysJson = selectedDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .join(',');
    await prefs.setString('draft_selected_days', selectedDaysJson);

    // Save open and close times as minutes since midnight
    await prefs.setInt(
        'draft_open_time_minutes', openTime.hour * 60 + openTime.minute);
    await prefs.setInt(
        'draft_close_time_minutes', closeTime.hour * 60 + closeTime.minute);
  }

  void _processNextStep() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Basic contact information saved successfully')),
        );


        final shopForm = ref.read(shopFormProvider.notifier);
        shopForm.updateEmail(_emailController.text);
        shopForm.updatePhone(_phoneController.text);
        
        // Update business hours with formatted string
        String businessHours = _formatBusinessHours();
        ref.read(hoursProvider.notifier).state = businessHours;

        // Save draft before navigating
        await _saveContactDraft();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SocialMediaScreen(),
          ),
        );
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

  Future<void> _selectTime(bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? openTime : closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          openTime = picked;
        } else {
          closeTime = picked;
        }
      });
    }
  }

  Widget _buildBusinessHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Business Hours',
            style: TextStyle(fontSize: 14, color: primaryDarkColor)),
        const SizedBox(height: 12),
        
        // Days selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Business Days',
                  style: TextStyle(fontSize: 12, color: primaryDarkColor.withAlpha((0.7 * 255).toInt()))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedDays.keys.map((day) {
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: selectedDays[day]!,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedDays[day] = selected;
                      });
                    },
                    selectedColor: primaryLightColor.withAlpha((0.3 * 255).toInt()),
                    checkmarkColor: primaryDarkColor,
                    labelStyle: TextStyle(
                      color: selectedDays[day]! ? primaryDarkColor : primaryDarkColor.withAlpha((0.6 * 255).toInt()),
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Time selectors
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Open Time',
                            style: TextStyle(fontSize: 12, color: primaryDarkColor.withAlpha((0.7 * 255).toInt()))),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectTime(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 20, color: primaryDarkColor.withAlpha((0.6 * 255).toInt())),
                                const SizedBox(width: 8),
                                Text(
                                  openTime.format(context),
                                  style: TextStyle(fontSize: 14, color: primaryDarkColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Close Time',
                            style: TextStyle(fontSize: 12, color: primaryDarkColor.withAlpha((0.7 * 255).toInt()))),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _selectTime(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 20, color: primaryDarkColor.withAlpha((0.6 * 255).toInt())),
                                const SizedBox(width: 8),
                                Text(
                                  closeTime.format(context),
                                  style: TextStyle(fontSize: 14, color: primaryDarkColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Preview of selected hours
              if (selectedDays.values.any((isSelected) => isSelected)) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryLightColor.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Preview: ${_formatBusinessHours()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryDarkColor.withAlpha((0.8 * 255).toInt()),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        leading: Icon(Icons.arrow_back, color: primaryDarkColor),
        title: Text('Contact Information',
            style: TextStyle(
              color: primaryDarkColor,
            )),
      ),
      body: Stack(
        children :[Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email Address',
                          style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                      CustomTextField(icon: Icons.email, hintText: "myemail@example.com",
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
        
                      const SizedBox(height: 32),
        
                      Text('Phone Number',
                          style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        keyboardType:TextInputType.phone,
                        icon: Icons.phone, hintText: "555-123-4567",
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
        
                      const SizedBox(height: 32),
        
                      const SizedBox(height: 12),
                      Text('Address',
                            style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomAddressWidget(
                          addressLine1Controller: _addressLine1Controller,
                          addressLine2Controller: _addressLine2Controller,
                          addressLine3Controller: _addressLine3Controller,
                          label: null,
                          isRequired: true,
                        ),
        
                      const SizedBox(height: 32),
                      _buildBusinessHoursSelector(),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 14),
        
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 3 / 6,
                  backgroundColor: primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: Text('Step 3 of 6',
                    style: TextStyle(fontSize: 14, color: primaryDarkColor.withAlpha((0.3 * 255).toInt()))),
              ),
              const SizedBox(height: 14),
        
              isEditMode
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : save,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryLightColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: whiteColor,
                              side: BorderSide(
                                  color: primaryDarkColor
                                      .withAlpha((0.3 * 255).toInt())),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                  color: primaryDarkColor, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _processNextStep,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryLightColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
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
        ]
      ),
    );
  }
}
