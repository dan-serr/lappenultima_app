import 'package:flutter/material.dart';
import 'package:lappenultima_app/screens/login.dart';
import 'package:lappenultima_app/theme/theme.dart';

void main() {
  runApp(const Appenultima());
}

class Appenultima extends StatelessWidget {
  const Appenultima({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lappenultima',
      theme: AppenultimaTheme.light(),
      darkTheme: AppenultimaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Login(),
    );
  }
}
