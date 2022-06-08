import 'beercompany.dart';
import 'beertype.dart';

class Beer {
  final int id;
  BeerCompany? iDBeerCompany;
  BeerType? iDBeerType;
  int? iBUs;
  final String name;
  String? description;
  String? image;

  Beer(
      {required this.id,
      this.iDBeerCompany,
      this.iDBeerType,
      this.iBUs,
      required this.name,
      this.description,
      this.image});

  Beer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        iDBeerCompany = json['iDBeerCompany'] != null ? BeerCompany.fromJson(json['iDBeerCompany']) : null,
        iDBeerType = json['iDBeerType'] != null ? BeerType.fromJson(json['iDBeerType']) : null,
        iBUs = json['iBUs'],
        name = json['name'],
        description = json['description'],
        image = json['image'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'iDBeerCompany': iDBeerCompany?.toJson(),
        'iDBeerType': iDBeerType?.toJson() ,
        'iBUs': iBUs,
        'name': name,
        'description': description,
        'image': image
      };
}
