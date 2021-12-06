import 'dart:async';

import 'package:geofence_service/geofence_service.dart';
import 'package:monitorlibrary/api/data_api.dart';
import 'package:monitorlibrary/api/local_mongo.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/data/geofence_event.dart';
import 'package:monitorlibrary/data/project_position.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/location/loc_bloc.dart';
import 'package:uuid/uuid.dart';

final GeofencerTwo geofencerTwo = GeofencerTwo();

class GeofencerTwo {
  static const mm = '💦 💦 💦 💦 💦 GeofencerTwo: 💦 💦 ';
  late GeofenceService _geofenceService;
  User? _user;
  Future initialize() async {
    pp('$mm Create a [GeofenceService] instance and set options.....');
    _geofenceService = GeofenceService.instance.setup(
        interval: 5000,
        accuracy: 100,
        loiteringDelayMs: 10000,
        statusChangeDelayMs: 10000,
        useActivityRecognition: true,
        allowMockLocations: false,
        printDevLog: false,
        geofenceRadiusSortType: GeofenceRadiusSortType.DESC);
    pp('$mm GeofenceService initialized .... 🌺 🌺 🌺 ');
    _user = await Prefs.getUser();
    if (_user != null) {
      pp('$mm Geofences for Organization: ${_user!.organizationId} name: ${_user!.organizationName} .... 🌺 🌺 🌺 ');
      pp('$mm Geofences for User: ${_user!.toJson()}');
    }
  }

  Future<List<ProjectPosition>> _getProjectPositionsByLocation(
      {required String organizationId,
      required double latitude,
      required double longitude,
      required double radiusInKM}) async {
    var list = await LocalMongo.getOrganizationProjectPositionsByLocation(
        organizationId: organizationId,
        latitude: latitude,
        longitude: longitude,
        radiusInKM: radiusInKM);

    if (list.isEmpty) {
      list = await DataAPI.getOrganizationProjectPositions(organizationId);
    }
    pp('\n\n$mm _getProjectPositionsByLocation: found ${list.length}\n\n');
    return list;
  }

  final _geofenceList = <Geofence>[];
  Future buildGeofences({double? radiusInKM}) async {
    if (_user == null) {
      return;
    }
    pp('\n\n$mm buildGeofences .... build geofences for the organization 🌀 ${_user!.organizationName}  🌀 \n\n');
    var loc = await locationBloc.getLocation();
    var list = await _getProjectPositionsByLocation(
        organizationId: _user!.organizationId!,
        latitude: loc.latitude,
        longitude: loc.longitude,
        radiusInKM: radiusInKM == null ? defaultRadiusInKM : radiusInKM);

    for (var pos in list) {
      await addGeofence(projectPosition: pos);
    }

    pp("$mm 😡 😡 😡 😡 😡 😡 😡 😡 😡  Geofence.startListening with instance of 💠 GeofenceStatusChangeListener 💠 ");
    _geofenceService.addGeofenceList(_geofenceList);
    _geofenceService.addGeofenceStatusChangeListener(
        (geofence, geofenceRadius, geofenceStatus, location) async {
      pp('\n\n\n$mm 🔆 🔆 🔆 🔆 🔆 🔆 🔆 🔆 GeofenceStatusChangeListener 💠 FIRED!! 🔵 🔵 🔵 🔵 🔵  id: ${geofence.id} 🔵 ');
      await _processGeofenceEvent(
          geofence: geofence,
          geofenceRadius: geofenceRadius,
          geofenceStatus: geofenceStatus,
          location: location);
    });
    try {
      pp('$mm  🔶  🔶 Starting GeofenceService ...... 🔶  🔶  🔶 ');
      await _geofenceService.start().onError((error, stackTrace) => {
            pp('🔴 🔴 🔴 🔴 🔴 🔴 GeofenceService really failed to start, onError: 🔴 $error 🔴 }')
          });
      pp('$mm  ✅ ✅ ✅ GeofenceService 🍐🍐🍐 STARTED 🍐🍐🍐; '
          '✅  🔆 🔆 🔆 🔆 🔆 🔆  waiting for status change.... 🔵 🔵 🔵 🔵 🔵 ');
    } catch (e) {
      pp('🔴 🔴 🔴 🔴 🔴 🔴 GeofenceService failed to start: 🔴 $e 🔴 }');
    }
  }

  void onError() {}

  Future _processGeofenceEvent(
      {required Geofence geofence,
      required GeofenceRadius geofenceRadius,
      required GeofenceStatus geofenceStatus,
      required Location location}) async {

    var projectPosition = await LocalMongo.getProjectPosition(geofence.id);
    if (projectPosition == null) {
      return;
    }
    pp('$mm  🔵 🔵 🔵 🔵 🔵 _processing new GeofenceEvent at  🔵 ${projectPosition.projectName} 🔵 with geofenceStatus: ${geofenceStatus.toString()}');

    var event = GeofenceEvent(
        status: geofenceStatus.toString(),
        userId: _user!.userId,
        user: _user,
        geofenceEventId: Uuid().v4(),
        projectPositionId: geofence.id,
        projectName: projectPosition.projectName,
        date: DateTime.now().toIso8601String());
    _geofenceStreamController.sink.add(event);
    String status = geofenceStatus.toString();
    switch (status) {
      case 'GeofenceStatus.ENTER':
        event.status = 'ENTER';
        await DataAPI.addGeofenceEvent(event);
        break;
      case 'GeofenceStatus.DWELL':
        event.status = 'DWELL';
        await DataAPI.addGeofenceEvent(event);
        break;
      case 'GeofenceStatus.EXIT':
        event.status = 'EXIT';
        await DataAPI.addGeofenceEvent(event);
        break;
    }

  }

  Future addGeofence({required ProjectPosition projectPosition}) async {
    var fence = Geofence(
      id: projectPosition.projectPositionId!,
      latitude: projectPosition.position!.coordinates[1],
      longitude: projectPosition.position!.coordinates[0],
      radius: [
        // GeofenceRadius(id: 'radius_100m', length: 100),
        // GeofenceRadius(id: 'radius_25m', length: 50),
        GeofenceRadius(id: 'radius_200m', length: defaultRadiusInMetres),
      ],
    );

    _geofenceList.add(fence);
    pp('$mm added Geofence .... 👽👽👽👽👽 id: ${fence.id} 👽👽 _geofenceList now has ${_geofenceList.length} fences 🍎 ');
  }

  StreamController<GeofenceEvent> _geofenceStreamController = StreamController.broadcast();
  Stream<GeofenceEvent> get geofenceStream => _geofenceStreamController.stream;

  var defaultRadiusInKM = 100.0;
  var defaultRadiusInMetres = 150.0;
  var defaultDwellInMilliSeconds = 30;

  close() {
    _geofenceStreamController.close();
  }
}
