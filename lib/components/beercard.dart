import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lappenultima_app/models/beer.dart';
import 'package:lappenultima_app/util/remoteapi.dart';
import 'package:page_transition/page_transition.dart';
import '../util/constants.dart' as constants;

import 'beerdetail.dart';

class BeerCard extends StatefulWidget {
  const BeerCard(
      {Key? key,
      required this.beer,
      required this.accessToken,
      this.width = 350,
      this.height = 250})
      : super(key: key);

  final Beer beer;
  final String accessToken;
  final double width;
  final double height;

  @override
  State<BeerCard> createState() => _BeerCardState();
}

class _BeerCardState extends State<BeerCard> {
  late Future<bool> _futureFav;

  late bool _fav;
  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    _futureFav = RemoteApi.isBeerFav(widget.beer.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(PageTransition(
            type: PageTransitionType.fade,
            child: BeerDetail(
              beer: widget.beer,
              accessToken: widget.accessToken,
            ))),
        child: SafeArea(
          child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints.expand(
                  width: widget.width, height: widget.height),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [
                        0,
                        1
                      ],
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer
                      ]),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0))),
              child: Stack(
                children: [
                  Positioned(
                    right: 15,
                    child: SizedBox(
                      width: 125,
                      height: 250,
                      child: widget.beer.image != null
                          ? CachedNetworkImage(
                              imageUrl:
                                  '${constants.ip}/rest/files?fileRef=${widget.beer.image}&access_token=${widget.accessToken}',
                              width: 115,
                              fit: BoxFit.fitHeight)
                          : Image.asset('assets/beer_placeholder.png',
                              fit: BoxFit.scaleDown),
                    ),
                  ),
                  Positioned(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                          child: AutoSizeText(
                            widget.beer.name,
                            minFontSize: 24,
                            style: TextStyle(shadows: [
                              Shadow(
                                  offset: const Offset(-1, -1),
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  blurRadius: 8.0),
                              Shadow(
                                  offset: const Offset(1, -1),
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  blurRadius: 8.0),
                              Shadow(
                                  offset: const Offset(-1, 1),
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  blurRadius: 8.0),
                              Shadow(
                                  offset: const Offset(1, 1),
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  blurRadius: 8.0),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        () {
                          String tipo = widget.beer.iDBeerType?.name ?? '';
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 0, 0, 0),
                            child: AutoSizeText(
                              tipo,
                              minFontSize: 18,
                              style: TextStyle(shadows: [
                                Shadow(
                                    offset: const Offset(-1, -1),
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    blurRadius: 8.0),
                                Shadow(
                                    offset: const Offset(1, -1),
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    blurRadius: 8.0),
                                Shadow(
                                    offset: const Offset(-1, 1),
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    blurRadius: 8.0),
                                Shadow(
                                    offset: const Offset(1, 1),
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    blurRadius: 8.0),
                              ]),
                            ),
                          );
                        }()
                      ])),
                  Positioned(
                      bottom: 5,
                      left: -5,
                      child: FutureBuilder(
                          future: _futureFav,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                if (firstLoad) {
                                  _fav = snapshot.data as bool? ?? false;
                                  firstLoad = false;
                                }
                                return IconButton(
                                  icon: Icon(
                                    _fav == true
                                        ? Icons.favorite
                                        : Icons.favorite_border_outlined,
                                    size: 40,
                                  ),
                                  onPressed: _handleFav,
                                );
                              }
                            }
                            return const Icon(Icons.error, size: 40);
                          }))
                ],
              )),
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
}
