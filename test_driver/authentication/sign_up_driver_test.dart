import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import '../main_test.dart';

void signUpDriverTest() {
  group("First step |", () {
    var btnSignUp = find.byValueKey("login_sign_up_button");
    var btnSendEmail = find.byValueKey("send_email_button");
    var inputName = find.byValueKey("textfield_name");
    var inputLastName = find.byValueKey("textfield_last_name");
    var inputCpf = find.byValueKey("textfield_cpf");
    var inputEmail = find.byValueKey("textfield_email");
    var inputPassword = find.byValueKey("textfield_password");
    var inputPasswordRepeat = find.byValueKey("textfield_password_repeat");
    var arrowBack = find.byValueKey("arrow_back");
    var txtSnackError = find.byValueKey("snackbar_text");

    test("Enter", () async {
      await driver().tap(btnSignUp);
    });

    test("Empty fields", () async {
      await driver().tap(btnSendEmail);

      await driver().waitFor(txtSnackError);
      expect(await driver().getText(txtSnackError), "Fields are required");
      await driver().waitForAbsent(txtSnackError);
    });

    test("Cpf already exist", () async {
      await driver().tap(inputName);
      await driver().enterText("Name");
      await driver().tap(inputLastName);
      await driver().enterText("LastName");
      await driver().tap(inputCpf);
      await driver().enterText("791.457.050-89");
      await driver().tap(inputEmail);
      await driver().enterText("email@email.com");

      expect(await driver().getText(find.text("CPF already in use")),
          "CPF already in use");

      // await driver().tap(btnSendEmail);
    });
    test("Email already exist", () async {
      await driver().tap(inputCpf);
      await driver().enterText("316.519.520-00");
      await driver().tap(inputEmail);
      await driver().enterText("giu.stravini@gmail.com");

      expect(await driver().getText(find.text("E-mail already in use")),
          "E-mail already in use");
    });

    test("Password is invalid", () async {
      await driver().tap(inputPassword);
      await driver().enterText("12345");

      expect(await driver().getText(find.text("Minimum of 6 characters")),
          "Minimum of 6 characters");
    });

    test("Password doesn't match", () async {
      await driver().tap(inputPassword);
      await driver().enterText("123456");
      await driver().tap(inputPasswordRepeat);
      await driver().enterText("12345");

      expect(await driver().getText(find.text("Password doesn't macth")),
          "Password doesn't macth");
    });

    test("Success", () async {
      await driver().tap(inputCpf);
      await driver().enterText("316.519.520-00");
      await driver().tap(inputEmail);
      await driver().enterText("email@email.com");
      await driver().tap(inputPassword);
      await driver().enterText("123456");
      await driver().tap(inputPasswordRepeat);
      await driver().enterText("123456");

      await driver().tap(btnSendEmail);
    });

    test("ReSend email", () async {
      await driver().tap(arrowBack);
    });
  });
}
