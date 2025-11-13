import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/helpers/marker_helper.dart';
import '../../services/location_service.dart';
import '../../services/firebase_service.dart';

class MapScreen extends StatefulWidget {
  final String myId;
  final String myName;
  final String myAvatar;
  const MapScreen(
      {super.key,
      required this.myId,
      required this.myName,
      required this.myAvatar});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _loc = LocationService();
  final FirebaseService _fb = FirebaseService(); // يمكنك استبداله بمحاكاة
  final Map<String, Marker> _markers = {};
  GoogleMapController? _mapCtrl;
  StreamSubscription? _sub;

  static const initial =
      CameraPosition(target: LatLng(33.9716, -6.8498), zoom: 6.5);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // مثال: تحديث موقعي (تحتاج صلاحيات)
    try {
      // upload my position once (if available)
      // _fb.updateMyLocation(...)

      // listen to all users (firestore)
      _sub = _fb.streamAllUsersLocations().listen((users) async {
        final Map<String, Marker> newM = {};
        for (final u in users) {
          final id = u['userId'] as String;
          final lat = u['latitude'] as double;
          final lng = u['longitude'] as double;
          final avatar = u['avatarUrl'] as String? ?? '';
          BitmapDescriptor icon =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
          if (avatar.isNotEmpty) {
            icon = await MarkerHelper.fromNetworkImage(avatar, size: 110);
          }
          newM[id] = Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            icon: icon,
            infoWindow: InfoWindow(title: u['name']),
            onTap: () => _showUserBottom(u),
          );
        }
        setState(() {
          _markers
            ..clear()
            ..addAll(newM);
        });
      });
    } catch (e) {
      debugPrint('map start error: $e');
    }
  }

  void _showUserBottom(Map<String, dynamic> u) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: CircleAvatar(
                      backgroundImage: NetworkImage(u['avatarUrl'] ?? ''),
                      radius: 28),
                  title: Text(u['name'] ?? ''),
                  subtitle: Text("Open chat")),
              Row(children: [
                ElevatedButton(onPressed: () {}, child: const Text("Message")),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () {}, child: const Text("View"))
              ])
            ]),
          );
        });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Map")),
        body: GoogleMap(
            initialCameraPosition: initial,
            markers: _markers.values.toSet(),
            onMapCreated: (c) => _mapCtrl = c));
  }
}
