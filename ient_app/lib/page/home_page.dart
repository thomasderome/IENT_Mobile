import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;

class Home_page extends StatefulWidget {
  const Home_page({super.key});

  @override
  State<Home_page> createState() => _Home_page();
}

class _Home_page extends State<Home_page> {
  final API = back.API();

  Map planning_cache = {};

  String? key = null;
  Widget actual_day_widget =  FCard(
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Merci de patienter"),
        const FCircularProgress()
      ]
    )
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  Future<Map> get_planning() async {

    Map planning_temp = await API.get_planning();
    return planning_temp;
  }

  Color get_color(String name) {
    return HSLColor.fromAHSL(1.0, name.hashCode.toDouble() % 360, 0.53, 0.575).toColor();
  }

  void render_day({String? key_select = null}) {
    Map day_select = {};

    if (key_select != null) { day_select = planning_cache[key_select]; }
    else if (key != null) { day_select = planning_cache[key]; }
    else { day_select = planning_cache[-1]; }

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
              onPress: null,
              child: const Text("p"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(day_select["day"]),
            ),
            FButton(
                onPress: null,
                child: const Text("s")
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

  void Loading_planngin() async {
    Map result = await get_planning();
    setState(() {
      planning_cache = result;
      render_day();
    });
  }

  @override
  void initState() {
    super.initState();
    Loading_planngin();
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
