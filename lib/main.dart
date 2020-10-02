import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'api.dart';
import 'widgets/common_widgets.dart';
import 'screens/auth_widget.dart';
import 'strings.dart';
import 'viewmodels.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final api = Api(http.Client(), FlutterSecureStorage());

    return MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider(create: (_) => AppStrings()),
        Provider(create: (_) => AuthViewModel(api)),
      ],
      child: AuthWidgetBuilder(
        builder: (_, snapshot) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthWidget(snapshot: snapshot),
          // themeMode: ThemeMode.system,
          // themeMode: ThemeMode.light,
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue,
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.grey[850],
              iconTheme: IconThemeData(color: Colors.white),
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.grey[50],
              iconTheme: IconThemeData(color: Colors.black),
              textTheme: TextTheme(
                headline6: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
