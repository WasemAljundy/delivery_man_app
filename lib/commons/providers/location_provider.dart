import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package

class LocationProvider with ChangeNotifier {
  final SharedPreferences? sharedPreferences;

  LocationProvider({required this.sharedPreferences});

  Placemark _address = Placemark();
  Placemark get address => _address;

  Position _currentLocation = Position(
    latitude: 0,
    longitude: 0,
    speed: 1,
    speedAccuracy: 1,
    altitude: 1,
    accuracy: 1,
    heading: 1,
    timestamp: DateTime.now(),
    altitudeAccuracy: 1,
    headingAccuracy: 1,
  );
  Position get currentLocation => _currentLocation;

  // Method to check and request location permissions
  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  // Method to get user's location with permission check
  Future<Position> locateUser() async {
    bool hasPermission = await _requestLocationPermission();
    if (hasPermission) {
      // If permission is granted, get the current location
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      // If permission is not granted, throw an error or handle accordingly
      throw PermissionDeniedException('Location permission denied');
    }
  }

  // Method to get and update user's location
  void getUserLocation() async {
    try {
      _currentLocation = await locateUser();
      var currentAddresses = await placemarkFromCoordinates(_currentLocation.latitude, _currentLocation.longitude);
      _address = currentAddresses.first;
      notifyListeners(); // Notify listeners to update UI with new location
    } catch (e) {
      // Handle errors, e.g., show a message or request permission
      print('Error: $e');
    }
  }
}

// Custom exception for permission denial
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => message;
}
