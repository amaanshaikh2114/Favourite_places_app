import 'package:uuid/uuid.dart';
import 'dart:io';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({
    required this.title,
    required this.image,
    required this.location,
    String? passedId,
  }) : id = passedId ?? uuid.v4();
  // ?? checks if null and if passed is null then dynamic id is generated
  // If passedId is not null and passed then assign it to id

  final String id;
  final String title;
  final File image;
  final PlaceLocation location;
}
