import 'dart:convert';

import 'package:atv_mobile/classes/Planet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'PlanetRow.dart';

Future<List<Planet>> fetchPlanets() async {
  final response = await http.get(Uri.parse('http://192.168.1.7:8080/planet'));

  if (response.statusCode == 200) {
    List<Planet> planets = [];
    List<dynamic> rawPlanets = jsonDecode(response.body)["_embedded"]["planet"];
    for (var i = 0; i < rawPlanets.length; i++) {
      planets.add(new Planet.fromJson(rawPlanets[i]));
    }
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return planets;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load planets');
  }
}

// ignore: must_be_immutable
class HomePageBody extends StatelessWidget {
  Future<List<Planet>> futurePlanets = fetchPlanets();

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        color: new Color(0xFF736AB7),
        child: new FutureBuilder<List<Planet>>(
          future: futurePlanets,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new CustomScrollView(
                scrollDirection: Axis.vertical,
                shrinkWrap: false,
                slivers: <Widget>[
                  new SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    sliver: new SliverList(
                      delegate: new SliverChildBuilderDelegate(
                        (context, index) =>
                            new PlanetRow(snapshot.data![index]),
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
