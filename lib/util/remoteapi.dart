import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lappenultima_app/util/constants.dart' as constants;
import 'package:lappenultima_app/models/beer.dart';
import 'package:http/http.dart' as http;

import '../models/bar.dart';

class RemoteApi {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  //Fetchs para paginador
  static Future<List<Beer>> fetchBeers(int offset, int size,
      [String? searchTerm]) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ODZlNWZmMmMtNWNiYi00MzE1LTg4YjYtMjFmZjhiMmU1NTY3'
    };
    searchTerm ??= '';
    http.Request request;
    request = http.Request(
        'GET',
        Uri.parse(
            '${constants.ip}/rest/queries/BeerDatum/beerFilterName?name=$searchTerm&limit=$size&offset=$offset'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List<dynamic> iterable =
          jsonDecode(await response.stream.bytesToString());
      List<Beer> beers =
          List<Beer>.from(iterable.map((model) => Beer.fromJson(model)));
      return beers;
    } else {
      return <Beer>[];
    }
  }

  static Future<List<Bar>> fetchBars(int offset, int size,
      [String? searchTerm]) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ODZlNWZmMmMtNWNiYi00MzE1LTg4YjYtMjFmZjhiMmU1NTY3'
    };
    searchTerm ??= '';
    http.Request request;
    request = http.Request(
        'GET',
        Uri.parse(
            '${constants.ip}/rest/queries/BarDatum/barFilterName?name=$searchTerm&limit=$size&offset=$offset'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      List<dynamic> iterable =
          jsonDecode(await response.stream.bytesToString());
      List<Bar> bars =
          List<Bar>.from(iterable.map((model) => Bar.fromJson(model)));
      return bars;
    } else {
      return <Bar>[];
    }
  }

  //Beers
  static Future<bool> isBeerFav(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/fav/beer/$user/$beer'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    return await response.stream.bytesToString() == 'true';
  }

  static Future<bool> isBeerRated(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request = http.Request(
        'GET', Uri.parse('${constants.ip}/rating/beer/$user/$beer'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return await response.stream.bytesToString() == 'true';
  }

  static Future<int> getBeerRating(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {'Authorization': 'Bearer $accessToken'};
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/beer/$beer'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      if (res == '') {
        return 0;
      }
      return int.parse(res);
    } else {
      print(response.reasonPhrase);
    }
    return 0;
  }

  static Future<void> postBeerFav(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ZTI5MjI1MDctMTk5Yi00YTBlLWIyNmUtMGFhYzA5YWE0MGFm'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${constants.ip}/fav/beer/$user/$beer'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> postBeerRating(int beer, int rating,
      [String? opinion]) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request = http.Request(
        'POST', Uri.parse('${constants.ip}/rest/entities/BeerRating/'));
    request.body = json.encode({
      "id": {"iDUser": "$user", "iDBeer": beer},
      "iDUser": {"id": "$user"},
      "iDBeer": {"id": beer},
      "rating": rating,
      "opinion": "$opinion"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> deleteBeerFav(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request = http.Request(
        'DELETE', Uri.parse('${constants.ip}/fav/beer/$user/$beer'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> deleteBeerRating(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request = http.Request(
        'DELETE', Uri.parse('${constants.ip}/rating/beer/$user/$beer'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(await response.stream.bytesToString());
  }

  static Future<Beer?> getBeerMostRated() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=MDY3Y2IzNmMtMGEyNC00YWM0LTk3NjEtZTBkNDdmZjBlNzFk'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/beer/mostRated'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return Beer.fromJson(jsonDecode(await response.stream.bytesToString()));
    }
    return null;
  }

  //Bars
  static Future<bool> isBarFav(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/fav/bar/$user/$bar'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    return await response.stream.bytesToString() == 'true';
  }

  static Future<bool> isBarRated(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/bar/$user/$bar'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    return await response.stream.bytesToString() == 'true';
  }

  static Future<int> getBarRating(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {'Authorization': 'Bearer $accessToken'};
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/bar/$bar'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      if (res == '') {
        return 0;
      }
      return int.parse(res);
    } else {
      print(response.reasonPhrase);
    }
    return 0;
  }

  static Future<void> postBarFav(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ZTI5MjI1MDctMTk5Yi00YTBlLWIyNmUtMGFhYzA5YWE0MGFm'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${constants.ip}/fav/bar/$user/$bar'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> postBarRating(int bar, int rating,
      [String? opinion]) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request = http.Request(
        'POST', Uri.parse('${constants.ip}/rest/entities/BarRating/'));
    request.body = json.encode({
      "id": {"iDUser": "$user", "iDBar": bar},
      "iDUser": {"id": "$user"},
      "iDBar": {"id": bar},
      "rating": rating,
      "opinion": "$opinion"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> deleteBarFav(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request =
        http.Request('DELETE', Uri.parse('${constants.ip}/fav/bar/$user/$bar'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> deleteBarRating(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request = http.Request(
        'DELETE', Uri.parse('${constants.ip}/rating/bar/$user/$bar'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(await response.stream.bytesToString());
  }

  static void logoutAction() async {
    //await _secureStorage.delete(key: 'user_id'); //No se borra para evitar que se quede a null: que se sobrescriba cuando entre uno nuevo TO FIX
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  static Future<List<Bar>> getBarsWithBeer(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=MjMxNjI4OWMtYTNlZC00YmJkLTg3MDgtNTdmZmRiYWViZDM0'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            '${constants.ip}/rest/queries/BarDatum/barsWithBeer?beer=$beer&limit=10'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> iterable =
          jsonDecode(await response.stream.bytesToString());
      List<Bar> bars =
          List<Bar>.from(iterable.map((model) => Bar.fromJson(model)));
      return bars;
    } else {
      return <Bar>[];
    }
  }

  static Future<Bar?> getBarMostRated() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=MDY3Y2IzNmMtMGEyNC00YWM0LTk3NjEtZTBkNDdmZjBlNzFk'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/bar/mostRated'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return Bar.fromJson(jsonDecode(await response.stream.bytesToString()));
    }
    return null;
  }
}
