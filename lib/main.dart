import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

ByteData? bytes;
FragmentProgram? program;

// final bytes = await rootBundle.load('assets/creation.spv');
// FragmentProgram? program = await FragmentProgram.compile(spirv: bytes.buffer);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      home: FutureBuilder(
          future: rootBundle.load('assets/creation.spv'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              bytes = snapshot.data as ByteData;
              return FutureBuilder(
                  future: FragmentProgram.compile(spirv: bytes!.buffer),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      program = snapshot.data as FragmentProgram;
                      return const MyApp();
                    } else {
                      return const CircularProgressIndicator();
                    }
                  });
            } else {
              return const CircularProgressIndicator();
            }
          })));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: Sky(),
      child: const Center(
        child: Text(
          'Once upon a time...',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}

class Sky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const RadialGradient gradient = RadialGradient(
      center: Alignment(0.7, -0.6),
      radius: 0.2,
      colors: <Color>[Color(0xFFFFFF00), Color(0xFF0099FF)],
      stops: <double>[0.4, 1.0],
    );

    canvas.drawRect(
      rect,
      // Paint()..shader = gradient.createShader(rect),
      Paint()..shader = program!.shader(),
    );
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a rectangle containing the picture of the sun
      // with the label "Sun". When text to speech feature is enabled on the
      // device, a user will be able to locate the sun on this picture by
      // touch.
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(Sky oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => false;
}
