import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lappenultima_app/components/beercard.dart';
import 'package:lappenultima_app/models/beer.dart';
import 'package:http/http.dart' as http;
import 'package:lappenultima_app/models/beertype.dart';
import 'package:lappenultima_app/util/remoteapi.dart';

class BeersPage extends StatefulWidget {
  const BeersPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BeersPageState();
}

class _BeersPageState extends State<BeersPage> {
  late FlutterSecureStorage _secureStorage;

  bool _isSearching = false;
  late TextEditingController _searchController;
  String? _searchTerm;

  String? _accessToken;

  late Future<List<BeerType>> _futureTypeList;
  late List<BeerType> _beerTypeFilterList;
  BeerType? _beerTypeFilter;

  static const _pageSize = 6;
  final PagingController<int, Beer> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _searchController = TextEditingController();
    _futureTypeList = RemoteApi.getBeerTypes();
    _pagingController
        .addPageRequestListener((pageKey) async => await _fetchPage(pageKey));
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      _accessToken ??= await _secureStorage.read(key: 'access_token');
      final newItems =
          await RemoteApi.fetchBeers(pageKey, _pageSize, _searchTerm);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        int nextPageKey = pageKey + _pageSize;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: !_isSearching
                ? const Text('Cervezas')
                : TextField(
                    controller: _searchController,
                    onChanged: _updateSearchTerm,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.search), hintText: 'Buscar cerveza'),
                  ),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    _updateSearchTerm('');
                    _pickFilter();
                  },
                  icon: const Icon(Icons.filter_alt)),
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  _updateSearchTerm('');
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: !_isSearching
                    ? const Icon(Icons.search)
                    : const Icon(Icons.cancel),
              ),
            ]),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() {
            _pagingController.refresh();
          }),
          child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: PagedGridView(
                          pagingController: _pagingController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 3,
                                  childAspectRatio: 100 / 150),
                          builderDelegate: PagedChildBuilderDelegate<Beer>(
                              itemBuilder: (context, item, index) {
                            return BeerCard(
                                beer: item, accessToken: _accessToken!);
                          })))
                ]),
          ),
        ));
  }

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  void _pickFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Filtrar por tipo de cerveza',
                textAlign: TextAlign.center),
            content: SizedBox(
              height: 350,
              width: 300,
              child: FutureBuilder(
                  future: _futureTypeList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      if (snapshot.hasData) {
                        _beerTypeFilterList = snapshot.data as List<BeerType>;
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: _beerTypeFilterList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  _beerTypeFilter = _beerTypeFilterList[index];
                                  if (_beerTypeFilter != null) {
                                    _pagingController.itemList =
                                        _pagingController.itemList
                                            ?.where((element) =>
                                                element.iDBeerType!.id ==
                                                _beerTypeFilter!.id)
                                            .toList();
                                  }
                                  Navigator.of(context).pop();
                                },
                                title: Text(
                                  _beerTypeFilterList[index].name,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            });
                      }
                    }
                    return const Icon(Icons.error, size: 40);
                  }),
            ),
          );
        });
  }
}
