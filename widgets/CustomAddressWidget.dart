import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:adgo_mobile/validation/providers/address_validation_provider.dart';

class CustomAddressWidget extends ConsumerWidget {
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController addressLine3Controller;
  final String? label;
  final bool isRequired;

  const CustomAddressWidget({
    Key? key,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.addressLine3Controller,
    this.label = 'Address',
    this.isRequired = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        if (label != null) const SizedBox(height: 12),
        
        // Address Line 1 (Required)
        CustomTextField(
          controller: addressLine1Controller,
          onChanged: (value) {
            ref.read(addressLine1Provider.notifier).state = value;
          },
          validationProvider: addressLine1ValidationProvider,
          icon: Icons.location_on,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Address Line 1 is required';
            }
            if (value != null && value.trim().isNotEmpty) {
              final trimmed = value.trim();
              if (trimmed.length > 100) {
                return 'Must be 100 characters or less';
              }
              if (trimmed.length < 2) {
                return 'Must be at least 2 characters';
              }
            }
            return null;
          },
          hintText: 'Address Line 1',
          keyboardType: TextInputType.multiline,
        ),
        
        const SizedBox(height: 12),
        
        // Address Line 2 (Optional)
        CustomTextField(
          controller: addressLine2Controller,
          onChanged: (value) {
            ref.read(addressLine2Provider.notifier).state = value;
          },
          validationProvider: addressLine2ValidationProvider,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final trimmed = value.trim();
            if (trimmed.length > 100) {
              return 'Must be 100 characters or less';
            }
            if (trimmed.length < 2) {
              return 'Must be at least 2 characters if provided';
            }
            return null;
          },
          hintText: 'Address Line 2',
          keyboardType: TextInputType.multiline,
        ),

        const SizedBox(height: 12),
        
        // Address Line 3 (Optional)
        CustomTextField(
          controller: addressLine3Controller,
          onChanged: (value) {
            ref.read(addressLine3Provider.notifier).state = value;
          },
          validationProvider: addressLine3ValidationProvider,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final trimmed = value.trim();
            if (trimmed.length > 100) {
              return 'Must be 100 characters or less';
            }
            if (trimmed.length < 2) {
              return 'Must be at least 2 characters if provided';
            }
            return null;
          },
          hintText: 'Address Line 3',
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}