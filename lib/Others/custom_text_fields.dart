import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final IconData? icon;
  final bool editable; // New
  final VoidCallback? onEdit; // New
  final FocusNode? focusNode; // Add this line

  const CustomTextField({
    super.key,
    required this.labelText,
    this.icon, // Include it in the constructor
    this.validator,
    this.onSaved,
    this.keyboardType = TextInputType.text,
    this.editable = true, // Default to true
    this.controller,
    this.onEdit,
    this.focusNode, // Add this line

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: onEdit != null ? IconButton(icon: const Icon(Icons.edit), onPressed: onEdit) : null, // New
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          prefixIcon: icon != null ? Icon(icon) : null, // Use the icon if provided
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        readOnly: !editable, // Use the editable flag
        focusNode: focusNode, // Use the focusNode here
      ),
    );
  }
}
class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownButtonFormField({
    super.key,
    this.value,
    required this.labelText,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = Colors.deepPurple, // Default color, adjust as needed
    this.textColor = Colors.white, // Default text color, adjust as needed
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor, backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Text(text),
    );
  }
}

