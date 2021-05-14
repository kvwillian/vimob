import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/blocs/authentication/input_validation_bloc.dart';

void main() {
  group("Input validation bloc |", () {
    test("cpf null, should return false", () {
      var result = InputValidationBloc().validateCpfCnpj(value: null);

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("cpf wrong, should return false", () {
      var result =
          InputValidationBloc().validateCpfCnpj(value: "111.111.111-11");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("cpf empty, should return false", () {
      var result = InputValidationBloc().validateCpfCnpj(value: "");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("cpf success, should return true", () {
      var result =
          InputValidationBloc().validateCpfCnpj(value: "879.141.370-22");

      expect(result, true);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("password null, should return false", () {
      var result = InputValidationBloc().validatePassword(passwordValue: null);
      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("password empty, should return false", () {
      var result = InputValidationBloc().validatePassword(passwordValue: "");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("password success, should return true", () {
      var result =
          InputValidationBloc().validatePassword(passwordValue: "123456");

      expect(result, true);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Field is null, should return false", () {
      var result = InputValidationBloc().validateEmptyField(value: null);

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Field is empty, should return false", () {
      var result = InputValidationBloc().validateEmptyField(value: "");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Field is not empty, should return true", () {
      var result = InputValidationBloc().validateEmptyField(value: "Test");

      expect(result, true);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Password is empty, should return false", () {
      var result = InputValidationBloc()
          .comparePassword(password: "password", repeat: "");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Password is different, should return false", () {
      var result = InputValidationBloc()
          .comparePassword(password: "password", repeat: "123456");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Password is different(Uppercase), should return false", () {
      var result = InputValidationBloc()
          .comparePassword(password: "password", repeat: "Password");

      expect(result, false);
    }, timeout: Timeout(Duration(seconds: 5)));

    test("Password is equal, should return true", () {
      var result = InputValidationBloc()
          .comparePassword(password: "password", repeat: "password");

      expect(result, true);
    }, timeout: Timeout(Duration(seconds: 5)));
  });
}
