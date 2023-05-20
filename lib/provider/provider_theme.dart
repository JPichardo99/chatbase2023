import 'package:chatbase/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  late ThemeData _themeData;
  late String _themeMode;

  ThemeNotifier() {
    _themeMode = "light";
    _themeData = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: thBackground,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: kPrimaryColor,
          shape: const StadiumBorder(),
          maximumSize: const Size(double.infinity, 56),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: thLightMode,
        iconColor: Colors.black,
        prefixIconColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        backgroundColor: kPrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 19,
            fontFamily: 'Poppins'),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimaryColor,
      ),
      cardTheme: const CardTheme(
        elevation: 4,
      ),
    );
    loadThemeFromPrefs();
  }

  ThemeData getTheme() => _themeData;

  String getThemeMode() => _themeMode;

  void setTheme(String themeMode) async {
    _themeMode = themeMode;
    switch (_themeMode) {
      case "light":
        _themeData = ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: thBackground,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: thLightMode,
            iconColor: Colors.black,
            prefixIconColor: Colors.black,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: kPrimaryColor,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 19,
                fontFamily: 'Poppins'),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: kPrimaryColor,
          ),
          cardTheme: const CardTheme(
            elevation: 4,
          ),
        );
        break;
      case "dark":
        _themeData = ThemeData(
          accentColor: Colors.red,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: thDarkMode,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: thDarkModeButtons,
            iconColor: Colors.white,
            prefixIconColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 19,
                fontFamily: 'Poppins'),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromRGBO(66, 66, 66, 1),
          ),
        );
        break;
    }
    notifyListeners();
    saveThemeToPrefs();
  }

  Future<void> saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode);
  }

  Future<void> loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode');
    if (themeMode == null) {
      _themeMode = "light";
      _themeData = ThemeData.light();
    } else {
      _themeMode = themeMode;
      setTheme(_themeMode);
    }
  }
}
