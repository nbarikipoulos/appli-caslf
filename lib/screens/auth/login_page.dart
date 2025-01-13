import 'package:caslf/router/app_router.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SignInScreen(
        showAuthActionSwitch: false,
        showPasswordVisibilityToggle: true,
        // breakpoint: 800,
        // headerBuilder: (context, _, __) => Center(child: Text('CASLF')),
        // sideBuilder: (context, _) => Center(child: Text('CASLF')),
        actions: [
          ForgotPasswordAction(((context, email) {
            final uri = Uri(
              path: NavigationHelper().resetPassword.path,
              queryParameters: <String, String?>{
                'email': email,
              },
            );
            context.push(uri.toString());
          })),
          AuthStateChangeAction(((context, state) async {
            final user = switch (state) {
              SignedIn state => state.user,
              // UserCreated state => state.credential.user,
              _ => null
            };
            if (user == null) {
              return;
            }
            // if (state is UserCreated) {
            //   user.updateDisplayName(user.email!.split('@')[0]);
            // }
            if (!user.emailVerified) {
              user.sendEmailVerification();
              var snackBar = SnackBar(
                  content: Text(
                    tr(context)!.check_email
                  )
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            context.pushReplacement(NavigationHelper().timeSlots.path);
          })),
        ]
      )
    ),
  );
}