import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../components/barcard.dart';
import '../models/bar.dart';
import '../models/bartype.dart';
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

  late Future<List<BarType>> _futureTypeList;
  late List<BarType> _barTypeFilterList;
  BarType? _barTypeFilter;

  static const _pageSize = 20;
  final PagingController<int, Bar> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    super.initState();
    _secureStorage = const FlutterSecureStorage();
    _searchController = TextEditingController();
    _futureTypeList = RemoteApi.getBarTypes();
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
              ? const Text('Bares')
              : TextField(
                  controller: _searchController,
                  onChanged: _updateSearchTerm,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.search), hintText: 'Buscar bar'),
                ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _updateSearchTerm('');
                _pickFilter();
              },
              icon: const Icon(Icons.filter_alt),
            ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 4.0),
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
                                const WovenGridTile(1.35,
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
            title: const Text('Filtrar por tipo de bar',
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
                          _barTypeFilterList = snapshot.data as List<BarType>;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: _barTypeFilterList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () {
                                  _barTypeFilter = _barTypeFilterList[index];
                                  if (_barTypeFilter != null) {
                                    _pagingController.itemList =
                                        _pagingController.itemList
                                            ?.where((element) =>
                                                element.iDBarType!.id ==
                                                _barTypeFilter!.id)
                                            .toList();
                                  }
                                  Navigator.of(context).pop();
                                },
                                title: Text(
                                  _barTypeFilterList[index].name,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          );
                        }
                      }
                      return const Icon(Icons.error, size: 40);
                    })),
          );
        });
  }
}
