import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../backend/backend.dart' as back;

class Work extends StatefulWidget {
  const Work({super.key});

  @override
  State<Work> createState() => _WorkState();
}

class _WorkState extends State<Work> {
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  final API = back.API();
  bool loading = true;

  Widget actual_widget = FCard(
      title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Merci de patienter"),
            const FCircularProgress()
          ]
      )
  );

  Future<void> _launchUrl(String url) async {
     await API.render_file(url);
  }

  @override
  void initState() {
    super.initState();
    loading_work();
  }

  void loading_work() async {
    final Map<String, List> result = await API.get_work();
    setState(() {
      List<Widget> work = [];

      result.forEach((key, value) {
        List<Widget> temp = [];
        for (var day in value) {
          temp.add(
            FAccordionItem(title: Text(day["title"], style: TextStyle(fontWeight: FontWeight.bold),), child: Column(
              children: [
                Text(day["desc_detail"], style: TextStyle(fontSize: 18)),
                ...(day["doc"] as List? ?? []).map((e) => Padding(padding: EdgeInsets.only(bottom: 5), child: FButton(
                  onPress: () { _launchUrl(e["link"]); },
                  child: Expanded(
                    child: Text(
                      e["name"] ?? "Sans nom",
                      style: TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ))).toList()
              ],
            ))
          );
        }

        work.add(FAccordionItem(
          title: Text(key),
          child: FAccordion(children: temp),
        ));
      });


      actual_widget = FCard(
        title: const Text("Devoir à faire"),
        child: FAccordion(children: work)
      );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
     return actual_widget;
  }
}
