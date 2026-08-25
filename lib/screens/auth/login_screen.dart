import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/login_footer.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
          ),
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoginHeader(),
                SizedBox(height: 50),
                LoginForm(),
                SizedBox(height: 30),
                LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}