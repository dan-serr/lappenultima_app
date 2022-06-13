import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lappenultima_app/screens/login.dart';
import 'package:lappenultima_app/theme/theme.dart';

void main() {
  runApp(const Appenultima());
}

class Appenultima extends StatelessWidget {
  const Appenultima({Key? key}) : super(key: key);

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
