import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favourite_places_app/models/place.dart';
import 'package:favourite_places_app/widgets/image_input.dart';
import 'package:favourite_places_app/widgets/location_input.dart';
import 'package:favourite_places_app/providers/user_places.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  void _savePlace() {
    final enteredTitle = _titleController.text.trim();

    if (enteredTitle.isEmpty ||
        _selectedImage == null ||
        _selectedLocation == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Error',
            style: TextStyle(
              color: Colors.black, // Ensure the title text is readable
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please enter a title, pick an image and a location before adding a place.',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _selectedImage!, _selectedLocation!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // Whenever using a TextEditingController use dispose()
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title', // alternative to add label
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ImageInput(
              onPickImage: (image) {
                // Passing the image from the child widget to the parent widget
                // This anonymous fn is getting executed when it is being called in the child class ImageInput
                // and the Image in brackets (image) which is _selectedImage in ImageInput is being assigned to
                // _selectedImage of here i.e. _AddPlaceScreenState class
                // no setState() needed as no UI is being updated
                _selectedImage = image;
              },
            ),
            SizedBox(
              height: 16,
            ),
            LocationInput(
              // Passing the PlaceLocation object location from the child LocationInput widget to this parent widget
              onSelectLocation: (location) {
                _selectedLocation = location;
              },
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: ElevatedButton.icon(
                label: Text('Add place'),
                icon: Icon(Icons.add),
                onPressed: _savePlace,
              ),
            )
          ],
        ),
      ),
    );
  }
}
