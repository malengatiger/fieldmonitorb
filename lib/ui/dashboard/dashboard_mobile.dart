import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:fieldmonitor3/ui/intro/intro_main.dart';
import 'package:fieldmonitor3/ui/schedules/schedules_list_main.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/bloc/fcm_bloc.dart';
import 'package:monitorlibrary/bloc/monitor_bloc.dart';
import 'package:monitorlibrary/bloc/theme_bloc.dart';
import 'package:monitorlibrary/data/photo.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/user.dart' as mon;
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:monitorlibrary/snack.dart';
import 'package:monitorlibrary/ui/media/user_media_list/user_media_list_main.dart';
import 'package:monitorlibrary/ui/message/message_main.dart';
import 'package:monitorlibrary/ui/project_list/project_list_main.dart';
import 'package:monitorlibrary/ui/project_list/project_list_mobile.dart';
import 'package:monitorlibrary/users/list/user_list_main.dart';
import 'package:page_transition/page_transition.dart';
import 'package:universal_platform/universal_platform.dart';

class DashboardMobile extends StatefulWidget {
  final mon.User user;
  DashboardMobile({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardMobileState createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var isBusy = false;
  var _projects = <Project>[];
  var _users = <mon.User>[];
  var _photos = <Photo>[];
  var _videos = <Video>[];
  User? user;

  late StreamSubscription<ConnectivityResult> subscription;

  static const nn = 'DashboardMobile:  😡 😡 ';
  bool networkAvailable = false;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _setItems();
    _listenToStreams();
    _listenForFCM();
    _refreshData(false);
    _subscribeToConnectivity();
  }

  void _subscribeToConnectivity() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      pp('$nn onConnectivityChanged: result index: ${result.index}');
      if (result.index == ConnectivityResult.mobile.index) {
        pp('$nn ConnectivityResult.mobile.index: ${result.index} - 🍎 MOBILE NETWORK is on!');
        networkAvailable = true;
      }
      if (result.index == ConnectivityResult.wifi.index) {
        pp('$nn ConnectivityResult.wifi.index:  ${result.index} - 🍎 WIFI is on!');
        networkAvailable = true;
      }
      if (result.index == ConnectivityResult.none.index) {
        pp('ConnectivityResult.none.index: ${result.index} = 🍎 NONE - AIRPLANE MODE?');
        networkAvailable = false;
      }
      setState(() {});
    });
  }

  void _listenToStreams() async {
    monitorBloc.projectStream.listen((event) {
      if (mounted) {
        setState(() {
          _projects = event;
          pp('_DashboardMobileState: 🎽 🎽 🎽 projects delivered by stream: ${_projects.length} ...');
        });
      }
    });
    monitorBloc.usersStream.listen((event) {
      if (mounted) {
        setState(() {
          _users = event;
          pp('_DashboardMobileState: 🎽 🎽 🎽 users delivered by stream: ${_users.length} ...');
        });
      }
    });
    monitorBloc.photoStream.listen((event) {
      if (mounted) {
        setState(() {
          _photos = event;
          pp('_DashboardMobileState: 🎽 🎽 🎽 photos delivered by stream: ${_photos.length} ...');
        });
      }
    });
    monitorBloc.videoStream.listen((event) {
      if (mounted) {
        setState(() {
          _videos = event;
          pp('_DashboardMobileState: 🎽 🎽 🎽 videos delivered by stream: ${_videos.length} ...');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    subscription.cancel();
    super.dispose();
  }

  var items = <BottomNavigationBarItem>[];
  void _setItems() {
    // items
    //     .add(BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'));
    items.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
        ),
        label: 'Projects'));
    items.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.person,
          color: Colors.pink,
        ),
        label: 'My Work'));
    items.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.send,
          color: Colors.blue,
        ),
        label: 'Send Message'));
  }

  void _refreshData(bool forceRefresh) async {
    pp('$mm ............... Refresh data ....');
    setState(() {
      isBusy = true;
    });
    try {
      user = await Prefs.getUser();
      monitorBloc.refreshUserData(
          userId: user!.userId!,
          organizationId: user!.organizationId!,
          forceRefresh: forceRefresh);
    } catch (e) {
      print(e);
      AppSnackbar.showErrorSnackbar(
          scaffoldKey: _key, message: 'Dashboard refresh failed: $e');
    }
    setState(() {
      isBusy = false;
    });
  }

  void _listenForFCM() async {
    var android = UniversalPlatform.isAndroid;
    var ios = UniversalPlatform.isIOS;

    if (android || ios) {
      pp('DashboardMobile: 🍎 🍎 _listen to FCM message streams ... 🍎 🍎');
      fcmBloc.projectStream.listen((Project project) async {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showProjectSnackbar: ${project.name} ... 🍎 🍎');
          _projects = await monitorBloc.getOrganizationProjects(
              organizationId: user!.organizationId!, forceRefresh: false);
          setState(() {});
          // SpecialSnack.showProjectSnackbar(
          //     scaffoldKey: _key,
          //     textColor: Colors.white,
          //     backgroundColor: Theme.of(context).primaryColor,
          //     project: project,
          //     listener: this);
        }
      });

      fcmBloc.userStream.listen((User user) async {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showUserSnackbar: ${user.name} ... 🍎 🍎');
          _users = await monitorBloc.getOrganizationUsers(
              organizationId: user.organizationId!, forceRefresh: false);
          setState(() {});
          // SpecialSnack.showUserSnackbar(
          //     scaffoldKey: _key, user: user, listener: this);
        }
      });

      fcmBloc.messageStream.listen((mon.OrgMessage message) {
        if (mounted) {
          pp('DashboardMobile: 🍎 🍎 showMessageSnackbar: ${message.message} ... 🍎 🍎');

          // SpecialSnack.showMessageSnackbar(
          //     scaffoldKey: _key, message: message, listener: this);
        }
      });
    } else {
      pp('App is running on the Web 👿 👿 👿  firebase messaging is OFF 👿 👿 👿');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: networkAvailable
          ? Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text(
                  'Digital Monitor',
                  style: Styles.whiteTiny,
                ),
                actions: [
                  IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        size: 20,
                      ),
                      onPressed: _navigateToIntro),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 20,
                    ),
                    onPressed: () {
                      themeBloc.changeToRandomTheme();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 20,
                    ),
                    onPressed: () {
                      _refreshData(true);
                    },
                  )
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(100),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          widget.user == null
                              ? ''
                              : widget.user.organizationName!,
                          style: Styles.blackBoldSmall,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          widget.user == null ? '' : widget.user.name!,
                          style: Styles.whiteBoldSmall,
                        ),
                        Text('Field Monitor', style: Styles.whiteTiny),
                        SizedBox(
                          height: 8,
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
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          backgroundColor: Colors.amber,
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
                                    color: Colors.brown[50],
                                    elevation: 2,
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
                                child: GestureDetector(
                                  onTap: _navigateToUserList,
                                  child: Card(
                                    color: Colors.brown[50],
                                    elevation: 2,
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
                              ),
                              Container(
                                child: Card(
                                  elevation: 4,
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
                                  elevation: 4,
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
            )
          : Scaffold(
              key: _key,
              appBar: AppBar(
                title: Text('Network Unavailable'),
              ),
              body: Center(
                child: Text(
                  'No Network Found!',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900),
                ),
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
        pp(' 🔆🔆🔆 Navigate to ScheduleList');
        _navigateToScheduleList();
        break;

      case 2:
        pp(' 🔆🔆🔆 Navigate to MessageSender');
        _navigateToMessageSender();
        break;
    }
  }

  void _navigateToProjectList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: ProjectListMobile(widget.user)));
  }

  void _navigateToMessageSender() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: MessageMain(user: user)));
  }

  void _navigateToMediaList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: UserMediaListMain(user!)));
  }

  void _navigateToScheduleList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: SchedulesListMain()));
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

  void _navigateToUserList() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: UserListMain()));
  }


}
