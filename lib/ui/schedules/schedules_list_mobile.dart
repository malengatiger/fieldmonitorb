import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/api/local_mongo.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/bloc/monitor_bloc.dart';
import 'package:monitorlibrary/data/field_monitor_schedule.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/snack.dart';
import 'package:flutter/rendering.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:monitorlibrary/ui/maps/project_map_mobile.dart';
import 'package:monitorlibrary/ui/maps_field_monitor/field_monitor_map_mobile.dart';
import 'package:monitorlibrary/ui/media/user_media_list/user_media_list_mobile.dart';
import 'package:page_transition/page_transition.dart';

class SchedulesListMobile extends StatefulWidget {
  @override
  _SchedulesListMobileState createState() => _SchedulesListMobileState();
}

class _SchedulesListMobileState extends State<SchedulesListMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  User? _user;
  List<FieldMonitorSchedule> _schedules = [];
  bool busy = false;
  var _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getData(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _navigateToProjectMapMobile(FieldMonitorSchedule sched) async {
    var pos = await LocalMongo.getProjectPositions(sched.projectId!);
    var proj = await LocalMongo.getProjectById(projectId: sched.projectId!);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: ProjectMapMobile(projectPositions: pos, project: proj!,)));
  }
  void _navigateToUserMediaListMobile() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: UserMediaListMobile(_user!)));
  }
  void _getData(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = await Prefs.getUser();
      _schedules = await monitorBloc.getMonitorFieldMonitorSchedules(
          userId: _user!.userId!, forceRefresh: refresh);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Data refresh failed: $e');
    }

    setState(() {
      busy = false;
    });
  }

  static const mm = '🍏 🍏 🍏 ScheduleList 🍏 : ';
  List<FocusedMenuItem> getPopUpMenuItems(FieldMonitorSchedule schedule) {
    List<FocusedMenuItem> menuItems = [];
    menuItems.add(
      FocusedMenuItem(
          title: Text('Project Map'),
          trailingIcon: Icon(
            Icons.map,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            pp('$mm should navigate to map');
            _navigateToProjectMapMobile(schedule);
          }),
    );
    menuItems.add(
      FocusedMenuItem(
          title: Text('Photos & Videos'),
          trailingIcon: Icon(
            Icons.camera,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToMedia(p);
            pp('$mm should navigate to media');
            _navigateToUserMediaListMobile();
          }),
    );
    if (_user!.userType == ORG_ADMINISTRATOR) {
      menuItems.add(FocusedMenuItem(
          title: Text('Add Project Location'),
          trailingIcon: Icon(
            Icons.location_pin,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToProjectLocation(p);
          }));
    }
    if (_user!.userType == ORG_ADMINISTRATOR) {
      menuItems.add(FocusedMenuItem(
          title: Text('Edit Project'),
          trailingIcon: Icon(
            Icons.create,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            //_navigateToDetail(p);
          }));
    }
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: busy
          ? Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Loading FieldMonitor schedules ...',
                  style: Styles.whiteSmall,
                ),
              ),
              body: Center(
                child: Container(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    backgroundColor: Colors.amber,
                  ),
                ),
              ),
            )
          : Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'FieldMonitor Schedules',
                  style: Styles.whiteSmall,
                ),
                actions: [
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        _getData(true);
                      })
                ],
                bottom: PreferredSize(
                    child: Column(
                      children: [
                        Text(
                          '${_user == null ? '' : _user!.name}',
                          style: Styles.whiteBoldMedium,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Field Monitor',
                          style: Styles.whiteTiny,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                    preferredSize: Size.fromHeight(100)),
              ),
              backgroundColor: Colors.brown[100],
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      var sched = _schedules.elementAt(index);
                      var subTitle = _getSubTitle(sched);
                      return FocusedMenuHolder(
                        menuOffset: 20,
                        duration: Duration(milliseconds: 300),
                        menuItems: getPopUpMenuItems(sched),
                        animateMenuItems: true,
                        openWithTap: true,
                        onPressed: () {
                          pp('.... 💛️ 💛️ 💛️ not sure what I pressed ...');
                        },
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Opacity(
                                      opacity: 0.5,
                                      child: Icon(
                                        Icons.water_damage,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Flexible(
                                      child: Text(
                                        sched.projectName!,
                                        style: Styles.blackBoldSmall,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 32,),
                                    Text('Frequency: ', style: Styles.greyLabelSmall,),
                                    Text('$subTitle', style: Styles.blackBoldSmall,),
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // return Card(
                      //   elevation: 2,
                      //   child: Column(
                      //     children: [
                      //       SizedBox(
                      //         height: 8,
                      //       ),
                      //       ListTile(
                      //         leading: Icon(
                      //           Icons.alarm,
                      //           color: Theme.of(context).primaryColor,
                      //         ),
                      //         title: Text(
                      //           '${sched.projectName}',
                      //           style: Styles.blackBoldSmall,
                      //         ),
                      //         subtitle: Text('$subTitle'),
                      //       ),
                      //       // SizedBox(
                      //       //   height: 0,
                      //       // ),
                      //       // Text(getFormattedDateLongWithTime(
                      //       //     sched.date!, context), style: Styles.greyLabelSmall,),
                      //       SizedBox(
                      //         height: 8,
                      //       ),
                      //     ],
                      //   ),
                      // );
                    }),
              ),
            ),
    );
  }

  String _getSubTitle(FieldMonitorSchedule sc) {
    var string = 'per Day';
    if (sc.perDay! > 0) {
      return '${sc.perDay} $string';
    }
    if (sc.perWeek! > 0) {
      return '${sc.perWeek} per Week';
    }
    if (sc.perMonth! > 0) {
      return '${sc.perMonth} per Month';
    }
    return '';
  }
}
