class BeerCompany {
  final int id;
  final String name;
  String? country;

  BeerCompany({
    required this.id,
    required this.name,
    this.country
  });

  BeerCompany.fromJson(Map<String, dynamic> json)
  : id = json['id'],
  name = json['name'],
  country = json['country'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country
  };
}