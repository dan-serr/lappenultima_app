import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lappenultima_app/components/barcard.dart';
import 'package:lappenultima_app/screens/login.dart';
import 'package:lappenultima_app/util/remoteapi.dart';

import '../components/beercard.dart';
import '../models/bar.dart';
import '../models/beer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlutterSecureStorage _secureStorage;
  late Future<Bar?> _futureBar;
  late Future<Beer?> _futureBeer;
  late Future<void> _futureUser;

  Bar? _bar;
  Beer? _beer;

  bool _firstLoadBeer = true;
  bool _firstLoadBar = true;

  String? accessToken;
  String? user;

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _futureUser = Future.sync(() => _getUserData());
    _futureBeer = Future.sync(() => RemoteApi.getBeerMostRated());
    _futureBar = Future.sync(() => RemoteApi.getBarMostRated());
  }

  final List<String> _menuItems = <String>[
    //'Opciones',
    'Cerrar sesión'
  ];
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureUser,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return Scaffold(
            appBar: AppBar(title: const Text('lappenultima'), actions: [
              PopupMenuButton(
                  itemBuilder: (context) => _menuItems
                      .map((choice) =>
                          PopupMenuItem(value: choice, child: Text(choice)))
                      .toList(),
                  onSelected: _onSelectedMenu)
            ]),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
                      child: AutoSizeText(
                          user != '' ? '¡Bienvenido $user!' : '¡Bienvenido!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline4),
                    ),
                    const Divider(
                      height: 15,
                    ),
                    AutoSizeText(
                      'Te puede interesar ',
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                    Container(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                        margin:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                        child: Card(
                            elevation: 4.0,
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        width: 2),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 5, 0, 0),
                                        child: AutoSizeText(
                                            'La cerveza del momento',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            textAlign: TextAlign.center),
                                      ),
                                      const Divider(height: 5),
                                      FutureBuilder(
                                        future: _futureBeer,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasError) {
                                              return Text('${snapshot.error}');
                                            }
                                            if (snapshot.hasData) {
                                              if (_firstLoadBeer) {
                                                _beer = snapshot.data as Beer?;
                                                _firstLoadBeer = false;
                                              }
                                              return _beer != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: BeerCard(
                                                          beer: _beer!,
                                                          accessToken:
                                                              accessToken!),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                          "assets/beer_placeholder.png"));
                                            }
                                          }
                                          return Column(children: [
                                            Icon(Icons.error,
                                                color: Theme.of(context)
                                                    .errorColor,
                                                size: 40),
                                            const Text(
                                                'Error al encontrar la cerveza más votada.')
                                          ]);
                                        },
                                      ),
                                    ])))),
                    const Divider(
                      height: 15,
                    ),
                    Container(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                        margin:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Card(
                                elevation: 4.0,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 5.0, 0, 0),
                                      child: AutoSizeText('El bar del momento',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5,
                                          textAlign: TextAlign.center),
                                    ),
                                    const Divider(height: 5),
                                    FutureBuilder(
                                      future: _futureBar,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            return Text('${snapshot.error}');
                                          }
                                          if (snapshot.hasData) {
                                            if (_firstLoadBar) {
                                              _bar = snapshot.data as Bar?;
                                              _firstLoadBar = false;
                                            }
                                            return _bar != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: BarCard(
                                                      bar: _bar!,
                                                      accessToken: accessToken!,
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        "assets/bar_placeholder.jpg"),
                                                  );
                                          }
                                        }
                                        return Column(children: [
                                          Icon(Icons.error,
                                              color: Theme.of(context)
                                                  .errorColor,
                                              size: 40),
                                          const Text(
                                              'Error al encontrar el bar más votado.')
                                        ]);
                                      },
                                    )
                                  ],
                                ))))
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _onSelectedMenu(String choice) {
    switch (choice) {
      case 'Cambiar tema':
        _showThemeDialog();
        break;
      case 'Cerrar sesión':
        RemoteApi.logoutAction();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const Login()));
        break;
    }
  }

  Future<void> _getUserData() async {
    user = await _secureStorage.read(key: 'username');
    accessToken = await _secureStorage.read(key: 'access_token');
  }

  void _showThemeDialog() {}
}
