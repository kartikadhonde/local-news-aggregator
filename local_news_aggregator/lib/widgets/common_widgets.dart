import 'package:flutter/material.dart';

// Validation helpers
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your email';
  if (!value.contains('@')) return 'Invalid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your name';
  if (value.length < 3) return 'Name must be at least 3 characters';
  return null;
}

String? validatePasswordStrength(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Please confirm your password';
  if (value != password) return 'Passwords do not match';
  return null;
}

// Reusable text input field
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? hint,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  int? maxLength,
  String? Function(String?)? validator,
  Widget? suffixIcon,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: maxLines,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
    ),
    validator: validator,
  );
}

// Reusable loading button
Widget buildLoadingButton({
  required VoidCallback onPressed,
  required String label,
  required bool isLoading,
  IconData? icon,
}) {
  return ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          )
        : Text(label, style: const TextStyle(fontSize: 16)),
  );
}

// Show snackbar message
void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}

// Loading indicator
Widget buildLoading(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message),
      ],
    ),
  );
}

// Error display with retry
Widget buildError(String message, VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 16),
        Text(message),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

// Empty state display
Widget buildEmptyState(String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        Text(message),
      ],
    ),
  );
}
