import 'package:flutter/material.dart';
import 'package:lappenultima_app/screens/login.dart';
import 'package:lappenultima_app/util/remoteapi.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _menuItems = <String>['Logout'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('lappenultima'), actions: [
        PopupMenuButton(
            itemBuilder: (context) => _menuItems
                .map((choice) =>
                    PopupMenuItem(value: choice, child: Text(choice)))
                .toList(),
            onSelected: _onSelectedMenu)
      ]),
      body: const Center(child: Text('HomePage')),
    );
  }

  void _onSelectedMenu(String choice) {
    switch (choice) {
      case 'Logout':
        RemoteApi.logoutAction();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const Login()));
        break;
    }
  }
}
