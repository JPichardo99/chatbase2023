import 'package:chatbase/screens/Welcome/welcome_screen.dart';
import 'package:chatbase/screens/home_screen.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> getApplicactionRoutes() {
  return <String, WidgetBuilder>{
    '/home': (BuildContext context) => HomeScreen(),
    '/welcome': (BuildContext context) => WelcomeScreen(),
  };
}
