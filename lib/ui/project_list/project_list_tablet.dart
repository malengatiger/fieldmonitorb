import 'package:flutter/material.dart';

class ProjectListTablet extends StatefulWidget {
  @override
  _ProjectListTabletState createState() => _ProjectListTabletState();
}

class _ProjectListTabletState extends State<ProjectListTablet>
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
