import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/user.dart';

class IntroDesktop extends StatefulWidget {
  final User user;
  IntroDesktop({Key key, this.user}) : super(key: key);
  @override
  _IntroDesktopState createState() => _IntroDesktopState();
}

class _IntroDesktopState extends State<IntroDesktop>
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
