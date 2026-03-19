import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => Planning_();
}

class Planning_ extends State<Planning> {
  ThemeData darkTheme = ThemeData(
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

  Future<Map> get_planning() async {
    Map planning_temp = await API.get_planning();
    return planning_temp;
  }

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
          SizedBox(
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
          ));
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
  void scroll_planning(bool scroll_state) {
    planning_cache["day_select"] = scroll_state ? planning_cache["day_select"] + 1 : planning_cache["day_select"] - 1;
    render_day();
  }

  void Loading_planning() async {
    Map result = await get_planning();
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