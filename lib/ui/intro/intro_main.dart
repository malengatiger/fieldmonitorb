import 'package:fieldmonitor3/ui/dashboard/dashboard_main.dart';
import 'package:flutter/material.dart';
import 'package:monitorlibrary/auth/app_auth.dart';
import 'package:monitorlibrary/data/user.dart';
import 'package:monitorlibrary/functions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'intro_desktop.dart';
import 'intro_mobile.dart';
import 'intro_tablet.dart';

class IntroMain extends StatefulWidget {
  final User? user;
  IntroMain({Key? key, this.user}) : super(key: key);

  @override
  _IntroMainState createState() => _IntroMainState();
}

/// Main Widget that manages a responsive layout for intro pages
class _IntroMainState extends State<IntroMain> {
  var isBusy = false;
  User? user;
  @override
  void initState() {
    super.initState();
      user = widget.user;

  }



  @override
  Widget build(BuildContext context) {
    return isBusy
        ? SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(('Loading User ..')),
              ),
              body: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          )
        : ScreenTypeLayout(
            mobile: IntroMobile(user: user),
            tablet: IntroTablet(user: user),
            desktop: IntroDesktop(user: user),
          );
  }
}
