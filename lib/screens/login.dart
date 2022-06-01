import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lappenultima_app/screens/home.dart';
import 'package:lappenultima_app/util/constants.dart' as constants;

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

  String? accessToken;
  String? refreshToken;

  bool _isBusy = false;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _checkToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('lappenultima')),
        body: Center(
            child: _isBusy
                ? const CircularProgressIndicator()
                : Padding(
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
                            onChanged: (text) =>
                                setState(() => _username = text),
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
                                          builder: (context) =>
                                              const Register())),
                                  child: Text(
                                    'Regístrate',
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                    textAlign: TextAlign.center,
                                  ))
                            ],
                          )
                        ],
                      ),
                    ))));
  }

  _loginAction(String username, String password) async {
    setState(() {
      _isBusy = true;
    });
    try {
      String ip = constants.ip;
      var headers = {
        'Authorization': 'Basic Y2xpZW50OnNlY3JldA==',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'SESSION=YmUyM2VjZWUtYTJlNy00MzRkLTk0MjgtNjcyOWM1MmI4NmZl'
      };
      var request = http.Request('POST', Uri.parse('$ip/oauth/token'));
      request.bodyFields = {
        'grant_type': 'password',
        'username': username,
        'password': password
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Map<String, dynamic> mappedResponse =
            jsonDecode(await response.stream.bytesToString());
        await _secureStorage.write(
            key: 'access_token', value: mappedResponse['access_token']);
        await _secureStorage.write(
            key: 'refresh_token', value: mappedResponse['refresh_token']);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const HomePage(),
            ));
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
    setState(() {
      _isBusy = false;
    });
  }

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

  Future<void> _checkToken() async {
    setState(() {
      _isBusy = true;
    });
    if (await _secureStorage.containsKey(key: "access_token")) {
      final accessToken = await _secureStorage.read(key: "access_token");
      if (accessToken != null) {
        _loginAccess(accessToken);
      }
    } else {
      if (await _secureStorage.containsKey(key: "refresh_token")) {
        final refreshToken = await _secureStorage.read(key: "refresh_token");
        if (refreshToken != null) {
          _loginRefresh(refreshToken);
        }
      }
    }
    setState(() {
      _isBusy = false;
    });
  }

  void _loginAccess(String accessToken) async {
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Cookie': 'SESSION=YzA4ODYyYTQtNmJlNi00NjRkLTk0MjEtNWZkMGRjYWNmNzRi'
    };
    var request = http.Request(
        'GET', Uri.parse('http://${constants.ip}/rest/entities/User'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> mappedResponse =
          jsonDecode(await response.stream.bytesToString());
      await _secureStorage.write(key: 'user_id', value: mappedResponse['id']);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const HomePage(),
          ));
    } else if (response.statusCode == 401) {
      await _secureStorage.delete(key: 'access_token');
    } else {
      print(response.reasonPhrase);
    }
  }

  void _loginRefresh(String refreshToken) async {
    var headers = {
      'Authorization': 'Basic Y2xpZW50OnNlY3JldA==',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': 'SESSION=MTY3OTNiODgtODdiNi00NGIyLWIyMWItZWZmNmE0MGM0Yjg4'
    };
    var request =
        http.Request('POST', Uri.parse('http://${constants.ip}/oauth/token'));
    request.bodyFields = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map<String, dynamic> mappedResponse =
          jsonDecode(await response.stream.bytesToString());
      await _secureStorage.write(
          key: 'access_token', value: mappedResponse['access_token']);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const HomePage(),
          ));
    } else if (response.statusCode == 401) {
      await _secureStorage.delete(key: 'refresh_token');
    } else {
      print(response.reasonPhrase);
    }
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

  late http.Response _response;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _checkPasswordController = TextEditingController();
    _response = http.Response('', 500);
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

  Future<http.Response> _registerAction(
      String username, String email, String password) async {
    //Para emulador:
    //String ip = '10.0.2.2:8080';
    //Para móvil:
    String ip = constants.ip;
    print('Entrada _register');
    http.Response response = await http.post(
      Uri.parse('$ip/registration/user'),
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
