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
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(PageTransition(
            type: PageTransitionType.fade,
            child: BeerDetail(
              beer: widget.beer,
              accessToken: widget.accessToken,
            ))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12.5, 10, 7.5),
            child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints.expand(
                    width: widget.width, height: widget.height),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          0,
                          0.5,
                          1
                        ],
                        colors: [
                          Colors.deepOrange,
                          Colors.orange,
                          Colors.yellow
                        ]),
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                              : CachedNetworkImage(
                                  imageUrl: 'http://via.placeholder.com/125x250',
                                  fit: BoxFit.scaleDown),
                        )),
                    Positioned(
                        child: AutoSizeText(widget.beer.name, minFontSize: 24)),
                    Positioned(
                        top: 35,
                        child: () {
                          String tipo = widget.beer.iDBeerType?.name ?? '';
                          String ibus = widget.beer.iBUs.toString();
                          if (tipo == '' && ibus != '') {
                            return AutoSizeText('$ibus IBUs', minFontSize: 18);
                          }
                          if (ibus == '' && tipo != '') {
                            return AutoSizeText(tipo, minFontSize: 18);
                          }
                          return AutoSizeText('$tipo - $ibus IBUs',
                              minFontSize: 18);
                        }()),
                    Positioned(
                        top: 65,
                        child: SizedBox(
                            width: 150,
                            child: AutoSizeText(
                              widget.beer.description ?? '',
                              minFontSize: 14,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                              wrapWords: true,
                            ))),
                    Positioned(
                        bottom: 5,
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
