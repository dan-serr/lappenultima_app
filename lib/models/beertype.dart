class BeerType {
  final int id;
  final String name;

  BeerType({
    required this.id,
    required this.name
});

  BeerType.fromJson(Map<String, dynamic> json)
  : id = json['id'],
  name = json['name'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name
  };
}