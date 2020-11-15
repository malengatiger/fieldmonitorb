import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/project.dart';

class ProjectDetailTablet extends StatefulWidget {
  final Project project;

  const ProjectDetailTablet(this.project);
  @override
  _ProjectDetailTabletState createState() => _ProjectDetailTabletState();
}

class _ProjectDetailTabletState extends State<ProjectDetailTablet>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
