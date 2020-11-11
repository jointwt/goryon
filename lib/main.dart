import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:goryon/httpclient.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'screens/auth_widget.dart';
import 'strings.dart';
import 'viewmodels.dart';
import 'widgets/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MyApp(
      sharedPreferences: await SharedPreferences.getInstance(),
      packageInfo: await PackageInfo.fromPlatform(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final PackageInfo packageInfo;

  const MyApp({
    Key key,
    @required this.sharedPreferences,
    @required this.packageInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final api = Api(
      UserAgentClient(http.Client(), this.packageInfo),
      FlutterSecureStorage(),
    );

    return MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider(create: (_) => AppStrings()),
        Provider(create: (_) => AuthViewModel(api)),
        ChangeNotifierProvider(
          create: (context) => ThemeViewModel(sharedPreferences),
        ),
      ],
      child: AuthWidgetBuilder(
        builder: (context, snapshot) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AuthWidget(snapshot: snapshot),
          themeMode: context.watch<ThemeViewModel>().themeMode,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue,
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
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
          theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
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
