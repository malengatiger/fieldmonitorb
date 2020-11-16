import 'package:fieldmonitor3/bloc.dart';
import 'package:fieldmonitor3/ui/media/media_house.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/project_position.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/location/loc_bloc.dart';
import 'package:monitorlibrary/snack.dart';
import 'package:page_transition/page_transition.dart';

class ProjectDetailMobile extends StatefulWidget {
  final Project project;

  ProjectDetailMobile(this.project);

  @override
  _ProjectDetailMobileState createState() => _ProjectDetailMobileState();
}

class _ProjectDetailMobileState extends State<ProjectDetailMobile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var isBusy = false;
  var _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp(' 🌸 🌸 ProjectDetailMobile: initState  🌸 🌸 '
        '${widget.project.name} ${widget.project.organizationName}');
    _getProjectPositions();
  }

  void _getProjectPositions() async {
    setState(() {
      isBusy = true;
    });
    var positions = await monitorBloc.getProjectPositions(
        projectId: widget.project.projectId);

    setState(() {
      widget.project.projectPositions = positions;
    });
    _checkProjectDistance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(widget.project.organizationName,
              style: Styles.whiteBoldSmall),
          bottom: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(widget.project.name, style: Styles.blackBoldSmall),
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    'The project should be monitored only when the device is within a radius of',
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text('${widget.project.monitorMaxDistanceInMetres}',
                      style: Styles.blackBoldMedium),
                  SizedBox(
                    height: 0,
                  ),
                  Text('metres'),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(240),
          ),
        ),
        backgroundColor: Colors.brown[100],
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                    ),
                    RaisedButton(
                      elevation: isWithinDistance ? 16 : 1,
                      onPressed: () async {
                        isWithinDistance = await _checkProjectDistance();
                        if (isWithinDistance) {
                          _startMonitoring();
                        } else {
                          setState(() {});
                          _showError();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Start Monitor',
                          style: Styles.whiteSmall,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    isBusy
                        ? Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.yellowAccent,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Checking project location',
                                style: Styles.blackTiny,
                              )
                            ],
                          )
                        : Container(),
                    SizedBox(
                      height: 24,
                    ),
                    isWithinDistance
                        ? Container(
                            child: Text('We are good to go!',
                                style: Styles.blackBoldSmall),
                          )
                        : Container(
                            child: Text(
                              'Device is too far from a project',
                              style: Styles.pinkBoldSmall,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<ProjectPosition> _findNearestProjectPosition() async {
    var bags = List<BagX>();
    if (widget.project.projectPositions.length == 1) {
      return widget.project.projectPositions.first;
    }
    widget.project.projectPositions.forEach((pos) async {
      var distance = await locationBloc.getDistanceFromCurrentPosition(
          latitude: widget.project.position.coordinates[1],
          longitude: widget.project.position.coordinates[0]);
      bags.add(BagX(distance, pos));
    });
    bags.sort((a, b) => a.distance.compareTo(b.distance));
    return bags.first.position;
  }

  bool isWithinDistance = false;
  ProjectPosition nearestProjectPosition;

  Future<bool> _checkProjectDistance() async {
    setState(() {
      isBusy = true;
    });
    nearestProjectPosition = await _findNearestProjectPosition();
    var distance = await locationBloc.getDistanceFromCurrentPosition(
        latitude: nearestProjectPosition.position.coordinates[1],
        longitude: nearestProjectPosition.position.coordinates[0]);

    pp("🍏 🍏 🍏 App is ${distance.toStringAsFixed(1)} metres from the project point");
    if (distance > widget.project.monitorMaxDistanceInMetres) {
      pp("🔆🔆🔆 App is ${distance.toStringAsFixed(1)} metres is greater than allowed project.monitorMaxDistanceInMetres: "
          "🍎 ${widget.project.monitorMaxDistanceInMetres} metres");
      isWithinDistance = false;
    } else {
      isWithinDistance = true;
      pp('🌸 🌸 🌸 The app is within the allowable project.monitorMaxDistanceInMetres of '
          '${widget.project.monitorMaxDistanceInMetres} metres');
    }
    setState(() {
      isBusy = false;
    });
    return isWithinDistance;
  }

  void _startMonitoring() async {
    pp('🍏 🍏 Start Monitoring this project after checking that the device is within '
        ' 🍎 ${widget.project.monitorMaxDistanceInMetres} metres 🍎 of a project point within ${widget.project.name}');
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: MediaHouse(
              project: widget.project,
              projectPosition: nearestProjectPosition,
            )));
  }

  _showError() {
    AppSnackbar.showErrorSnackbar(
        scaffoldKey: _key,
        actionLabel: '',
        message:
            "You are too far from the project for monitoring to work properly");
    setState(() {
      isBusy = false;
    });
  }
}

class BagX {
  double distance;
  ProjectPosition position;

  BagX(this.distance, this.position);
}
