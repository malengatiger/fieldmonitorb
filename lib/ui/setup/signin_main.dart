import 'package:fieldmonitor3/ui/setup/signin_desktop.dart';
import 'package:fieldmonitor3/ui/setup/signin_mobile.dart';
import 'package:fieldmonitor3/ui/setup/signin_tablet.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SigninMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SigninMobile(),
      tablet: SigninTablet(),
      desktop: SigninDesktop(),
    );
  }
}
