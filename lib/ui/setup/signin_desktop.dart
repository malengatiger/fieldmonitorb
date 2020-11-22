import 'package:flutter/material.dart';

class SigninDesktop extends StatefulWidget {
  @override
  _SigninDesktopState createState() => _SigninDesktopState();
}

class _SigninDesktopState extends State<SigninDesktop>
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
