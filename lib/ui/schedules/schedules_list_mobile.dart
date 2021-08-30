import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/bloc/monitor_bloc.dart';
import 'package:monitorlibrary/data/field_monitor_schedule.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/snack.dart';

class SchedulesListMobile extends StatefulWidget {
  @override
  _SchedulesListMobileState createState() => _SchedulesListMobileState();
}

class _SchedulesListMobileState extends State<SchedulesListMobile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  User _user;
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

  void _getData(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      _user = await Prefs.getUser();
      _schedules = await monitorBloc.getMonitorFieldMonitorSchedules(
          userId: _user.userId, forceRefresh: refresh);
    } catch (e) {
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Data refresh failed: $e');
    }

    setState(() {
      busy = false;
    });
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
                          '${_user == null ? '' : _user.name},',
                          style: Styles.whiteBoldMedium,
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
                      return Card(
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.alarm,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                '${sched.projectName}',
                                style: Styles.blackBoldSmall,
                              ),
                              subtitle: Text('$subTitle'),
                            ),
                            SizedBox(
                              height: 0,
                            ),
                            Text(getFormattedDateLongWithTime(
                                sched.date, context)),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
    );
  }

  String _getSubTitle(FieldMonitorSchedule sc) {
    var string = 'time(s) per Day';
    if (sc.perDay > 0) {
      return '${sc.perDay} $string';
    }
    if (sc.perWeek > 0) {
      return '${sc.perWeek} time(s) per Week';
    }
    if (sc.perMonth > 0) {
      return '${sc.perMonth} time(s) per Month';
    }
    return '';
  }
}
