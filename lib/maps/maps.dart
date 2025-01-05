// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MapsUtils {
  MapsUtils._();

  // Latitude and Longitude
  static Future<void> openMapWithPosition(
      double latitude, double longitude) async {
    final googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      // Handle the case where the map couldn't be opened
      print("Could not open the map with position.");
    }
  }

  // Text address
  static Future<void> openMapWithAddress(String fullAddress) async {
    final query = Uri.encodeComponent(fullAddress);
    final googleMapUrl =
        "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      // Handle the case where the map couldn't be opened
      print("Could not open the map with address: $fullAddress");
    }
  }
}
