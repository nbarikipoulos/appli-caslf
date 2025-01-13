import 'package:caslf/router/app_router.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email;

  const ResetPasswordPage({
    this.email,
    super.key
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _emailCtrl.text = widget.email ?? '';

    return Scaffold(
        appBar: AppBar(
          title: Text(
            tr(context)!.screen_reset_password_title
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32.0),
                    EmailInput(
                      controller: _emailCtrl,
                      onSubmitted: (value) { /* Do nothing */}
                    ),
                    const SizedBox(height: 64.0),
                    UniversalButton(
                      variant: ButtonVariant.outlined,
                      text: tr(context)!.screen_reset_password_send,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          await _doOnPressed(
                            context,
                            _emailCtrl.text
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  Future<void> _doOnPressed(BuildContext context, String email) =>
    _auth.sendPasswordResetEmail(
      email: email
    ).then((_) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
         tr(context)!.screen_reset_password_mail_send(email)
        ),
        actions: [TextButton(
          child: Text(tr(context)!.ok),
          onPressed: () => context.pushReplacement(
            NavigationHelper().login.path
          )
        )],
      )
    ))
  ;

  @override
  void dispose() {
    super.dispose();
    _emailCtrl.dispose();
  }

}