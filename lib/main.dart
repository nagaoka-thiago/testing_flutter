import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PolyEditor _polyEditor;
  List<Polygon> _polygons = [];
  late Location location;
  late LatLng firstLocation;

  var _testPolygon = Polygon(
      color: Colors.red,
      points: [],
      borderStrokeWidth: 5,
      borderColor: Colors.red);

  @override
  void initState() {
    super.initState();
    Permission.location.request();
    // Permission.locationAlways.request();
    // Permission.locationWhenInUse.request();
    _polyEditor = PolyEditor(
        points: _testPolygon.points,
        pointIcon: Icon(Icons.location_on, size: 23, color: Colors.red),
        addClosePathMarker: true,
        intermediateIcon: Icon(Icons.lens, size: 15, color: Colors.red),
        callbackRefresh: () {
          setState(() {});
        });
    _polygons.add(_testPolygon);

    location = Location();

    location.getLocation().then((loc) => {
          setState(() {
            firstLocation = LatLng(loc.latitude!, loc.longitude!);
          })
        });

    location.onLocationChanged.listen((event) {
      setState(() {
        firstLocation = LatLng(event.latitude!, event.longitude!);
      });
    });
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
            center: firstLocation,
            plugins: [
              DragMarkerPlugin(),
            ],
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            PolygonLayerOptions(
              polygons: _polygons,
            ),
            DragMarkerPluginOptions(markers: _polyEditor.edit()),
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
