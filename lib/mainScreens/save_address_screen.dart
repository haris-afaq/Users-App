// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../global/global.dart';
import '../models/address.dart';
import '../widgets/simple_app_bar.dart';
import '../widgets/text_field.dart';

class SaveAddressScreen extends StatelessWidget {
  final _name = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _flatNumber = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _completeAddress = TextEditingController();
  final _locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Placemark>? placemarks;
  Position? position;

  getUserLocationAddress() async {
    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Handle permission denied gracefully
          return;
        }
      }

      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      position = newPosition;

      placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);

      if (placemarks != null && placemarks!.isNotEmpty) {
        Placemark pMark = placemarks![0];

        String fullAddress =
            '${pMark.thoroughfare} ${pMark.subThoroughfare}, ${pMark.locality} ${pMark.subLocality}, ${pMark.administrativeArea}, ${pMark.subAdministrativeArea} ${pMark.postalCode}, ${pMark.country}';

        _locationController.text = fullAddress;

        _flatNumber.text =
            '${pMark.thoroughfare} ${pMark.subThoroughfare}, ${pMark.locality} ${pMark.subLocality}';

        _city.text =
            '${pMark.administrativeArea}, ${pMark.subAdministrativeArea} ${pMark.postalCode}';

        _state.text = '${pMark.country}';

        _completeAddress.text = fullAddress;
      }
    } catch (e) {
      // Handle exceptions (e.g., Geolocator or Geocoding errors) here
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: "iFood",
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Save Now"),
        icon: const Icon(Icons.save),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            final model = Address(
              name: _name.text.trim().toString(),
              state: _state.text.trim().toString(),
              fullAddress: _completeAddress.text.trim().toString(),
              phoneNumber: _phoneNumber.text.trim().toString(),
              flatNumber: _flatNumber.text.trim().toString(),
              city: _city.text.trim().toString(),
              lat: position!.latitude,
              lng: position!.longitude,
            ).toJson();

            FirebaseFirestore.instance
                .collection("users")
                .doc(sharedPreferences!.getString("uid"))
                .collection("userAddress")
                .doc(DateTime.now().millisecondsSinceEpoch.toString())
                .set(model)
                .then((value) {
              Fluttertoast.showToast(msg: "New Address has been saved.");
              formKey.currentState!.reset();
            });
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 6,
            ),
            const Align(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Save New Address:",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person_pin_circle,
                color: Colors.black,
                size: 35,
              ),
              title: Container(
                width: 250,
                child: TextField(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: "What's your address?",
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            ElevatedButton.icon(
              label: const Text(
                "Get my Location",
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.cyan),
                  ),
                ),
              ),
              onPressed: () {
                // getCurrentLocationWithAddress();
                getUserLocationAddress();
              },
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "Name",
                    controller: _name,
                  ),
                  MyTextField(
                    hint: 'Phone Number',
                    controller: _phoneNumber,
                  ),
                  MyTextField(
                    hint: 'City',
                    controller: _city,
                  ),
                  MyTextField(
                    hint: 'State / Country',
                    controller: _state,
                  ),
                  MyTextField(
                    hint: 'Address Line',
                    controller: _flatNumber,
                  ),
                  MyTextField(
                    hint: 'Complete Address',
                    controller: _completeAddress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
