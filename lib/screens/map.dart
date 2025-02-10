import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:favourite_places_app/models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
      // default location of google offices would be used if no location is passed
      // If a location is passed then it would override the above location
    ),
    // to check whether this MapScreen is beind opened to select a location for the first time using (Select location on map button)
    // or display an already chosen location (isSelecting = false)
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick Your location' : 'Your location'),
        actions: [
          if (widget.isSelecting)
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
              label: Text('Save'),
            ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: GoogleMap(
        onTap: !widget.isSelecting
            ? null
            : (position) {
                setState(() {
                  _pickedLocation = position;
                });
              },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          zoom: 16,
        ),
        // A set of markers that cannot have duplicate values and just has a list of items
        // passing an empty set for no markers if no location is picked and if location is being selected
        // The second marker would be passed when displaying an already picked location from place_details screen
        // (using Get current location buttonn) as isSelecting would be false
        markers: (_pickedLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: MarkerId('m1'),
                  // If a new location is picked on map that is passed for marking else the current location got by default is sent for marking
                  // position: _pickedLocation != null
                  //     ? _pickedLocation!
                  //     : LatLng(
                  //         widget.location.latitude,
                  //         widget.location.longitude,
                  //       ),
                  // concise way of writing the above statement (if _pickedLocation isn't null then use it otherwise the latter value is used)
                  position: _pickedLocation ??
                      LatLng(
                        widget.location.latitude,
                        widget.location.longitude,
                      ),
                ),
              },
      ),
    );
  }
}
