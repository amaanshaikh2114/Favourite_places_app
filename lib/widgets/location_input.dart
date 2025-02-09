import 'dart:convert';

import 'package:favourite_places_app/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'package:favourite_places_app/models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({
    super.key,
    required this.onSelectLocation,
  });

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    // Using Google static maps API to get snapshot of maps and location
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDKUg_PJ2tpSfu-KRFkpt22D_vELR6mNYY';
  }

  Future<void> _savPlace(double latitude, double longitude) async {
    // parse() is used to take the whole url unlike https() which only takes the domain name onwards url after https://
    // Using Google Geoencoding API to convert latitude and longitude to addresses and vice versa
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyDKUg_PJ2tpSfu-KRFkpt22D_vELR6mNYY');
    // Getting response from above url using http.get()
    final response = await http.get(url);
    // Converting json object to map
    final resData = json.decode(response.body);
    // accessing redData maps' results' key's first list which is a map and then accessing the maps' formatted_address key
    final address = resData['results'][0]['formatted_address'];
    // Above line gives the human readable address

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });
    // A way of passing the value from child widget LocationInput to _AddPlaceScreenState widget
    widget.onSelectLocation(_pickedLocation!);
  }

  void _getCurrentlocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      // can show error dialog here later
      return;
    }

    _savPlace(lat, lng);
  }

  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savPlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location selected',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_isGettingLocation) {
      previewContent = CircularProgressIndicator();
    }

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Get current location'),
              onPressed: _getCurrentlocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: Text('Select location on map'),
              onPressed: _selectOnMap,
            ),
          ],
        )
      ],
    );
  }
}
