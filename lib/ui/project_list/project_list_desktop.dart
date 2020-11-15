import 'package:flutter/material.dart';

class ProjectListDesktop extends StatefulWidget {
  @override
  _ProjectListDesktopState createState() => _ProjectListDesktopState();
}

class _ProjectListDesktopState extends State<ProjectListDesktop>
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
