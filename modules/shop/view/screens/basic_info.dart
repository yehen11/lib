import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/branding.dart';
import 'package:adgo_mobile/modules/shop/view/screens/preview_screen.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:adgo_mobile/validation/providers/description_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/validation/providers/shopName_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/shopHandle_validation_provider.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';

class BasicShopInfoScreen extends ConsumerStatefulWidget {
  const BasicShopInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BasicShopInfoScreen> createState() =>
      _BasicShopInfoScreenState();
}

class _BasicShopInfoScreenState extends ConsumerState<BasicShopInfoScreen> {
  final _shopNameController = TextEditingController();
  final _shopHandleController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  String? _selectedCategory;
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
      shopForm.updateName(_shopNameController.text);
      shopForm.updateHandle(_shopHandleController.text);
      shopForm.updateDescription(_shopDescriptionController.text);
      shopForm.updateCategory(_selectedCategory!);

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
      print("Error saving shop info: $e");
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

    // Load existing data into text controllers AND update validators
    if (shopForm.name != null && shopForm.name!.isNotEmpty) {
      _shopNameController.text = shopForm.name!;
      // Update the state provider so validation works
      ref.read(shopNameProvider.notifier).state = shopForm.name!;
    }
    if (shopForm.handle != null && shopForm.handle!.isNotEmpty) {
      _shopHandleController.text = shopForm.handle!;
      // Update the state provider so validation works
      ref.read(shopHandleProvider.notifier).state = shopForm.handle!;
    }
    if (shopForm.description != null && shopForm.description!.isNotEmpty) {
      _shopDescriptionController.text = shopForm.description!;
      // Update the state provider so validation works
      ref.read(descriptionProvider.notifier).state = shopForm.description!;
    }
    if (shopForm.category != null && shopForm.category!.isNotEmpty) {
      setState(() {
        _selectedCategory = shopForm.category;
      });
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopHandleController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  // Validate the form fields using the validation providers
  bool _validateFields() {
    final shopNameValidation = ref.read(shopNameValidationProvider);
    final shopHandleValidation = ref.read(shopHandleValidationProvider);
    final descriptionValidation = ref.read(descriptionValidationProvider);

    // Check shop name validation
    if (!shopNameValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(shopNameValidation.error ?? 'Invalid shop name')),
      );
      return false;
    }

    // Check shop handle validation
    if (!shopHandleValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(shopHandleValidation.error ?? 'Invalid shop handle')),
      );
      return false;
    }

    // Check description validation
    if (!descriptionValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(descriptionValidation.error ?? 'Invalid description')),
      );
      return false;
    }

    // Check if category is selected
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business category')),
      );
      return false;
    }

    return true;
  }

  // Process next step
  void _processNextStep() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Basic shop information saved successfully')),
        );



        final shopForm = ref.read(shopFormProvider.notifier);
        shopForm.updateName(_shopNameController.text);
        shopForm.updateHandle(_shopHandleController.text);
        shopForm.updateDescription(_shopDescriptionController.text);
        shopForm.updateCategory(_selectedCategory!);


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShopBrandingScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Basic Info',
            style: TextStyle(
              color: primaryDarkColor,
            )),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shop Name',
                            style: TextStyle(
                                fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _shopNameController,
                          onChanged: (value) {
                            ref.read(shopNameProvider.notifier).state = value;
                          },
                          validationProvider: shopNameValidationProvider,
                          icon: Icons.store,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your shop name';
                            }
                            return null;
                          },
                          hintText: 'Enter shop name',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 32),
                        Text('Shop Handle/URL',
                            style: TextStyle(
                                fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _shopHandleController,
                          onChanged: (value) {
                            ref.read(shopHandleProvider.notifier).state = value;
                          },
                          validationProvider: shopHandleValidationProvider,
                          icon: Icons.alternate_email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your shop handle';
                            }
                            return null;
                          },
                          hintText: 'Enter shop handle',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 32),
                        Text('Shop Description',
                            style: TextStyle(
                                fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _shopDescriptionController,
                          onChanged: (value) {
                            ref.read(descriptionProvider.notifier).state =
                                value;
                          },
                          validationProvider: descriptionValidationProvider,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your shop description';
                            }
                            return null;
                          },
                          hintText: 'Enter description',
                          maxLines: 4,
                          
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("min 10, max 500 characters",
                              style: TextStyle(
                                color: primaryDarkColor
                                    .withAlpha((0.3 * 255).toInt()),
                                fontSize: 12,
                              )),
                        ),
                        const SizedBox(height: 32),
                        Text('Business Category',
                            style: TextStyle(
                                fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryLightColor
                                .withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              hintText: 'Select category',
                              hintStyle: TextStyle(
                                  color: primaryDarkColor
                                      .withAlpha((0.3 * 255).toInt())),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.arrow_drop_down),
                            elevation: 16,
                            style: TextStyle(color: primaryDarkColor),
                            items: const [
                              DropdownMenuItem(
                                value: 'clothing',
                                child: Text('Clothing & Accessories'),
                              ),
                              DropdownMenuItem(
                                value: 'electronics',
                                child: Text('Electronics'),
                              ),
                              DropdownMenuItem(
                                value: 'food',
                                child: Text('Food & Beverages'),
                              ),
                              DropdownMenuItem(
                                value: 'home',
                                child: Text('Home & Garden'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1 / 6,
                    backgroundColor:
                        primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(primaryLightColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text('Step 1 of 6',
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              primaryDarkColor.withAlpha((0.3 * 255).toInt()))),
                ),
                const SizedBox(height: 14),

                // Buttons
                isEditMode? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : save,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: primaryLightColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                :Row(
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
                          style:
                              TextStyle(color: primaryDarkColor, fontSize: 16),
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
                            fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
