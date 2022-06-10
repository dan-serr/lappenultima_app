import 'dart:convert';

import 'package:lappenultima_app/models/bartype.dart';
import 'package:lappenultima_app/models/user.dart';

import 'beer.dart';

class Bar {
  final int id;
  User? owner;
  String? image;
  BarType? iDBarType;
  List<Beer>? beers;
  final String name;
  String? description;
  String? pluscode;
  String? direction;

  Bar(
      {required this.id,
      this.owner,
      this.image,
      this.iDBarType,
      this.beers,
      required this.name,
      this.description,
      this.pluscode,
      this.direction});

  Bar.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        owner = json['owner'] != null ? User.fromJson(json['owner']) : null,
        image = json['image'],
        iDBarType = json['iDBarType'] != null
            ? BarType.fromJson(json['iDBarType'])
            : null,
        beers = _extractBeers(json),
        name = json['name'],
        description = json['description'],
        pluscode = json['pluscode'],
        direction = json['direction'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner': owner?.toJson(),
        'iDBarType': iDBarType?.toJson(),
        'beers': jsonEncode(beers),
        'name': name,
        'description': description,
        'pluscode': pluscode,
        'direction': direction
      };

  static _extractBeers(Map<String, dynamic> json) {
    final beersJson = json['beers'];
    List<Beer> beers = <Beer>[];
    beersJson.forEach((beer) {
      beers.add(Beer.fromJson(beer));
    });
    return beers;
  }
}
