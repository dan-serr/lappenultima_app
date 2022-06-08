import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lappenultima_app/models/beer.dart';

import 'package:lappenultima_app/util/constants.dart' as constants;
import 'package:lappenultima_app/util/remoteapi.dart';
import 'package:rating_dialog/rating_dialog.dart';

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

  late bool _fav;
  late bool _rated;

  bool _firstLoadFav = true;
  bool _firstLoadRated = true;
  double? _rating;

  @override
  void initState() {
    super.initState();
    _futureFav = RemoteApi.getBeerFav(widget.beer.id);
    _futureRated = RemoteApi.getBeerRating(widget.beer.id);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widget.beer.image != null
                      ? CachedNetworkImage(
                          imageUrl:
                              '${constants.ip}/rest/files?fileRef=${widget.beer.image}&access_token=${widget.accessToken}',
                          width: 125)
                      : const Placeholder(),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Visibility(
                            visible:
                                widget.beer.iDBeerType != null ? true : false,
                            child: AutoSizeText(
                              'Tipo: ${widget.beer.iDBeerType?.name}',
                              wrapWords: true,
                            )),
                        const SizedBox(height: 10),
                        Visibility(
                            visible:
                                widget.beer.description != '' ? true : false,
                            child: AutoSizeText(
                              'IBUs: ${widget.beer.iBUs}',
                              wrapWords: true,
                            )),
                        const SizedBox(height: 10),
                        Visibility(
                            visible: widget.beer.iDBeerCompany != null
                                ? true
                                : false,
                            child: AutoSizeText(
                              'Compañía: ${widget.beer.iDBeerCompany?.name}, ${widget.beer.iDBeerCompany?.country}',
                              wrapWords: true,
                            )),
                        const SizedBox(height: 10),
                        Visibility(
                          visible: widget.beer.description != '' ? true : false,
                          child: AutoSizeText(
                            'Descripción: ${widget.beer.description}',
                            wrapWords: true,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
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
              //TODO: Añadir ver lista de bares donde está dicha cerveza o ->> meter en un scroll row <<-
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
        : RemoteApi.deleteBeerFav(widget.beer.id);
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
        submitButtonText: 'Rate',
        commentHint: 'Give us your opinion!',
        onSubmitted: (p0) =>
            RemoteApi.postBeerRating(beer, p0.rating as int, p0.comment));

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ratingDialog,
    );
  }
}
