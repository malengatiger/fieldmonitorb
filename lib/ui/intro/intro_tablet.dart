import 'package:flutter/material.dart';
import 'package:monitorlibrary/data/user.dart';

class IntroTablet extends StatefulWidget {
  final User user;
  IntroTablet({Key key, this.user}) : super(key: key);

  @override
  _IntroTabletState createState() => _IntroTabletState();
}

class _IntroTabletState extends State<IntroTablet>
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
