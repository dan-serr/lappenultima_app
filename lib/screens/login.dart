import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:lappenultima_app/screens/main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  String? _username;
  String? _password;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  late Future<bool> _futureLoggedIn;
  bool _loggedIn = false;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _futureLoggedIn = _checkToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _loggedIn = _futureLoggedIn as bool;
    if (_loggedIn) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const MainPage(),
          ));
    }
    return Scaffold(
        appBar: AppBar(title: const Text('lappenultima')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(40),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('lappenultima',
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text('Logueate',
                          style: Theme.of(context).textTheme.headline2,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        obscureText: false,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Nombre de usuario',
                            errorText: _userErrorText),
                        onChanged: (text) => setState(() => _username = text),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Contraseña',
                              errorText: _passwordErrorText),
                          onChanged: (text) =>
                              setState(() => _password = text)),
                      /*
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _passwordForgotten(),
                        child: const Text('¿Se te olvidó la contraseña?'),
                      ),
                       */
                      SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_userErrorText == null &&
                                  _passwordErrorText == null) {
                                _loginAction(_username!, _password!);
                              }
                            },
                            child: const Text('Login'),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿No tienes cuenta?',
                              textAlign: TextAlign.center),
                          TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (context) => const Register())),
                              child: Text(
                                'Regístrate',
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center,
                              ))
                        ],
                      )
                    ],
                  ),
                ))));
  }

  _loginAction(String email, String password) async {}

  /*
   final response = await http.post(
    Uri.parse('http://${ip}/oauth/token'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

   */

  _passwordForgotten() {
    //TODO Reenviar un email con la pass (no está controlado en la API yet)
  }

  String? get _userErrorText {
    final text = _usernameController.text;
    if (text.isEmpty) {
      return 'No puede estar vacío.';
    }
    if (text.length < 3) {
      return 'Demasiado corto.';
    }
    return null;
  }

  String? get _passwordErrorText {
    final text = _passwordController.text;
    if (text.isEmpty) {
      return 'No puede estar vacía';
    }
    return null;
  }

  Future<bool> _checkToken() async {
    if (await _secureStorage.containsKey(key: "access_token")) {
      final accessToken = await _secureStorage.read(key: "access_token");
      if (accessToken != null) {
        return _loginAccess(accessToken);
      }
    } else {
      if (await _secureStorage.containsKey(key: "refresh_token")) {
        final refreshToken = await _secureStorage.read(key: "refresh_token");
        if (refreshToken != null) {
          return _loginRefresh(refreshToken);
        }
      }
    }
    return false;
  }

  bool _loginAccess(String accessToken) {
    return false;
  }

  bool _loginRefresh(String? refreshToken) {
    return false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// Clase para la Screen de registro
class Register extends StatefulWidget {
  //TODO FINISH
  const Register({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _checkPasswordController;

  String? _username;
  String? _email;
  String? _password;
  String? _passwordCheck;

  late Response _response;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _checkPasswordController = TextEditingController();
    _response = Response('', 500);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Registro')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(40),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      const SizedBox(height: 12),
                      TextField(
                        controller: _usernameController,
                        obscureText: false,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Nombre de usuario',
                            errorText: _userErrorText),
                        onChanged: (text) => setState(() => _username = text),
                      ),
                      const SizedBox(height: 36),
                      TextField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Correo electrónico',
                              errorText: _emailErrorText),
                          onChanged: (text) => setState(() => _email = text)),
                      const SizedBox(height: 36),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Contraseña',
                            errorText: _passwordErrorText),
                        onChanged: (text) => setState(() => _password = text),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _checkPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Repite la contraseña',
                            errorText: _checkPasswordErrorText),
                        onChanged: (text) =>
                            setState(() => _passwordCheck = text),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_userErrorText == null &&
                                  _emailErrorText == null &&
                                  _passwordErrorText == null &&
                                  _checkPasswordErrorText == null) {
                                await _registerAction(
                                    _username!, _email!, _password!);
                                print(_response.statusCode);
                                if (_response.statusCode == 201) {
                                  Fluttertoast.showToast(
                                      msg:
                                          'Verifique su registro clickeando el enlace enviado a su correo.',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.white12,
                                      textColor: Colors.white,
                                      fontSize: 22.0);
                                  Future.delayed(
                                      const Duration(milliseconds: 2500), () {
                                    Navigator.pop(context);
                                  });
                                } else if (_response.statusCode == 500) {
                                  Fluttertoast.showToast(
                                      msg:
                                          'Error al registrar, inténtelo más tarde.',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.white38,
                                      textColor: Colors.redAccent,
                                      fontSize: 16.0);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'Comprueba que los campos estén rellenos y válidos.',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.white12,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: const Text('Registrar'),
                          ))
                    ])))));
  }

  String? get _userErrorText {
    final text = _usernameController.text;
    if (text.isEmpty) {
      return 'No puede estar vacío.';
    }
    if (text.length < 3) {
      return 'Demasiado corto.';
    }
    return null;
  }

  String? get _emailErrorText {
    final text = _emailController.text;
    final _emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (text.isEmpty) {
      return 'No puede estar vacío.';
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'No has introducido un email válido.';
    }
    return null;
  }

  String? get _passwordErrorText {
    final text = _passwordController.text;
    if (text.isEmpty) {
      return 'No puede estar vacía';
    }
    return null;
  }

  String? get _checkPasswordErrorText {
    final password = _passwordController.text;
    final check = _checkPasswordController.text;
    if (password == check) {
      return null;
    }
    return 'Las contraseñas no coinciden.';
  }

  Future<Response> _registerAction(
      String username, String email, String password) async {
    //Para emulador:
    //String ip = '10.0.2.2:8080';
    //Para móvil:
    String ip = '192.168.137.1:8080';
    print('Entrada _register');
    Response response = await post(
      Uri.parse('http://${ip}/registration/user'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password
      }),
    );
    print('Salida await _register');
    setState(() {
      _response = response;
    });
    print('Return _register');
    return response;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _checkPasswordController.dispose();
    super.dispose();
  }
}
