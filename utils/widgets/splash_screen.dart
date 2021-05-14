import 'package:flutter/material.dart';
import 'package:vimob/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          _buildBackground(),
          Column(
            children: <Widget>[
              Flexible(flex: 5, child: _buildLogo()),
              Flexible(flex: 2, child: _buildLogoMega()),
            ],
          ),
        ],
      ),
    );
  }

  Center _buildBackground() {
    return Center(
      child: Image.asset(
        "assets/common/splash_screen.png",
        height: Style.vertical(100),
        width: Style.horizontal(100),
        fit: BoxFit.fill,
      ),
    );
  }

  Center _buildLogoMega() {
    return Center(
      child: Image.asset(
        "assets/common/powered_by_mega.png",
        width: Style.horizontal(25),
        fit: BoxFit.fill,
      ),
    );
  }

  Center _buildLogo() {
    return Center(
      child: Image.asset(
        "assets/login/app_logo.png",
        width: Style.horizontal(55),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:vimob/style.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({
//     Key key,
//   }) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(
//       Duration(seconds: 2),
//     ).then((_) => Navigator.pushNamedAndRemoveUntil(
//         context, "/", (Route<dynamic> route) => false));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.transparent,
//       child: Stack(
//         children: <Widget>[
//           _buildBackground(),
//           Column(
//             children: <Widget>[
//               Flexible(flex: 5, child: _buildLogo()),
//               Flexible(flex: 2, child: _buildLogoMega()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Center _buildBackground() {
//     return Center(
//       child: Image.asset(
//         "assets/common/splash_screen.png",
//         height: Style.vertical(100),
//         width: Style.horizontal(100),
//         fit: BoxFit.fill,
//       ),
//     );
//   }

//   Center _buildLogoMega() {
//     return Center(
//       child: Image.asset(
//         "assets/common/powered_by_mega.png",
//         width: Style.horizontal(25),
//         fit: BoxFit.fill,
//       ),
//     );
//   }

//   Center _buildLogo() {
//     return Center(
//       child: Image.asset(
//         "assets/login/app_logo.png",
//         width: Style.horizontal(55),
//       ),
//     );
//   }
// }
