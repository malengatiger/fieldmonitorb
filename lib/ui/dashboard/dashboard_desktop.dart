import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/user.dart';

class DashboardDesktop extends StatefulWidget {
  final User user;
  DashboardDesktop({Key? key, required this.user}) : super(key: key);
  @override
  _DashboardDesktopState createState() => _DashboardDesktopState();
}

class _DashboardDesktopState extends State<DashboardDesktop>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
