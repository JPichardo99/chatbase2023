import 'dart:developer';
import 'package:chatbase/firebase_options.dart';
import 'package:chatbase/provider/provider_theme.dart';
import 'package:chatbase/routes.dart';
import 'package:chatbase/screens/Onboarding/onboarding_screen.dart';
import 'package:chatbase/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';

//import 'firebase_options.dart';
int? isviewed;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // chanel for push notification
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'Para recibir notificaciones de Chatbase',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'chats',
  );
  log('\nNotification Channel Result: $result');
  //
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ],
        child: ChatbaseApp(),
      );
    });
  }
}

class ChatbaseApp extends StatelessWidget {
  const ChatbaseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatbase',
      theme: Provider.of<ThemeNotifier>(context).getTheme(),
      home: isviewed != 0 ? OnboardingScreen() : SplashScreen(),
      //home: OnboardingScreen(),
      routes: getApplicactionRoutes(),
    );
  }
}
