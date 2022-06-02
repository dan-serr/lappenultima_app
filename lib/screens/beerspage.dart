import 'package:flutter/material.dart';

class BeersPage extends StatefulWidget {
  const BeersPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BeersPageState();

}

class _BeersPageState extends State<BeersPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('BeersPage')
      ),
    );
  }
}