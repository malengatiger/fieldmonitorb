import 'package:flutter/material.dart';

class SigninTablet extends StatefulWidget {
  @override
  _SigninTabletState createState() => _SigninTabletState();
}

class _SigninTabletState extends State<SigninTablet>
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
