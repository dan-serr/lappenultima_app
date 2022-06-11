import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lappenultima_app/models/beer.dart';

import 'package:lappenultima_app/util/constants.dart' as constants;
import 'package:lappenultima_app/util/remoteapi.dart';
import 'package:rating_dialog/rating_dialog.dart';

import '../models/bar.dart';
import 'barcard.dart';

class BeerDetail extends StatefulWidget {
  const BeerDetail({Key? key, required this.accessToken, required this.beer})
      : super(key: key);

  final Beer beer;
  final String accessToken;

  @override
  State<StatefulWidget> createState() => _BeerDetailState();
}

class _BeerDetailState extends State<BeerDetail> {
  late Future<bool> _futureFav;
  late Future<bool> _futureRated;
  late Future<int> _futureRating;
  late Future<List<Bar>> _futureBars;

  late bool _fav;
  late bool _rated;
  late int _rating;
  late List<Bar> _bars;

  bool _firstLoadFav = true;
  bool _firstLoadRated = true;
  bool _firstLoadRating = true;
  bool _firstLoadBars = true;

  @override
  void initState() {
    super.initState();
    _futureFav = RemoteApi.isBeerFav(widget.beer.id);
    _futureRated = RemoteApi.isBeerRated(widget.beer.id);
    _futureRating = RemoteApi.getBeerRating(widget.beer.id);
    _futureBars = RemoteApi.getBarsWithBeer(widget.beer.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Detalles')),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(widget.beer.name,
                    style: Theme.of(context).textTheme.headline2),
              ),
              const Divider(height: 30),
              Expanded(
                flex: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 125,
                      height: 250,
                      child: widget.beer.image != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  '${constants.ip}/rest/files?fileRef=${widget.beer.image}&access_token=${widget.accessToken}',
                              fit: BoxFit.fitHeight)
                          : CachedNetworkImage(
                              imageUrl: 'http://via.placeholder.com/125x250',
                              fit: BoxFit.scaleDown),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                              visible: widget.beer.iDBeerType != null,
                              child: AutoSizeText(
                                'Tipo: ${widget.beer.iDBeerType?.name}',
                                wrapWords: true,
                              )),
                          SizedBox(
                              height: widget.beer.iDBeerType != null ? 10 : 0),
                          Visibility(
                              visible: widget.beer.iBUs != null,
                              child: AutoSizeText(
                                'IBUs: ${widget.beer.iBUs}',
                                wrapWords: true,
                              )),
                          SizedBox(height: widget.beer.iBUs != null ? 10 : 0),
                          Visibility(
                              visible: widget.beer.iDBeerCompany != null,
                              child: AutoSizeText(
                                'Compañía: ${widget.beer.iDBeerCompany?.name}, ${widget.beer.iDBeerCompany?.country}',
                                wrapWords: true,
                              )),
                          SizedBox(
                              height:
                                  widget.beer.iDBeerCompany != null ? 10 : 0),
                          Visibility(
                            visible: widget.beer.description != null,
                            child: AutoSizeText(
                              'Descripción: ${widget.beer.description}',
                              wrapWords: true,
                            ),
                          ),
                          SizedBox(
                              height: widget.beer.description != null ? 10 : 0),
                          FutureBuilder(
                              future: _futureRating,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    if (_firstLoadRating) {
                                      _rating = snapshot.data as int;
                                      _firstLoadRating = false;
                                    }
                                    return Row(
                                      children: (puntuacion) {
                                        List<Widget> widgets = <Widget>[];
                                        widgets.add(const Text('Valoración: '));
                                        for (int i = 0; i < 5; i++) {
                                          if (i < _rating) {
                                            widgets.add(const Icon(Icons.star));
                                          } else {
                                            widgets.add(
                                                const Icon(Icons.star_outline));
                                          }
                                        }
                                        return widgets;
                                      }(_rating),
                                    );
                                  }
                                }
                                return const Icon(Icons.error, size: 20);
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 250,
                  child: FutureBuilder(
                    future: _futureFav,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasData) {
                          if (_firstLoadFav) {
                            _fav = snapshot.data as bool? ?? false;
                            _firstLoadFav = false;
                          }
                          return ElevatedButton(
                              onPressed: _handleFav,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _fav == true
                                      ? const Icon(Icons.favorite)
                                      : const Icon(
                                          Icons.favorite_border_outlined),
                                  const SizedBox(width: 25),
                                  _fav == true
                                      ? const Text('Eliminar como favorito',
                                          textAlign: TextAlign.center)
                                      : const Text('Marcar como favorito',
                                          textAlign: TextAlign.center),
                                ],
                              ));
                        }
                      }
                      return const Icon(Icons.error, size: 40);
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 250,
                  child: FutureBuilder(
                    future: _futureRated,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasData) {
                          if (_firstLoadRated) {
                            _rated = snapshot.data as bool? ?? false;
                            _firstLoadRated = false;
                          }
                          return ElevatedButton(
                              onPressed: _handleRating,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _rated == true
                                      ? const Icon(Icons.star)
                                      : const Icon(Icons.star_border_outlined),
                                  const SizedBox(width: 25),
                                  _rated == true
                                      ? const Text('Eliminar tu votación.',
                                          textAlign: TextAlign.center)
                                      : const Text('Dejar tu opinión',
                                          textAlign: TextAlign.center),
                                ],
                              ));
                        }
                      }
                      return const Icon(Icons.error, size: 40);
                    },
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      child: FutureBuilder(
                          future: _futureBars,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                if (_firstLoadBars) {
                                  _bars = snapshot.data as List<Bar>;
                                  _firstLoadBars = false;
                                }
                                return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 4, 8, 0),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _bars.isNotEmpty
                                              ? const Text(
                                                  'Bares donde puedes encontrarla:')
                                              : const SizedBox(
                                                  height: 1,
                                                ),
                                          Expanded(
                                            flex: 0,
                                            child: SizedBox(
                                              height: 320,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const ClampingScrollPhysics(),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  itemCount: _bars.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return BarCard(
                                                        bar: _bars[index],
                                                        accessToken:
                                                            widget.accessToken,
                                                        width: 250);
                                                  }),
                                            ),
                                          )
                                        ]));
                              }
                            }
                            return const Icon(Icons.error, size: 40);
                          }),
                    ),
                  ),
                ],
              )
            ])),
          ),
        ),
      ),
    );
  }

  void _handleFav() {
    _fav != true
        ? RemoteApi.postBeerFav(widget.beer.id)
        : RemoteApi.deleteBeerFav(widget.beer.id);
    setState(() {
      _fav = !_fav;
    });
  }

  void _handleRating() {
    _rated != true
        ? _showRatingDialog(widget.beer.id)
        : RemoteApi.deleteBeerRating(widget.beer.id);
    setState(() {
      _rated = !_rated;
    });
  }

  void _showRatingDialog(int beer) {
    final ratingDialog = RatingDialog(
        title: Text(
          'Rate ${widget.beer.name}',
          textAlign: TextAlign.center,
        ),
        initialRating: 1,
        submitButtonText: 'Rate',
        commentHint: 'Give us your opinion!',
        onSubmitted: (response) => RemoteApi.postBeerRating(
            beer, response.rating.round(), response.comment));

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ratingDialog,
    );
  }
}
