import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favourite_places_app/models/place.dart';
import 'package:favourite_places_app/providers/user_places.dart';
import 'package:favourite_places_app/screens/map.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.place,
  });

  final Place place;

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen> {
  String get locationImage {
    final lat = widget.place.location.latitude;
    final lng = widget.place.location.longitude;
    // Using Google static maps API to get snapshot of maps and location
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=YOUR_GOOGLE_API_KEY';
  }

  void _removePlace() {
    // Capture the parent (details screen) context.
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 221, 215, 222),
        title: Text(
          'Delete this location?',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this location?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // "Yes" Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 221, 215, 222),
              side: BorderSide(
                color: Theme.of(parentContext).primaryColor,
              ),
            ),
            onPressed: () {
              // Delete the place
              ref.read(userPlacesProvider.notifier).deletePlace(widget.place);
              // First, pop the dialog...
              Navigator.of(dialogContext).pop();
              // ...then pop the details screen to return home.
              Navigator.of(parentContext).pop();
            },
            child: Text(
              'Yes',
              style: TextStyle(
                color: Theme.of(parentContext).primaryColor,
              ),
            ),
          ),
          // "No" Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // just pop the dialog
            },
            child: Text(
              'No',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.title),
        actions: [
          IconButton(
            onPressed: _removePlace,
            icon: Icon(Icons.delete),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        // Image.file() used to show an image generally
        children: [
          Image.file(
            widget.place.image,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => MapScreen(
                          location: widget.place.location,
                          isSelecting:
                              false, // not selecting a new place rather just showing the already selected place
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(locationImage),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color.fromARGB(255, 0, 0, 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    widget.place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
