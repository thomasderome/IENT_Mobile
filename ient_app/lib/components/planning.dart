import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;
import 'package:time/time.dart';

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => Planning_();
}

class Planning_ extends State<Planning> {
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  final API = back.API();

  Map planning_cache = {};

  Widget actual_day_widget = FCard(
      title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Merci de patienter"),
            const FCircularProgress()
          ]
      )
  );

  Color get_color(String name) {
    return HSLColor.fromAHSL(1.0, name.hashCode.toDouble() % 360, 0.53, 0.575).toColor();
  }

  void render_day() {
    Map day_select = planning_cache["days"][planning_cache["day_select"]];

    List<Widget> activity_widget = [];
    for (Map activity in day_select["activity"]) {
      double start = activity["start"] * 30.0 + 7 * 60;
      double time = activity["time"] * 30 + start;

      activity_widget.add(
        Padding(padding: EdgeInsets.only(bottom: 5),
          child: SizedBox(
              width: 400,
              height: 85,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Text("${start ~/ 60}h${(start % 60).toInt().toString().padLeft(2, "0")}\n\n\n${time ~/ 60}h${(time % 60).toInt().toString().padLeft(2, "0")}")
                    ),
                    SizedBox(
                      width: 10,
                      child: Container(
                        decoration: BoxDecoration(
                            color: get_color(activity["name"]),
                            borderRadius: BorderRadius.circular(12.0)
                        ),
                      ),
                    ),
                    Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity["name"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              activity["prof"],
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              activity["room"],
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        )
                    ))
                  ])
          ))
        );
    }

    if (activity_widget.isEmpty) {
      activity_widget.add(
          SizedBox(
              width: 400,
              height: 85,
              child: Center(
                  child: Text(
                      "Aucun cour prévu pour à ce jour.",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                  )
              )
          )
      );
    }

    setState(() {
      actual_day_widget = FCard(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FButton(
              onPress: () => scroll_planning(false),
              child: const Text("p"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(day_select["day"]),
            ),
            FButton(
                onPress: () => scroll_planning(true),
                child: const Text("n")
            ),
          ],
        ),
        child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: FCard(
                child: Column(
                  children: activity_widget,
                )
            )),
      );
    });
  }

  // if scroll state true next day else last day
  bool disable_scroll = false;
  void scroll_planning(bool scroll_state) {
    if (disable_scroll) return;
    disable_scroll = true;

    int verif = scroll_state ? planning_cache["day_select"] + 1 : planning_cache["day_select"] - 1;

    if (verif <= 5 && verif >= 1) {
      planning_cache["day_select"] = verif;
    } else {
      final int direction = scroll_state ? 1 : -1;
      final num next_day = (8 - planning_cache["original"]) * direction;

      final week = DateTime.parse(planning_cache["date_select"]) + next_day.days;

      Loading_planning(custom_date: "${week.year}-${week.month >= 10 ? week.month : '0${week.month}'}-${week.day >= 10 ? week.day : '0${week.day}'}") ;
    }

    render_day();
    disable_scroll = false;
  }

  Future<Map> get_planning({String? custom_date = null}) async {
    if (custom_date == null) { return await API.get_planning(); }
    else { return await API.get_planning(date_custom: custom_date); }
  }

  void Loading_planning({String? custom_date = null}) async {
    Map result = await get_planning(custom_date:custom_date);
    setState(() {
      planning_cache = result;
      render_day();
    });
  }

  @override
  void initState() {
    super.initState();
    Loading_planning();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: darkTheme,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.dark,
          child: child!,
        ),
        home: Scaffold(
            body: Center(
                child: actual_day_widget
            )
        )
    );
  }
}