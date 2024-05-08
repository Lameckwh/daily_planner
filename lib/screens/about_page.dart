import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            title: const Text('About'),
          ),
          body: const SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Image(
                      height: 90,
                      width: 90,
                      image: AssetImage("images/ic_launcher.png"),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Eco Tourism  App",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    Text("v 1.0.0", style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: ListBody(
                        children: [
                          ListTile(
                            leading: Icon(FontAwesomeIcons.github),
                            title: Text("View source code"),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 0.6,
                          ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.linkedin,
                              color: Colors.blue,
                            ),
                            title: Text("LinkedIn"),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 0.6,
                          ),
                          ListTile(
                            leading: Icon(Icons.help),
                            title: Text("Help or FeedBack"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
                  child: Text(
                    "This app was developed by MG Lameck Mbewe with love of Eco Tourism",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
