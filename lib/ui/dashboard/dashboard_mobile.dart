import 'package:fieldmonitor3/ui/intro/intro_main.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/bloc/monitor_bloc.dart';
import 'package:monitorlibrary/bloc/theme_bloc.dart';
import 'package:monitorlibrary/data/photo.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/user.dart' as mon;
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/snack.dart';
import 'package:monitorlibrary/ui/project_list/project_list_main.dart';
import 'package:page_transition/page_transition.dart';

class DashboardMobile extends StatefulWidget {
  final mon.User user;
  DashboardMobile({Key key, this.user}) : super(key: key);

  @override
  _DashboardMobileState createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var isBusy = false;
  var _projects = List<Project>();
  var _users = List<mon.User>();
  var _photos = List<Photo>();
  var _videos = List<Video>();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setItems();
    _listenToStreams();
  }

  void _listenToStreams() async {
    monitorBloc.projectStream.listen((event) {
      setState(() {
        _projects = event;
        pp('_DashboardMobileState: 🎽 🎽 🎽 projects delivered by stream: ${_projects.length} ...');
      });
    });
    monitorBloc.usersStream.listen((event) {
      setState(() {
        _users = event;
        pp('_DashboardMobileState: 🎽 🎽 🎽 users delivered by stream: ${_users.length} ...');
      });
    });
    monitorBloc.photoStream.listen((event) {
      setState(() {
        _photos = event;
        pp('_DashboardMobileState: 🎽 🎽 🎽 photos delivered by stream: ${_photos.length} ...');
      });
    });
    monitorBloc.videoStream.listen((event) {
      setState(() {
        _videos = event;
        pp('_DashboardMobileState: 🎽 🎽 🎽 videos delivered by stream: ${_videos.length} ...');
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var items = List<BottomNavigationBarItem>();
  void _setItems() {
    // items
    //     .add(BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'));
    items.add(
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Projects'));
    items.add(
        BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.info_outline), onPressed: _navigateToIntro),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                themeBloc.changeToRandomTheme();
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _listenToStreams,
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.user == null ? '' : widget.user.organizationName,
                    style: Styles.blackBoldSmall,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.user == null ? '' : widget.user.name,
                    style: Styles.whiteSmall,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.brown[100],
        bottomNavigationBar: BottomNavigationBar(
          items: items,
          onTap: _handleBottomNav,
        ),
        body: isBusy
            ? Center(
                child: Container(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.teal,
                  ),
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      children: [
                        Container(
                          child: GestureDetector(
                            onTap: _navigateToProjectList,
                            child: Card(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 48,
                                  ),
                                  Text(
                                    '${_projects.length}',
                                    style: Styles.blackBoldLarge,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    'Projects',
                                    style: Styles.greyLabelSmall,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Card(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                ),
                                Text(
                                  '${_users.length}',
                                  style: Styles.blackBoldLarge,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Users',
                                  style: Styles.greyLabelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Card(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                ),
                                Text(
                                  '${_photos.length}',
                                  style: Styles.blackBoldLarge,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Photos',
                                  style: Styles.greyLabelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Card(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                ),
                                Text(
                                  '${_videos.length}',
                                  style: Styles.blackBoldLarge,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Videos',
                                  style: Styles.greyLabelSmall,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  var _key = GlobalKey<ScaffoldState>();
  void _handleBottomNav(int value) {
    switch (value) {
      case 0:
        pp(' 🔆🔆🔆 Navigate to MonitorList');
        _navigateToProjectList();
        break;

      case 1:
        pp(' 🔆🔆🔆 Navigate to MediaList');
        AppSnackbar.showSnackbar(
            scaffoldKey: _key,
            message: 'Under Construction',
            textColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor);
        break;
    }
  }

  // void _navigateToUserList() {
  //   Navigator.push(
  //       context,
  //       PageTransition(
  //           type: PageTransitionType.scale,
  //           alignment: Alignment.topLeft,
  //           duration: Duration(seconds: 1),
  //           child: UserListMain()));
  // }

  void _navigateToProjectList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: ProjectListMain(widget.user)));
  }

  void _navigateToIntro() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: IntroMain(
              user: widget.user,
            )));
  }
}
