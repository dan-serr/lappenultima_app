import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lappenultima_app/components/beercard.dart';
import 'package:lappenultima_app/models/bar.dart';
import 'package:lappenultima_app/util/constants.dart' as constants;
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/open_location_code.dart' as olc;
import '../util/remoteapi.dart';

class BarDetail extends StatefulWidget {
  const BarDetail({Key? key, required this.bar, required this.accessToken})
      : super(key: key);

  final Bar bar;
  final String accessToken;
  @override
  State<StatefulWidget> createState() => _BarDetailState();
}

class _BarDetailState extends State<BarDetail> {
  late Future<bool> _futureFav;
  late Future<bool> _futureRated;
  late Future<int> _futureRating;

  late bool _fav;
  late bool _rated;
  late int _rating;

  bool _firstLoadFav = true;
  bool _firstLoadRated = true;
  bool _firstLoadRating = true;

  @override
  void initState() {
    super.initState();
    _futureFav = RemoteApi.isBarFav(widget.bar.id);
    _futureRated = RemoteApi.isBarRated(widget.bar.id);
    _futureRating = RemoteApi.getBarRating(widget.bar.id);
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
            child: Center(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.bar.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                const Divider(height: 30),
                Material(
                  elevation: 2.0,
                  child: widget.bar.image != null
                      ? CachedNetworkImage(
                          imageUrl:
                              '${constants.ip}/rest/files?fileRef=${widget.bar.image}&access_token=${widget.accessToken}',
                          width: 250)
                      : CachedNetworkImage(
                          imageUrl: 'http://via.placeholder.com/275x200',
                          fit: BoxFit.scaleDown),
                ),
                const Divider(height: 30),
                Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                          visible: widget.bar.iDBarType != null,
                          child: AutoSizeText(
                            'Clase de bar: ${widget.bar.iDBarType?.name}',
                            wrapWords: true,
                          )),
                      const SizedBox(height: 10),
                      Visibility(
                        visible: widget.bar.description != '',
                        child: AutoSizeText(
                          'Descripción: ${widget.bar.description}',
                          wrapWords: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                          visible: widget.bar.direction != '',
                          child: AutoSizeText(
                            'Dirección: ${widget.bar.direction}',
                            wrapWords: true,
                          )),
                      const SizedBox(height: 10),
                      Visibility(
                          visible: !(widget.bar.pluscode == '' ||
                              widget.bar.pluscode == null),
                          child: GestureDetector(
                            onTap: _openMaps,
                            child: AutoSizeText(
                              'Abrir en Maps',
                              wrapWords: true,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          )),
                      const SizedBox(height: 10),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: (puntuacion) {
                                  List<Widget> widgets = <Widget>[];
                                  widgets.add(const Text('Valoración: '));
                                  for (int i = 0; i < 5; i++) {
                                    if (i < _rating) {
                                      widgets.add(const Icon(Icons.star));
                                    } else {
                                      widgets
                                          .add(const Icon(Icons.star_outline));
                                    }
                                  }
                                  return widgets;
                                }(_rating),
                              );
                            }
                          }
                          return const Icon(Icons.error, size: 20);
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Center(
                        child: FutureBuilder(
                          future: _futureFav,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                if (_firstLoadFav) {
                                  _fav = snapshot.data as bool? ?? false;
                                  _firstLoadFav = false;
                                }
                                return SizedBox(
                                  width: 250,
                                  child: ElevatedButton(
                                      onPressed: _handleFav,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          _fav == true
                                              ? const Icon(Icons.favorite)
                                              : const Icon(Icons
                                                  .favorite_border_outlined),
                                          const SizedBox(width: 25),
                                          _fav == true
                                              ? const Text(
                                                  'Eliminar como favorito',
                                                  textAlign: TextAlign.center)
                                              : const Text(
                                                  'Marcar como favorito',
                                                  textAlign: TextAlign.center),
                                        ],
                                      )),
                                );
                              }
                            }
                            return const Icon(Icons.error, size: 40);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      Center(
                        child: FutureBuilder(
                          future: _futureRated,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                if (_firstLoadRated) {
                                  _rated = snapshot.data as bool? ?? false;
                                  _firstLoadRated = false;
                                }
                                return SizedBox(
                                  width: 250,
                                  child: ElevatedButton(
                                      onPressed: _handleRating,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          _rated == true
                                              ? const Icon(Icons.star)
                                              : const Icon(
                                                  Icons.star_border_outlined),
                                          const SizedBox(width: 25),
                                          _rated == true
                                              ? const Text(
                                                  'Eliminar tu votación.',
                                                  textAlign: TextAlign.center)
                                              : const Text('Dejar tu opinión',
                                                  textAlign: TextAlign.center),
                                        ],
                                      )),
                                );
                              }
                            }
                            return const Icon(Icons.error, size: 40);
                          },
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          widget.bar.beers!.isNotEmpty
                              ? const Text('Cervezas en este bar:')
                              : const SizedBox(
                                  height: 1,
                                ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: SizedBox(
                                    height: 250,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.all(8),
                                      itemCount: widget.bar.beers!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return BeerCard(
                                            beer: widget.bar.beers![index],
                                            accessToken: widget.accessToken,
                                            width: 150);
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ]),
              ]),
            ),
          ),
        ));
  }

  void _handleFav() {
    _fav != true
        ? RemoteApi.postBarFav(widget.bar.id)
        : RemoteApi.deleteBarFav(widget.bar.id);
    setState(() {
      _fav = !_fav;
    });
  }

  void _handleRating() {
    _rated != true
        ? _showRatingDialog(widget.bar.id)
        : () {
            RemoteApi.deleteBarRating(widget.bar.id);
            setState(() {
              _rating = 0;
            });
          }();
    setState(() {
      _rated = !_rated;
    });
  }

  void _showRatingDialog(int bar) {
    final ratingDialog = RatingDialog(
        title: Text(
          'Puntúa ${widget.bar.name}',
          textAlign: TextAlign.center,
        ),
        initialRating: 1,
        submitButtonText: 'Puntúa',
        commentHint: '¡Dános tu opinión!',
        onSubmitted: (response) {
          RemoteApi.postBarRating(
              bar, response.rating.round(), response.comment);
          setState(() {
            _rating = response.rating.round();
          });
        });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ratingDialog,
    );
  }

  _openMaps() async {
    String? pluscode = widget.bar.pluscode;
    if (pluscode != null) {
      olc.CodeArea ca = olc.decode(pluscode);
      Uri googleUrl = Uri.parse(
          'https://www.google.com/maps/@?api=1&map_action=map&center=${ca.center.latitude},${ca.center.longitude}');
      try {
        await launchUrl(googleUrl);
      } catch (error) {
        Fluttertoast.showToast(
            msg: 'Ha habido un error abriendo el enlace.',
            textColor: Theme.of(context).primaryColor,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      }
    }
  }
}
