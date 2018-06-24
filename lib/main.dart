import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Springy Slider',
      theme: new ThemeData(
        primaryColor: Color(0xFFFF6688),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Text(title,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: isOnLight ? Theme.of(context).primaryColor : Colors.white,
          )),
      onPressed: () {
        // TODO:
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(
            color: Theme.of(context).primaryColor,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
            ),
            onPressed: () {
              // TODO:
            },
          ),
          actions: [
            _buildTextButton('settings'.toUpperCase(), true),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SpringySlider(
                markCount: 12,
                positiveColor: Theme.of(context).primaryColor,
                negativeColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            new Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  _buildTextButton('more'.toUpperCase(), false),
                  new Expanded(child: new Container()),
                  _buildTextButton('stats'.toUpperCase(), false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SpringySlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringySlider({
    this.markCount,
    this.positiveColor,
    this.negativeColor,
  });

  @override
  _SpringySliderState createState() => new _SpringySliderState();
}

class _SpringySliderState extends State<SpringySlider> with TickerProviderStateMixin {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  SpringySliderController sliderController;

  @override
  void initState() {
    super.initState();
    sliderController = new SpringySliderController(
      sliderPercent: 0.5,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    double sliderPercent = sliderController.sliderValue;
    if (sliderController.state == SpringySliderState.springing) {
      sliderPercent = sliderController.springingPercent;
    }

    return SliderDragger(
      sliderController: sliderController,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      child: Stack(
        children: <Widget>[
          SliderMarks(
            markCount: widget.markCount,
            markColor: widget.positiveColor,
            backgroundColor: widget.negativeColor,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          SliderGoo(
            sliderPercent: sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
            child: SliderMarks(
              markCount: widget.markCount,
              markColor: widget.negativeColor,
              backgroundColor: widget.positiveColor,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom,
            ),
          ),
          new SliderPoints(
            sliderPercent: sliderController.state == SpringySliderState.dragging
                ? sliderController.draggingPercent
                : sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          new SliderDebug(
            sliderPercent: sliderController.state == SpringySliderState.dragging
                ? sliderController.draggingPercent
                : sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
        ],
      ),
    );
  }
}

class SliderDebug extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderDebug({
    this.sliderPercent,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight - paddingTop - paddingBottom;

        return Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              right: 0.0,
              top: height * (1.0 - sliderPercent) + paddingTop,
              child: Container(
                height: 2.0,
                color: Colors.black,
              ),
            )
          ],
        );
      },
    );
  }
}

class SliderDragger extends StatefulWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  SliderDragger({
    this.sliderController,
    this.paddingTop,
    this.paddingBottom,
    this.child,
  });

  @override
  _SliderDraggerState createState() => _SliderDraggerState();
}

class _SliderDraggerState extends State<SliderDragger> {
  double startDragY;
  double startDragPercent;

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = widget.sliderController.sliderValue;

    widget.sliderController.onDragStart();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height - widget.paddingTop - widget.paddingBottom;
    final dragPercent = dragDistance / sliderHeight;

    widget.sliderController.draggingPercent = startDragPercent + dragPercent;
  }

  void _onPanEnd(DragEndDetails details) {
    startDragY = null;
    startDragPercent = null;

    widget.sliderController.onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

class SliderGoo extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  SliderGoo({
    this.sliderPercent,
    this.paddingTop,
    this.paddingBottom,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SliderClipper(
        sliderPercent: sliderPercent,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
      ),
      child: child,
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks({
    this.markCount,
    this.markColor,
    this.backgroundColor,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: new SliderMarksPainter(
        markCount: markCount,
        markColor: markColor,
        backgroundColor: backgroundColor,
        markThickness: 2.0,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
        paddingRight: 20.0,
      ),
      child: Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;

  final int markCount;
  final Color markColor;
  final Color backgroundColor;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;
  final Paint backgroundPaint;

  SliderMarksPainter({
    this.markCount,
    this.markColor,
    this.backgroundColor,
    this.markThickness,
    this.paddingTop,
    this.paddingBottom,
    this.paddingRight,
  })  : markPaint = new Paint()
          ..color = markColor
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
        backgroundPaint = new Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(
        0.0,
        0.0,
        size.width,
        size.height,
      ),
      backgroundPaint,
    );

    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        markWidth = lerpDouble(smallMarkWidth, largeMarkWidth, 0.5);
      }

      final markY = i * gap + paddingTop;

      canvas.drawLine(
        new Offset(size.width - paddingRight - markWidth, markY),
        new Offset(size.width - paddingRight, markY),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SliderClipper extends CustomClipper<Path> {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({
    this.sliderPercent,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Path getClip(Size size) {
    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingBottom) - top;
    final percentFromBottom = 1.0 - sliderPercent;

    rect.addRect(
      new Rect.fromLTRB(
        0.0,
        top + (percentFromBottom * height),
        size.width,
        bottom,
      ),
    );

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class SliderPoints extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderPoints({
    this.sliderPercent,
    this.paddingTop,
    this.paddingBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final height = constraints.maxHeight;
          final sliderY = height * (1.0 - sliderPercent);
          final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
          final pointsYouHave = 100 - pointsYouNeed;

          return Stack(
            children: <Widget>[
              Positioned(
                left: 30.0,
                top: sliderY - 50.0,
                child: FractionalTranslation(
                  translation: Offset(0.0, -1.0),
                  child: new Points(
                    points: pointsYouNeed,
                    isAboveSlider: true,
                    isPointsYouNeed: true,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Positioned(
                left: 30.0,
                top: sliderY + 50.0,
                child: new Points(
                  points: pointsYouHave,
                  isAboveSlider: false,
                  isPointsYouNeed: false,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  Points({
    this.points,
    this.isAboveSlider = true,
    this.isPointsYouNeed = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);

    return Row(
      crossAxisAlignment: isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        FractionalTranslation(
          translation: Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: Text(
            '$points',
            style: TextStyle(
              fontSize: pointTextSize,
              color: color,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'POINTS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Text(
                isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class SpringySliderController extends ChangeNotifier {
  final SpringDescription sliderSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 1000.0,
    damping: 30.0,
  );

  final TickerProvider _vsync;

  SpringySliderState _state = SpringySliderState.idle;

  // Stable slider value.
  double _sliderPercent;

  // Slider value during user drag.
  double _draggingPercent;

  // When springing to new slider value, this is where the UI is springing from.
  double _springStartPercent;
  // When springing to new slider value, this is where the UI is springing to.
  double _springEndPercent;
  // Current slider value during spring effect.
  double _springingPercent;
  // Physics spring.
  SpringSimulation _sliderSpringSimulation;
  // Ticker that computes current spring position based on time.
  Ticker _springTicker;
  // Elapsed time that has passed since the start of the spring.
  double _springTime;

  SpringySliderController({
    double sliderPercent = 0.0,
    vsync,
  })  : _vsync = vsync,
        _sliderPercent = sliderPercent;

  void dispose() {
    if (_springTicker != null) {
      _springTicker.dispose();
    }

    super.dispose();
  }

  SpringySliderState get state => _state;

  double get sliderValue => _sliderPercent;

  set sliderValue(double newValue) {
    _sliderPercent = newValue;
    notifyListeners();
  }

  double get draggingPercent => _draggingPercent;

  set draggingPercent(double newValue) {
    _draggingPercent = newValue;
    notifyListeners();
  }

  void onDragStart() {
    if (_springTicker != null) {
      _springTicker
        ..stop()
        ..dispose();
    }

    _state = SpringySliderState.dragging;
    _draggingPercent = _sliderPercent;

    notifyListeners();
  }

  void onDragEnd() {
    _state = SpringySliderState.springing;

    _springingPercent = _sliderPercent;
    _springStartPercent = _sliderPercent;
    _springEndPercent = _draggingPercent.clamp(0.0, 1.0);

    _draggingPercent = null;

    _sliderPercent = _springEndPercent;

    _startSpringing();

    notifyListeners();
  }

  void _startSpringing() {
    _sliderSpringSimulation = new SpringSimulation(
      sliderSpring,
      _springStartPercent,
      _springEndPercent,
      0.0,
    );

    _springTime = 0.0;

    _springTicker = _vsync.createTicker(_springTick)..start();
  }

  void _springTick(Duration deltaTime) {
    _springTime += deltaTime.inMilliseconds.toDouble() / 1000.0;
    _springingPercent = _sliderSpringSimulation.x(_springTime);

    if (_sliderSpringSimulation.isDone(_springTime)) {
      _springTicker
        ..stop()
        ..dispose();
      _springTicker = null;

      _state = SpringySliderState.idle;
    }

    notifyListeners();
  }

  double get springingPercent => _springingPercent;

  set springingPercent(double newValue) {
    _springingPercent = newValue;
    notifyListeners();
  }
}

enum SpringySliderState {
  idle,
  dragging,
  springing,
}
