import 'package:flutter/material.dart';

import 'barspage.dart';
import 'beerspage.dart';
import 'home.dart';

///Clase dónde se alojarán el resto de pages.
class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const BeersPage(),
    const BarsPage()
  ];

  static int _selectedIndex = 0;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              _handleRight();
            }
            if (details.primaryVelocity! > 0) {
              _handleLeft();
            }
          },
          child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: _pages)),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_bar_outlined),
              activeIcon: Icon(Icons.sports_bar),
              label: 'Cervezas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.table_bar_outlined),
              activeIcon: Icon(Icons.table_bar),
              label: 'Bares')
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  void _handleRight() {
    if (_selectedIndex < _pages.length - 1) {
      setState(() {
        _selectedIndex++;
        _pageController.animateToPage(_selectedIndex,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    }
  }

  void _handleLeft() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
        _pageController.animateToPage(_selectedIndex,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
