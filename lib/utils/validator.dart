
class Validator {
  static final Validator _instance = Validator._internal();

  factory Validator() {
    return _instance;
  }

  Validator._internal();

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one number, and one special character';
    }
    return null;
  }

  String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    if (!RegExp(r'^[A-Z]{4}-\d{5}$').hasMatch(value.trim())) {
      return 'License number must be in format ARCH-12345';
    }
    return null;
  }

  String? validateSpecialization(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Specialization is required';
    }
    return null;
  }

  String? validateYearsOfExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Years of experience is required';
    }
    int? years = int.tryParse(value.trim());
    if (years == null || years < 0 || years > 100) {
      return 'Enter a valid number of years (0-100)';
    }
    return null;
  }

  String? validatePortfolioUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Portfolio URL is required';
    }
    if (!RegExp(r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$').hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }
    return null;
  }

  String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }
    return null;
  }

  String? validateOfficeLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Office location is required';
    }
    return null;
  }
}


