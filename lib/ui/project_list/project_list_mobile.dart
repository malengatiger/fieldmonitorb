import 'package:fieldmonitor3/bloc.dart';
import 'package:fieldmonitor3/ui/project_detail/project_detail_main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/api/sharedprefs.dart';
import 'package:monitorlibrary/bloc/theme_bloc.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:page_transition/page_transition.dart';

class ProjectListMobile extends StatefulWidget {
  @override
  _ProjectListMobileState createState() => _ProjectListMobileState();
}

class _ProjectListMobileState extends State<ProjectListMobile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var projects = List<Project>();
  User user;
  bool isBusy = false;

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
    if (user != null) {
      monitorBloc.getOrganizationProjects(organizationId: user.organizationId);
    }

    setState(() {
      isBusy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Project>>(
          stream: monitorBloc.projectStream,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              pp('❤️❤️❤️ stream delivering projects to widget: ${snapshot.data.length}');
              projects = snapshot.data;
            }
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Projects',
                    style: Styles.whiteSmall,
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        themeBloc.changeToRandomTheme();
                      },
                    )
                  ],
                  bottom: PreferredSize(
                    child: Column(
                      children: [
                        Text(
                          user == null ? 'Field Monitor' : user.name,
                          style: Styles.whiteBoldMedium,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Field Monitor',
                          style: Styles.blackSmall,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          user == null ? '' : '${user.organizationName}',
                          style: Styles.whiteSmall,
                        ),
                        SizedBox(
                          height: 48,
                        ),
                      ],
                    ),
                    preferredSize: Size.fromHeight(200),
                  ),
                ),
                backgroundColor: Colors.brown[100],
                body: isBusy
                    ? Center(
                        child: Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 8,
                            backgroundColor: Colors.indigo,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (BuildContext context, int index) {
                            var p = projects.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                _navigateToDetail(p);
                              },
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.settings),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            p.name,
                                            style: Styles.blackBoldSmall,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 32,
                                          ),
                                          Row(
                                            children: [
                                              Text('Ratings'),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '${p.ratings.length}',
                                                style: Styles.blueBoldSmall,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text('Photos'),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                '${p.photos.length}',
                                                style: Styles.pinkBoldSmall,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ));
          }),
    );
  }

  void _navigateToDetail(Project p) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.scale,
            alignment: Alignment.topLeft,
            duration: Duration(seconds: 1),
            child: ProjectDetailMain(p)));
  }
}
