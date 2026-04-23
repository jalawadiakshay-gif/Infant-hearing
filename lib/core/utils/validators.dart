class Validators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    final stripped = value.replaceAll(RegExp(r'\s|-'), '');
    if (!phoneRegex.hasMatch(stripped)) return 'Enter a valid phone number';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final age = int.tryParse(value.trim());
    if (age == null || age < 1 || age > 120) return 'Enter a valid age (1–120)';
    return null;
  }

  static String? ageMonths(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age in months is required';
    final months = int.tryParse(value.trim());
    if (months == null || months < 0 || months > 36) return 'Enter age between 0 and 36 months';
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Birth weight is required';
    final w = double.tryParse(value.trim());
    if (w == null || w < 0.3 || w > 8.0) return 'Enter a valid weight (0.3–8.0 kg)';
    return null;
  }

  static String? gestationalAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Gestational age is required';
    final weeks = int.tryParse(value.trim());
    if (weeks == null || weeks < 20 || weeks > 45) return 'Enter weeks between 20 and 45';
    return null;
  }
}
