import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:num_remap/num_remap.dart';
import 'ffi.dart' if (dart.library.html) 'ffi_web.dart';
import 'package:lakos/lakos.dart';

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
  // These futures belong to the state and are only initialized once,
  // in the initState method.
  late Future<Platform> platform;
  late Future<bool> isRelease;
  List<String> nodeList = [];
  List<Position> positions = [];
  List<RustEdge> edgeList = [];
  var globalOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    platform = api.platform();
    isRelease = api.rustReleaseMode();

    setState(() {
      foo();
    });
  }

  Future<void> foo() async {
    final directoryPath = await getDirectoryPath();

    final model =
        buildModel(Directory(directoryPath ?? '.'), showMetrics: true);

    final digraph = model.toDirectedGraph();

    nodeList = digraph.vertices.toList();
    edgeList = <RustEdge>[];
    for (var node in nodeList) {
      final connectedNodes = digraph.edges(node);
      final fromIndex = nodeList.indexOf(node);
      for (var connectedNode in connectedNodes) {
        final toIndex = nodeList.indexOf(connectedNode);
        edgeList.add(RustEdge(fromIndex: fromIndex, toIndex: toIndex));
      }
    }

    print('calling layout graph...');

    final newPositions =
        await api.layoutGraph(numberOfNodes: nodeList.length, edges: edgeList);

    setState(() {
      positions = newPositions;
    });

    print('positions:');
    for (var position in positions) {
      print("${position.x}, ${position.y}, ${position.z}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SizedBox.expand(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              globalOffset = globalOffset + details.delta;
            });
          },
          child: Container(
            color: Colors.black.withAlpha(1),
            child: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      if (nodeList.length != positions.length) {
                        return const SizedBox();
                      }

                      return CustomPaint(
                        painter: _GraphPainter(
                          nodeList: nodeList,
                          positions: positions,
                          edgeList: edgeList,
                          globalOffset: globalOffset,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<String> nodeList;
  final List<Position> positions;
  final List<RustEdge> edgeList;
  final Offset globalOffset;

  _GraphPainter({
    required this.nodeList,
    required this.positions,
    required this.edgeList,
    required this.globalOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeList.length != positions.length) {
      print('nodeList.length: ${nodeList.length}, '
          'positions.length: ${positions.length}');
      return;
    }

    const scale = 32.0;
    const zScale = 0.02;

    // paint edges
    for (var edge in edgeList) {
      final fromPosition = positions[edge.fromIndex];
      final toPosition = positions[edge.toIndex];

      final fromOffset =
          (Offset(fromPosition.x, fromPosition.y) * scale + globalOffset) *
              (1.0 + fromPosition.z * zScale);
      final toOffset =
          (Offset(toPosition.x, toPosition.y) * scale + globalOffset) *
              (1.0 + toPosition.z * zScale);

      const steps = 8;
      for (int i = 0; i < steps; i += 1) {
        final fromSegmentPosition = i.remap(0, steps, 0.0, 1.0);
        final toSegmentPosition = (i + 1).remap(0, steps, 0.0, 1.0);

        final z = (i + 0.5).remap(0, steps, fromPosition.z, toPosition.z);

        final paint = Paint()
          ..color =
              Colors.blue.withOpacity((1.0 - z.abs() * 0.01).clamp(0.0, 1.0))
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, z.abs() * 0.05 + 0.5);

        canvas.drawLine(
          fromOffset + (toOffset - fromOffset) * fromSegmentPosition,
          fromOffset + (toOffset - fromOffset) * toSegmentPosition,
          paint,
        );
      }
    }

    // paint nodes
    for (var i = 0; i < nodeList.length; i += 1) {
      final node = nodeList[i];
      final position = positions[i];

      final offset = (Offset(position.x, position.y) * scale + globalOffset) *
          (1.0 + position.z * zScale);

      final paint = Paint()
        ..color = Colors.blue
            .withOpacity((1.0 - position.z.abs() * 0.01).clamp(0.0, 1.0))
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, position.z.abs() * 0.05);

      canvas.drawCircle(offset, (position.z + 20.0) * 0.2 + 2.0, paint);

      final span = TextSpan(
        text: node.split('/').last,
        style: TextStyle(
          color: Colors.black
              .withOpacity((1.0 - position.z.abs() * 0.01).clamp(0.0, 1.0)),
          fontSize: 6.0,
        ),
      );
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        offset + Offset(tp.width * -0.5, 4.0),
      );
    }
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) {
    return nodeList.length != oldDelegate.nodeList.length ||
        globalOffset != oldDelegate.globalOffset;
  }
}
