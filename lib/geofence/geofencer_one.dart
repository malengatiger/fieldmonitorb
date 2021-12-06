import 'dart:async';

import 'package:flutter_geofence/geofence.dart';
import 'package:monitorlibrary/api/data_api.dart';
import 'package:monitorlibrary/api/local_mongo.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/data/project_position.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'dart:async';

import 'package:monitorlibrary/location/loc_bloc.dart';

final GeofencerOne geofencerOne = GeofencerOne();
class GeofencerOne {
  static const mm = ' ☘️ ☘️ ☘️ Geofencer  ☘️ ☘️ ☘️: ';
  User? _user;
  Future initialize() async {
    Geofence.initialize();
    pp('$mm Geofence initialized ....');
    _requestPermissions();
    _user = await Prefs.getUser();
    pp('$mm Geofence initialized .... user: ${_user!.toJson()}');

  }

  Future _requestPermissions() async {
    Geofence.requestPermissions();
    pp('$mm Geofence requestPermissions executed ....');
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

      await addGeolocation(position: pos);
    }

    pp("$mm 😡 😡 😡 😡 😡 😡 😡 😡 😡  Geofence.startListening ...");
    Geofence.startListening(GeolocationEvent.entry, (entry) {
      pp("$mm 😡 😡 😡 Entry of a georegion: Welcome to: 😡 😡 😡  ${entry.id}");
    });
  }

  Future addGeolocation({required ProjectPosition position}) async {
    pp("$mm 🔵 🔵 🔵 🔵  addGeolocation  ... projectName: ${position.projectName} ....");
    Geolocation geolocation = Geolocation(
        latitude: position.position!.coordinates[1]!,
        longitude: position.position!.coordinates[0]!,
        radius: defaultRadiusInMetres,
        id: position.projectPositionId!);

    await  Geofence.addGeolocation(geolocation, GeolocationEvent.entry).catchError((error) {
      pp("🔴 🔴 🔴 🔴 ProjectPosition geofence failed with $error 🔴 projectPositionId:  ${position.projectPositionId}");
    });

    pp("$mm ProjectPosition:🥬  🥬  🥬 project: ${position.projectName} geofence has been added!  🥬 projectPositionId:  ${position.projectPositionId}");
    return true;
  }
}

var defaultRadiusInKM = 100.0;
var defaultRadiusInMetres = 200.0;
