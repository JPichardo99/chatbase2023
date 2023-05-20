import 'dart:developer';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chatbase/api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LogginButtos extends StatefulWidget {
  const LogginButtos({
    Key? key,
  }) : super(key: key);

  @override
  State<LogginButtos> createState() => _LogginButtosState();
}

final RoundedLoadingButtonController googleController =
    RoundedLoadingButtonController();

class _LogginButtosState extends State<LogginButtos> {
  // guardar preferencias de onboarding

  // google
  _handleGoogleBntClick() {
    _signInWithGoogle().then((user) async {
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalUserInfo: ${user.additionalUserInfo}');
        googleController.success();
        if ((await APIs.UserExists())) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (Route<dynamic> route) => false,
          );
        } else {
          await APIs.createUser().then((value) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (Route<dynamic> route) => false,
            );
          });
        }
      } else {
        googleController.reset();
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      // Manejar la excepción aquí
      log('Error al iniciar sesión con Google: $e');
      AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              headerAnimationLoop: false,
              animType: AnimType.topSlide,
              title: 'Error',
              desc: 'Error al iniciar sesión con Google',
              btnOkOnPress: () {})
          .show();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RoundedLoadingButton(
          onPressed: () {
            _handleGoogleBntClick();
          },
          controller: googleController,
          successColor: Colors.red,
          width: MediaQuery.of(context).size.width * 0.80,
          elevation: 0,
          borderRadius: 25,
          color: Colors.red,
          child: Wrap(
            children: const [
              Icon(
                FontAwesomeIcons.google,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(
                width: 14,
              ),
              Text("Iniciar sesión con Google",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
