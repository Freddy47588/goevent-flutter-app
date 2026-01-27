import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationData {
  final double lat;
  final double lng;
  final String city;
  final String addressLine;

  const UserLocationData({
    required this.lat,
    required this.lng,
    required this.city,
    required this.addressLine,
  });
}

class LocationService {
  final _controller = StreamController<UserLocationData>.broadcast();
  Stream<UserLocationData> get stream => _controller.stream;

  StreamSubscription<Position>? _sub;
  DateTime _lastSaved = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> start() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception('Location service OFF');

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever');
    }

    _sub?.cancel();
    _sub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 30, // update setiap pindah ~30m
          ),
        ).listen((pos) async {
          final placemarks = await placemarkFromCoordinates(
            pos.latitude,
            pos.longitude,
          );
          final p = placemarks.isNotEmpty ? placemarks.first : null;

          final city = (p?.locality ?? p?.subAdministrativeArea ?? '').trim();
          final address = [
            p?.street,
            p?.subLocality,
            p?.locality,
          ].where((e) => (e ?? '').trim().isNotEmpty).join(', ');

          final data = UserLocationData(
            lat: pos.latitude,
            lng: pos.longitude,
            city: city.isEmpty ? 'Unknown' : city,
            addressLine: address.isEmpty ? 'Unknown address' : address,
          );

          _controller.add(data);
          await _saveToFirestore(data);
        });
  }

  Future<void> _saveToFirestore(UserLocationData data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // hemat write: simpan maksimal tiap 2 menit
    final now = DateTime.now();
    if (now.difference(_lastSaved).inSeconds < 120) return;
    _lastSaved = now;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'lastLat': data.lat,
      'lastLng': data.lng,
      'lastCity': data.city,
      'lastAddress': data.addressLine,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    _controller.close();
  }
}
