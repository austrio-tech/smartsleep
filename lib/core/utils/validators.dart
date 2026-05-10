import 'package:form_builder_validators/form_builder_validators.dart';

class AppValidators {
  static final required = FormBuilderValidators.required();
  static final email = FormBuilderValidators.email();
  static final numeric = FormBuilderValidators.numeric();
  
  static minLength(int length) => FormBuilderValidators.minLength(length);
  static min(num value) => FormBuilderValidators.min(value);
  static max(num value) => FormBuilderValidators.max(value);
}
