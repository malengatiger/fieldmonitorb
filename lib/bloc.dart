import 'dart:async';

import 'package:monitorlibrary/api/data_api.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/data/community.dart';
import 'package:monitorlibrary/data/country.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/questionnaire.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/location/loc_bloc.dart';

final MonitorBloc monitorBloc = MonitorBloc();

class MonitorBloc {
  MonitorBloc() {
    _initialize();
  }

  User _user;
  User get user => _user;
  StreamController<List<Community>> _reportController =
      StreamController.broadcast();
  StreamController<List<Community>> _communityController =
      StreamController.broadcast();
  StreamController<List<Questionnaire>> _questController =
      StreamController.broadcast();
  StreamController<List<Project>> _projController =
      StreamController.broadcast();
  StreamController<List<Country>> _countryController =
      StreamController.broadcast();
  StreamController<Questionnaire> _activeQuestionnaireController =
      StreamController.broadcast();
  StreamController<User> _activeUserController = StreamController.broadcast();

  Stream get reportStream => _reportController.stream;
  Stream get settlementStream => _communityController.stream;
  Stream get questionnaireStream => _questController.stream;
  Stream get projectStream => _projController.stream;
  Stream get countryStream => _countryController.stream;
  Stream get activeUserStream => _activeUserController.stream;
  Stream get usersStream => _userController.stream;
  Stream get activeQuestionnaireStream => _activeQuestionnaireController.stream;

  StreamController<List<User>> _userController = StreamController.broadcast();
  List<Community> _communities = List();
  List<Questionnaire> _questionnaires = List();
  List<Project> _projects = List();
  List<User> _users = List();
  List<Country> _countries = List();

  Future<List<Project>> getProjectsWithinRadius(
      {double radiusInKM = 100.5}) async {
    var pos = await locationBloc.getLocation();
    pp('💜 💜 💜 MonitorBloc: current location: 💜 latitude: ${pos.latitude} longitude: ${pos.longitude}');
    _projects = await DataAPI.findProjectsByLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        radiusInKM: radiusInKM);
    _projController.sink.add(_projects);
    pp('💜 💜 💜 MonitorBloc: Projects within radius of $radiusInKM kilometres; found: 💜 ${_projects.length} projects');
    _projects.forEach((element) {
      pp('💜 💜 PROJECT: ${element.name} 🍏 ${element.organizationName}');
    });
    return _projects;
  }

  Future<List<Project>> getOrganizationProjects({String organizationId}) async {
    var pos = await locationBloc.getLocation();
    pp('💜 💜 💜 MonitorBloc: current location: 💜 latitude: ${pos.latitude} longitude: ${pos.longitude}');
    _projects = await DataAPI.findProjectsByOrganization(organizationId);
    _projController.sink.add(_projects);
    pp('💜 💜 💜 MonitorBloc: OrganizationProjects found: 💜 ${_projects.length} projects ');
    _projects.forEach((element) {
      pp('💜 💜 PROJECT: ${element.name} 🍏 ${element.organizationName}');
    });
    return _projects;
  }

  void _initialize() async {
    pp('🏈🏈🏈🏈🏈 Initializing MonitorBloc ....');
    _user = await Prefs.getUser();
  }

  close() {
    _communityController.close();
    _questController.close();
    _projController.close();
    _userController.close();
    _countryController.close();
    _activeQuestionnaireController.close();
    _activeUserController.close();
    _reportController.close();
  }
}
