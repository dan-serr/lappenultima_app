import 'package:flutter/material.dart';

class BarsPage extends StatefulWidget {
  const BarsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarsPageState();

}

class _BarsPageState extends State<BarsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('BarsPage')
      ),
    );
  }
}