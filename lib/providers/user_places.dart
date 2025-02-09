import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:favourite_places_app/models/place.dart';

Future<Database> _getDatabase() async {
  // dbPath points to a directory where the databases would be stored
  final dbPath = await sql.getDatabasesPath();
  // join() method is used to associate the database path(dbPath) with a particular database
  // It opens that database if it exists and creates a new one if it doesn't exist (ending with .db is necesaary)
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    // This onCreate function is executed when the database is created for the first time (used to create a table)
    onCreate: (db, version) {
      // execute() fn to execute an SQL query with no return value
      db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    // To retrieve data from database like SELECT
    final data = await db.query('user_places');
    // calling the map function for each map(row) in the List<Map> that represents a row
    final places = data
        .map(
          (row) => Place(
            passedId: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
                latitude: row['lat'] as double,
                longitude: row['lng'] as double,
                address: row['address'] as String),
          ),
        )
        .toList();

    state = places;
  }

  void addPlace(String title, File image, PlaceLocation location) async {
    // below line to store the path where the image will be stored
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    // basename() method is used to get the file name from the path
    final fileName = path.basename(image.path);
    // copying image to the appDir/fileName path using copy()
    final copiedImage = await image.copy('${appDir.path}/$fileName');

    final newPlace = Place(
      title: title,
      image: copiedImage,
      location: location,
    );

    // going to the databse path and connecting to it
    final db = await _getDatabase();

    // insert() fn to insert values in database
    db.insert(
      'user_places', // table_name
      {
        // Storing in (key) columns ((value) items
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );
    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
        (ref) => UserPlacesNotifier());
