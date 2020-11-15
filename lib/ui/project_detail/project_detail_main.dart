import 'package:fieldmonitor3/ui/project_detail/project_detail_desktop.dart';
import 'package:fieldmonitor3/ui/project_detail/project_detail_mobile.dart';
import 'package:fieldmonitor3/ui/project_detail/project_detail_tablet.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/project.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProjectDetailMain extends StatefulWidget {
  final Project project;

  const ProjectDetailMain(this.project);
  @override
  _ProjectDetailMainState createState() => _ProjectDetailMainState();
}

class _ProjectDetailMainState extends State<ProjectDetailMain>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool isBusy = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp(' 🌸 🌸 ProjectDetailMain: initState  🌸 🌸 '
        '${widget.project.name} ${widget.project.organizationName}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isBusy
        ? Center(
            child: Container(
              child: CircularProgressIndicator(
                strokeWidth: 16,
                backgroundColor: Colors.pink,
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: ProjectDetailMobile(widget.project),
            tablet: ProjectDetailTablet(widget.project),
            desktop: ProjectDetailDesktop(widget.project),
          );
  }
}

abstract class ProjectDetailBase {
  startProjectMonitoring();
  listMonitorReports();
  listNearestCities();
  updateProject();
}
