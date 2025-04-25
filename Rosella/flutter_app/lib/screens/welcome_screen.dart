// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_app/screens/auth_screen.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    // Show logo after short delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showLogo = true;
      });
    });

    // Navigate to Signup after splash animation (~3.5s total)
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8EFE6),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _showLogo ? 1.0 : 0.0,
                  duration: Duration(seconds: 2),
                  child: Image.asset(
                    'assets/images/rosee_trans.png',
                    height: 180,
                  ),
                ),
                SizedBox(height: 20),
                if (_showLogo)
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 36.0,
                      fontFamily: 'Cursive',
                      color: Color(0xFFB86B77),
                    ),
                    child: AnimatedTextKit(
                      totalRepeatCount: 1,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Rosella',
                          speed: Duration(milliseconds: 200),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
              ),
                );
        }
}
//
// import 'package:flutter/material.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/images/welcome_illustration.jpg'),
//             const SizedBox(height: 20),
//             const Text(
//               'Welcome to Period Tracker',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFE75A7C),
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 40),
//               child: Text(
//                 'Track your cycle, symptoms, and more with our easy-to-use app',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/auth');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE75A7C),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 40,
//                   vertical: 15,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 'Get Started',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
