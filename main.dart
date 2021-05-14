import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vimob/home_page.dart';
import 'package:vimob/i18n/i18n_delegate.dart';
import 'package:vimob/states/global_settings_state.dart';
import 'package:vimob/states/authentication_state.dart';
import 'package:vimob/states/buyer_state.dart';
import 'package:vimob/states/company_state.dart';
import 'package:vimob/states/connectivity_state.dart';
import 'package:vimob/states/development_state.dart';
import 'package:vimob/states/invite_state.dart';
import 'package:vimob/states/profile_state.dart';
import 'package:vimob/states/proposal_state.dart';
import 'package:vimob/states/payment_state.dart';
import 'package:vimob/states/sign_up_state.dart';
import 'package:vimob/style.dart';
import 'package:vimob/ui/authentication/check_user.dart';
import 'package:vimob/ui/authentication/email_confirmation_page.dart';
import 'package:vimob/ui/authentication/forgot_password_page.dart';
import 'package:vimob/ui/authentication/forgot_password_sent_page.dart';
import 'package:vimob/ui/authentication/login_page.dart';
import 'package:vimob/ui/authentication/resend_email_page.dart';
import 'package:vimob/ui/authentication/sign_up_page.dart';
import 'package:vimob/ui/invite/company_invite_page.dart';
import 'package:vimob/ui/invite/qr_scan_camera.dart';
import 'package:vimob/ui/profile/change_email_page.dart';
import 'package:vimob/ui/profile/change_password_page.dart';
import 'package:vimob/ui/profile/profile_page.dart';
import 'package:vimob/ui/proposal/development_list_page.dart';
import 'package:vimob/ui/proposal/proposal_filter_page.dart';
import 'package:vimob/ui/payment/proposal_saved_page.dart';
import 'package:vimob/utils/widgets/splash_screen.dart';

/*
Vimob - Flutter

============================================================

State management: Provider + rxdart

Some concepts:
-BLoCs (Business Logic)
recive a date, manipule and return

-State
where will save data to use in differents parts of app

============================================================

About test:
-unit
bloc functions

-widget
when the widget react after some action in yourself

-integration
When have more than one widget with reaction

============================================================

About files name:
lowercase separate with underscore(_)

- State
*_state.dart

- Bloc
*_bloc.dart

- Component
*.dart
*_page.dart

- Test
test\*_test.dart (unit/widget)
test_driver\*_driver_test.dart (integration)

============================================================


                  ========ToDo's==========
TODO: refactoring: SignIn and SignUp form*******
TODO: Fix logOut error
TODO: Filter need save old state when is closed?
TODO: Make integration tests independent*******
need clean the base(delete user "email@email.com" on firestore("users") and authentication) to run test
need clean the base(delete buyer "Dart > React Native" on firestore("buyers") ) to run test
TODO: Refactoring test data**********

========Buyer==========
TODO: delete buyer?

*/

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();

  await GlobalSettingsState().fetchGlobalSettings();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    var globalSettingsState = GlobalSettingsState();
    var proposalState = ProposalState();
    var paymentState = PaymentState();
    var developmentState = DevelopmentState();
    var authenticationState = AuthenticationState();
    var connectivityState = ConnectivityState();
    var companyInviteState = InviteState();
    var companyState = CompanyState();
    var signUpState = SignUpState();
    var profileState = ProfileState();
    var buyerState = BuyerState();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: globalSettingsState,
        ),
        ChangeNotifierProvider.value(
          value: proposalState,
        ),
        ChangeNotifierProvider.value(
          value: paymentState,
        ),
        ChangeNotifierProvider.value(
          value: developmentState,
        ),
        ChangeNotifierProvider.value(
          value: authenticationState,
        ),
        ChangeNotifierProvider.value(
          value: connectivityState,
        ),
        ChangeNotifierProvider.value(
          value: companyInviteState,
        ),
        ChangeNotifierProvider.value(
          value: companyState,
        ),
        ChangeNotifierProvider.value(
          value: signUpState,
        ),
        ChangeNotifierProvider.value(
          value: profileState,
        ),
        ChangeNotifierProvider.value(
          value: buyerState,
        ),
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        Style().responsiveInit(constraints: constraints);
        ConnectivityState().checkInternet();
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Style.brandColor,
            statusBarBrightness: Brightness.light));
        return MaterialApp(
          theme: Style.mainTheme,
          localizationsDelegates: [
            const I18nDelegate(),
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('pt', 'BR'),
            const Locale('es', ''),
          ],
          initialRoute: '/',
          localeResolutionCallback: (deviceLocale, supportedLocale) {
            proposalState.deveiceLocale = deviceLocale.toString();
            developmentState.deviceLocale = deviceLocale.toString();
            return deviceLocale;
          },
          routes: {
            ///[CheckUser] will check if user is logged
            ///if true, redirect to HomePage
            ///if false, redirect to LoginPage
            '/': (context) => CheckUser(
                authenticationState: authenticationState, context: context),
            'splashScreen': (context) => SplashScreen(),
            'home': (context) => HomePage(),
            'login': (context) => LoginPage(),
            'signUp': (context) => SignUpPage(),
            'resendEmail': (context) => ReSendEmailPage(),
            'emailConfirmation': (context) => EmailConfirmationPage(),
            'companyInvite': (context) => CompanyInvitePage(),
            'QRScanCamera': (context) => QRScanCamera(),
            'developmentList': (context) => DevelopmentListPage(),
            'forgotPassword': (context) => ForgotPasswordPage(),
            'forgotPasswordSent': (context) => ForgotPasswordSentPage(),
            'profile': (context) => ProfilePage(),
            'changePassword': (context) => ChangePasswordPage(),
            'changeEmail': (context) => ChangeEmailPage(),
            'proposalFilterPage': (context) => ProposalFilterPage(),
            'proposalSavedPage': (context) => ProposalSavedPage(),
          },
        );
      }),
    );
  }
}
