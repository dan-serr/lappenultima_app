import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../components/barcard.dart';
import '../models/bar.dart';
import '../util/remoteapi.dart';

class BarsPage extends StatefulWidget {
  const BarsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BarsPageState();
}

class _BarsPageState extends State<BarsPage> {
  late FlutterSecureStorage _secureStorage;

  bool _isSearching = false;
  late TextEditingController _searchController;
  String? _searchTerm;

  String? _accessToken;

  static const _pageSize = 10;
  final PagingController<int, Bar> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _searchController = TextEditingController();
    _pagingController
        .addPageRequestListener((pageKey) async => await _fetchPage(pageKey));
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      _accessToken ??= await _secureStorage.read(key: 'access_token');
      final newItems =
          await RemoteApi.fetchBars(pageKey, _pageSize, _searchTerm);
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
              ? const Text('Bars')
              : TextField(
                  controller: _searchController,
                  onChanged: _updateSearchTerm,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.search), hintText: 'Search bar'),
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
            )
          ],
        ),
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
                          gridDelegate: SliverWovenGridDelegate.count(
                            crossAxisCount: 1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 6,
                            pattern: [
                              const WovenGridTile(1.25,
                                  crossAxisRatio: 1,
                                  alignment: AlignmentDirectional(0.75, 0)),
                            ],
                          ),
                          builderDelegate: PagedChildBuilderDelegate<Bar>(
                              itemBuilder: (context, item, index) {
                            return BarCard(
                                bar: item, accessToken: _accessToken!);
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
}
