import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'auth/login.dart';
import 'auth/sign_up.dart';
import 'home_panel.dart';

void main() {
  runApp(const SplitPayApp());
}

class SplitPayApp extends StatefulWidget {
  const SplitPayApp({Key? key}) : super(key: key);

  @override
  State<SplitPayApp> createState() => _SplitPayAppState();
}

class _SplitPayAppState extends State<SplitPayApp> {
  bool _isAuthenticated = false;
  ThemeMode _themeMode = ThemeMode.light;

  void _onLoginOrSignUp() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitPay',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginScreen(onLoginSuccess: _onLoginOrSignUp),
        '/signup': (context) => SignUpScreen(onSignUpSuccess: _onLoginOrSignUp),
        // '/home': (context) => HomePanel(toggleTheme: _toggleTheme, themeMode: _themeMode),
        '/home': (context) => HomePanel(
          toggleTheme: _toggleTheme,
          themeMode: _themeMode,
          onLogout: () {
            setState(() {
              _isAuthenticated = false;
            });
          },
        ),
      },
      home: _isAuthenticated
          ? HomePanel(toggleTheme: _toggleTheme, themeMode: _themeMode,onLogout: () {
        setState(() {
          _isAuthenticated = false;
        });
      },)
          : LoginScreen(onLoginSuccess: _onLoginOrSignUp),
      onGenerateRoute: (settings) {
        if (settings.name == '/signup') {
          return PageRouteBuilder(
            pageBuilder: (ctx, anim1, anim2) =>
                SignUpScreen(onSignUpSuccess: _onLoginOrSignUp),
            transitionsBuilder: (ctx, anim1, anim2, child) {
              final offsetAnim = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                  .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut));
              final fadeAnim = Tween<double>(begin: 0, end: 1).animate(anim1);
              return SlideTransition(
                  position: offsetAnim, child: FadeTransition(opacity: fadeAnim, child: child));
            },
            transitionDuration: Duration(milliseconds: 600),
          );
        }
        return null;
      },
    );
  }
}
