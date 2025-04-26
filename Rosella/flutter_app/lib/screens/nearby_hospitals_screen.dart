import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  List<dynamic> hospitals = [];
  bool isLoading = true;

  final String apiKey = 'AIzaSyCC5MUGTVyEycb-jlB1vr1fO973MkX4B6U';

  @override
  void initState() {
    super.initState();
    _fetchNearbyHospitals();
  }

  Future<void> _fetchNearbyHospitals() async {
    try {
      print('📍 Checking if location service is enabled...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      print('📍 Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('📍 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          throw Exception('Location permissions are denied.');
        }
      }

      print('📍 Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('✅ Got location: ${position.latitude}, ${position.longitude}');

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=5000'
        '&type=hospital'
        '&keyword=gynecologist'
        '&key=$apiKey',
      );

      print('🌐 Sending request to: $url');

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      print('📦 API response status: ${response.statusCode}');
      print('📦 API raw data: ${response.body}');

      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() {
          hospitals = data['results'];
          isLoading = false;
        });
        print('✅ Found ${hospitals.length} hospitals nearby.');
      } else {
        print('❌ API error or no hospitals found: ${data['status']}');
        throw Exception('No hospitals found nearby or API error.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('🔥 Exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: Color(0xFFE75A7C),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hospitals.isEmpty
              ? const Center(child: Text('No hospitals found nearby.'))
              : ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(
                          Icons.local_hospital,
                          color: Colors.pink,
                        ),
                        title: Text(hospital['name'] ?? 'Unnamed'),
                        subtitle: Text(
                          hospital['vicinity'] ?? 'Unknown location',
                        ),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          // future enhancement: open Google Maps or call the hospital
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
