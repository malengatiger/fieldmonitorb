import 'dart:async';
import 'dart:math';

import 'package:fieldmonitor3/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/project_position.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';

class MonitorMap extends StatefulWidget {
  @override
  _MonitorMapState createState() => _MonitorMapState();
}

class _MonitorMapState extends State<MonitorMap>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<ProjectPosition> projectPositions = [];
  List<Project> projects = [];
  User user;
  bool isBusy = false;
  GoogleMapController googleMapController;

  BitmapDescriptor markerIcon =
      BitmapDescriptor.fromAsset('assets/mapicons/construction.png');

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();
  }

  void _getUser() async {
    setState(() {
      isBusy = true;
    });
    user = await Prefs.getUser();
    pp('🍎 🍎 🍎 user found: 🍎 ${user.name}');
    setState(() {
      isBusy = false;
    });
    _getData();
  }

  void _getData() async {
    setState(() {
      isBusy = true;
    });
    user = await Prefs.getUser();
    projects = await monitorBloc.getOrganizationProjects(
        organizationId: user.organizationId);

    for (var i = 0; i < projects.length; i++) {
      var pos = await monitorBloc.getProjectPositions(
          projectId: projects.elementAt(i).projectId);
      projectPositions.addAll(pos);
    }

    pp('💜 💜 💜 Project positions found: 🍎 ${projectPositions.length}');
    _addMarkers();
    setState(() {
      isBusy = false;
    });
  }

  Completer<GoogleMapController> _mapController = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  var random = Random(DateTime.now().millisecondsSinceEpoch);

  Future<void> _addMarkers() async {
    pp('💜 💜 💜 _addMarkers ....... 🍎 ${projectPositions.length}');
    markers.clear();
    projectPositions.forEach((projectPosition) {
      final MarkerId markerId =
          MarkerId('${projectPosition.projectId}_${random.nextInt(9999988)}');
      final Marker marker = Marker(
        markerId: markerId,
        // icon: markerIcon,
        position: LatLng(
          projectPosition.position.coordinates.elementAt(1),
          projectPosition.position.coordinates.elementAt(0),
        ),
        infoWindow:
            InfoWindow(title: projectPosition.projectName, snippet: '*'),
        onTap: () {
          _onMarkerTapped(projectPosition);
        },
        onDragEnd: (LatLng position) {
          _onMarkerDragEnd(projectPosition, position);
        },
      );
      markers[markerId] = marker;
    });
    final CameraPosition _first = CameraPosition(
      target: LatLng(
          projectPositions.elementAt(0).position.coordinates.elementAt(1),
          projectPositions.elementAt(0).position.coordinates.elementAt(0)),
      zoom: 14.4746,
    );
    googleMapController = await _mapController.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(_first));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: [
          isBusy
              ? Scaffold(
                  appBar: AppBar(
                    title: Text('Project Map'),
                    bottom: PreferredSize(
                      child: Column(
                        children: [
                          Text(
                            user == null ? '' : user.name,
                            style: Styles.whiteBoldSmall,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(user == null ? '' : user.organizationName,
                              style: Styles.blackBoldSmall),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                      preferredSize: Size.fromHeight(200),
                    ),
                  ),
                  body: Center(
                    child: Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 8,
                            backgroundColor: Colors.black,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Loading Project Data ...'),
                        ],
                      ),
                    ),
                  ),
                )
              : GoogleMap(
                  mapType: MapType.hybrid,
                  mapToolbarEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    googleMapController = controller;
                  },
                  myLocationEnabled: true,
                  onLongPress: _onLongPress,
                  markers: Set<Marker>.of(markers.values),
                ),
          Positioned(
            left: 8,
            top: 40,
            child: Card(
              elevation: 16,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      user == null ? '' : user.organizationName,
                      style: Styles.blackBoldSmall,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Text('Project Points', style: Styles.greyLabelSmall),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${projectPositions.length}',
                          style: Styles.blackBoldMedium,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _getData,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  // Future<void> _goToTheLake() async {
  //   pp('');
  //   final GoogleMapController controller = await _mapController.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

  void _onLongPress(LatLng argument) {
    pp('🔆🔆🔆 _onLongPress ,,,,,,,, $argument');
  }

  void _onMarkerTapped(ProjectPosition projectPosition) {
    pp('💜 💜 💜 _onMarkerTapped ....... ${projectPosition.projectName}');
  }

  void _onMarkerDragEnd(ProjectPosition projectPosition, LatLng position) {
    pp('💜 💜 💜 _onMarkerDragEnd ....... ${projectPosition.projectName} LatLng: $position');
  }
}
