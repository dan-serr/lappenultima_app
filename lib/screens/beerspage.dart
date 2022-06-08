import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lappenultima_app/components/beercard.dart';
import 'package:lappenultima_app/models/beer.dart';
import 'package:http/http.dart' as http;
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

  static const _pageSize = 2;
  final PagingController<int, Beer> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _secureStorage = const FlutterSecureStorage();
    _searchController = TextEditingController();
    _pagingController
        .addPageRequestListener((pageKey) async => await _fetchPage(pageKey));
    super.initState();
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
                ? const Text('Beers')
                : TextField(
                    controller: _searchController,
                    onChanged: _updateSearchTerm,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.search), hintText: 'Search beer'),
                  ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12.5),
                child: IconButton(
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
              ),
            ]),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: PagedGridView(
                          pagingController: _pagingController,
                          //separatorBuilder: (context, index) => const Divider(),
                          gridDelegate: SliverWovenGridDelegate.count(
                            crossAxisCount: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 6,
                            pattern: [
                              const WovenGridTile(1,
                                  crossAxisRatio: 0.75,
                                  alignment: AlignmentDirectional(0.75, 0)),
                            ],
                          ),
                          builderDelegate: PagedChildBuilderDelegate<Beer>(
                              itemBuilder: (context, item, index) {
                            return BeerCard(
                                beer: item, accessToken: _accessToken!);
                          })))
                ]),
          ),
        ));
    /*Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text('BeersPage'),
            ],
          ),
        )
      ), */
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
}