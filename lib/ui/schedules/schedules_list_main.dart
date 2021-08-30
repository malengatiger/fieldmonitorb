import 'package:fieldmonitor3/ui/schedules/schedules_list_desktop.dart';
import 'package:fieldmonitor3/ui/schedules/schedules_list_mobile.dart';
import 'package:fieldmonitor3/ui/schedules/schedules_list_tablet.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SchedulesListMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      mobile: SchedulesListMobile(),
      tablet: SchedulesListTablet(),
      desktop: SchedulesListDesktop(),
    );
  }
}
