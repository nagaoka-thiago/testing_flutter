import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PolyEditor _polyEditor;
  List<Polygon> _polygons = [];
  var _testPolygon =
      Polygon(color: Colors.red, points: [], borderStrokeWidth: 5);

  @override
  void initState() {
    super.initState();
    _polyEditor = PolyEditor(
        points: _testPolygon.points,
        pointIcon: Icon(Icons.location_on, size: 23, color: Colors.red),
        addClosePathMarker: true,
        intermediateIcon: Icon(Icons.lens, size: 15, color: Colors.red),
        callbackRefresh: () {
          setState(() {});
        });
    _polygons.add(_testPolygon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FlutterMap(
          options: MapOptions(
            allowPanningOnScrollingParent: false,
            onTap: (_, p) {
              setState(() {
                _polyEditor.add(_testPolygon.points, p);
              });
            },
            plugins: [
              DragMarkerPlugin(),
            ],
            zoom: 6.4,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            DragMarkerPluginOptions(markers: _polyEditor.edit()),
            // polygon formed by points clicked, only 4 points required
            PolygonLayerOptions(
              polygons: _polygons,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _testPolygon.points.removeLast();
            });
          },
          child: Icon(Icons.delete)),
    );
  }
}
