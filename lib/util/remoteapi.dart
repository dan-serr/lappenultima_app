import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lappenultima_app/util/constants.dart' as constants;
import 'package:lappenultima_app/models/beer.dart';
import 'package:http/http.dart' as http;

class RemoteApi {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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

  /*
  static Future<List<Bar>> fetchBars(int offset, int size, [String? searchTerm]) async { //TODO
    }*/

  static Future<bool> getBeerFav(int beer) async {
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

  static Future<bool> getBarFav(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/fav/bar/$user'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    return await response.stream.bytesToString() == 'true';
  }

  static Future<bool> getBeerRating(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/beer/$user'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    return await response.stream.bytesToString() == 'true';
  }

  static Future<bool> getBarRating(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=M2U5OGFkYmEtOTgwMy00MWY2LTk4ZjMtNjQ0ZGFlMzFlNWE0'
    };
    var request =
        http.Request('GET', Uri.parse('${constants.ip}/rating/bar/$user'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    return await response.stream.bytesToString() == 'true';
  }

  static Future<void> postBeerFav(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ZTI5MjI1MDctMTk5Yi00YTBlLWIyNmUtMGFhYzA5YWE0MGFm'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${constants.ip}/fav/beer/$user/$beer'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> postBarFav(int bar) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=ZTI5MjI1MDctMTk5Yi00YTBlLWIyNmUtMGFhYzA5YWE0MGFm'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${constants.ip}/fav/bar/$user/$bar'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }

  static Future<void> postBeerRating(int beer, int rating, [String? opinion]) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request = http.Request('POST', Uri.parse('${constants.ip}/rest/entities/BeerRating/'));
    request.body = json.encode({
      "id": {
        "iDUser": "$user",
        "iDBeer": beer
      },
      "iDUser": {
        "id": "$user"
      },
      "iDBeer": {
        "id": beer
      },
      "rating": rating,
      "opinion": "$opinion"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }

  static Future<void> postBarRating(int bar) async {}

  static Future<void> deleteBeerFav(int beer) async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? user = await _secureStorage.read(key: 'user_id');
    var headers = {
      'Authorization': 'Bearer $accessToken',
      //'Cookie': 'SESSION=YmNlODIzMzEtMzhkOS00OWMyLWE2MzQtZjkwNGJkZTQwNWE5'
    };
    var request = http.Request('DELETE', Uri.parse('${constants.ip}/fav/beer/$user/$beer'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }

  static Future<void> deleteBarFav(int bar) async {

  }

  static Future<void> deleteBeerRating(int beer) async {}

  static Future<void> deleteBarRating(int bar) async {}
}
