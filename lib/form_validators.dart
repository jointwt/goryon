class FormValidators {
  static String requiredField(String fieldValue) {
    if (fieldValue.isEmpty) {
      return 'Required';
    }

    return null;
  }
}
