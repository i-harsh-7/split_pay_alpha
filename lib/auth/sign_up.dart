import 'package:flutter/material.dart';
import '../components/wave_header.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignUpSuccess;

  const SignUpScreen({Key? key, required this.onSignUpSuccess}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _slideAnimation = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    _performSignUp();
  }

  Future<void> _performSignUp() async {
    setState(() {});
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(child: CircularProgressIndicator()));

    try {
      await AuthService.signUp(name: name, email: email, phone: phone, password: password);
      Navigator.of(context).pop(); // close progress
      widget.onSignUpSuccess();
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final background = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final horizontalPadding = (size.width * 0.08).clamp(16.0, 28.0);
    final topPadding = (size.height * 0.18).clamp(100.0, 180.0);
    final gapSmall = (size.height * 0.018).clamp(10.0, 20.0);
    final gapMedium = (size.height * 0.03).clamp(16.0, 30.0);
    final buttonHeight = (size.height * 0.06).clamp(44.0, 56.0);
    final titleFontSize = (size.width * 0.075).clamp(22.0, 32.0) * textScale;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          WaveHeader(
            gradientStart: primaryColor,
            gradientEnd: theme.brightness == Brightness.dark
                ? Color(0xFF19202E)
                : Color(0xFFB3D8F6),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: topPadding, left: horizontalPadding, right: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: gapSmall),
                        Container(
                          width: (size.width * 0.08).clamp(24.0, 36.0),
                          height: (size.height * 0.004).clamp(2.0, 4.0),
                          color: primaryColor,
                        ),
                      ],
                    ),
                    SizedBox(height: gapMedium),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Name",
                        prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.mail_outline, color: primaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Phone no",
                        prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: gapMedium),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "Create Account",
                          style: TextStyle(fontSize: (size.width * 0.042).clamp(14.0, 18.0) * textScale, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: gapSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an Account? ",
                          style: TextStyle(color: textColor.withValues(alpha: 0.7)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: gapMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}