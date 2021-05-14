import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vimob/i18n/test_i18n_delegate.dart';
import 'package:vimob/utils/messages/translate_error_messages.dart';

void main() {
  group("Translate error message |", () {
    //Test key because unit test don't connect with firestore

    var errorWidget = (String error) => MaterialApp(
          localizationsDelegates: [
            TestI18nDelegate(),
          ],
          supportedLocales: [
            Locale("pt", "BR"),
            Locale("en", "US"),
          ],
          home: Builder(
            builder: (context) => Text(
              TranslateErrorMessages()
                  .translateError(context: context, error: error),
              key: Key("error_message_key"),
            ),
          ),
        );

    var emailErrorWidget = (String error) => MaterialApp(
          localizationsDelegates: [
            TestI18nDelegate(),
          ],
          supportedLocales: [
            Locale("pt", "BR"),
            Locale("en", "US"),
          ],
          home: Builder(
            builder: (context) => Text(
              TranslateErrorMessages()
                  .translateEmailError(context: context, error: error),
              key: Key("error_message_key"),
            ),
          ),
        );

    var cpfErrorWidget = (String error) => MaterialApp(
          localizationsDelegates: [
            TestI18nDelegate(),
          ],
          supportedLocales: [
            Locale("pt", "BR"),
            Locale("en", "US"),
          ],
          home: Builder(
            builder: (context) => Text(
              TranslateErrorMessages()
                  .translateCpfError(context: context, error: error),
              key: Key("error_message_key"),
            ),
          ),
        );

    var errorKey = find.byKey(Key("error_message_key"));

    testWidgets('Translate error (Email confirmation)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_EMAIL_CONFIRMATION"));

      expect(tester.widget<Text>(errorKey).data, "errorEmailConfimation");
    });

    testWidgets('Translate error (Wrong password)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_WRONG_PASSWORD"));

      expect(tester.widget<Text>(errorKey).data, "wrongPassword");
    });

    testWidgets('Translate error (User disabled)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_USER_DISABLED"));

      expect(tester.widget<Text>(errorKey).data, "userDisabled");
    });

    testWidgets('Translate error (User not found)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_USER_NOT_FOUND"));

      expect(tester.widget<Text>(errorKey).data, "userNotFound");
    });

    testWidgets('Translate error (Code not exist)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("CODE_NOT_EXIST"));

      expect(tester.widget<Text>(errorKey).data, "codeNotExist");
    });
    testWidgets('Translate error (invalid code)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("INVALID_CODE"));

      expect(tester.widget<Text>(errorKey).data, "invalidCode");
    });
    testWidgets('Translate error (Code already used)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("CODE_ALREADY_USED"));

      expect(tester.widget<Text>(errorKey).data, "codeAlreadyUsed");
    });

    testWidgets('Translate error (Fields are required)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("FIELDS_REQUIRED"));

      expect(tester.widget<Text>(errorKey).data, "fieldsRequired");
    });

    testWidgets('Translate error (Email invalid)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_INVALID_EMAIL"));

      expect(tester.widget<Text>(errorKey).data, "invalidEmail");
    });

    testWidgets('Translate error (empty)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget(""));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });

    testWidgets('Translate error (null)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget(null));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });
    testWidgets('Translate error (Requires recent login)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_REQUIRES_RECENT_LOGIN"));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });
    testWidgets('Translate error (Weak password)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_WEAK_PASSWORD"));

      expect(tester.widget<Text>(errorKey).data, "weakPassword");
    });
    testWidgets('Translate error (Too many requests)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_TOO_MANY_REQUESTS"));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });
    testWidgets('Translate error (Operation not allowed)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("ERROR_OPERATION_NOT_ALLOWED"));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });

    testWidgets('Translate error (special characters)',
        (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("*%#@&"));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });

    testWidgets('Translate error (numbers)', (WidgetTester tester) async {
      await tester.pumpWidget(errorWidget("123345"));

      expect(tester.widget<Text>(errorKey).data, "genericError");
    });

    testWidgets('Translate email error (Email already in use)',
        (WidgetTester tester) async {
      await tester.pumpWidget(emailErrorWidget("EMAIL_ALREADY_IN_USE"));

      expect(tester.widget<Text>(errorKey).data, "emailAlreadyInUse");
    });

    testWidgets('Translate email error (special characters)',
        (WidgetTester tester) async {
      await tester.pumpWidget(emailErrorWidget("@#%&*"));

      expect(tester.widget<Text>(errorKey).data, "E-mail invalid");
    });

    testWidgets('Translate email error (numbers)', (WidgetTester tester) async {
      await tester.pumpWidget(emailErrorWidget("123143"));

      expect(tester.widget<Text>(errorKey).data, "E-mail invalid");
    });

    testWidgets('Translate cpf error (Cpf already in use)',
        (WidgetTester tester) async {
      await tester.pumpWidget(cpfErrorWidget("CPF_ALREADY_IN_USE"));

      expect(tester.widget<Text>(errorKey).data, "cpfAlreadyInUse");
    });

    testWidgets('Translate cpf error (Cpf already in use)',
        (WidgetTester tester) async {
      await tester.pumpWidget(cpfErrorWidget("CPF_INVALID"));

      expect(tester.widget<Text>(errorKey).data, "CPF invalid");
    });

    testWidgets('Translate cpf error (null)', (WidgetTester tester) async {
      await tester.pumpWidget(cpfErrorWidget(null));

      expect(tester.widget<Text>(errorKey).data, "");
    });
    testWidgets('Translate cpf error (special characters)',
        (WidgetTester tester) async {
      await tester.pumpWidget(cpfErrorWidget("@#%&*"));

      expect(tester.widget<Text>(errorKey).data, "");
    });

    testWidgets('Translate cpf error (numbers)', (WidgetTester tester) async {
      await tester.pumpWidget(cpfErrorWidget("123143"));

      expect(tester.widget<Text>(errorKey).data, "");
    });
  });
}
