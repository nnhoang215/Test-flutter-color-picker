import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);



  @override
  State<MyHomePage> createState() => _MyHomePageState();
  final String title;
}

class _MyHomePageState extends State<MyHomePage> {
  Color cc = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              child: Row(
                children: [
                  Container(
                    color: cc,
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(width: 0.5, color: const Color(0x00000000)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ColorPicker(
                      width: 300, height: 30,
                      onChanged: (color) {
                        setState(() {
                          cc = color;
                        });
                        print(color);
                      },
                    ),
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}


class ColorPicker extends StatefulWidget {
  final double width;
  final double height;
  final ValueChanged<Color> onChanged;
  // final initColor;


  ColorPicker({
    Key? key,
    required this.width,
    required this.height,
    required this.onChanged,
    // required this.initColor
  }) : super(key: key);
  @override
  ColorPickerState createState() => ColorPickerState();
}
class ColorPickerState extends State<ColorPicker> {
  final List<Color> _colors = [
    const Color.fromARGB(255, 0, 0, 0),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 0, 128, 255),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 128),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 127, 0, 255),
    const Color.fromARGB(255, 128, 128, 128),
    const Color.fromARGB(255, 128, 255, 0),
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 0, 127),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 128, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 255, 255, 255),
  ];
  double _colorSliderPosition = 0;
  Color currentColor = Colors.white;
  double initSliderPosition = 0;

  @override
  void initState(){
    super.initState();
    currentColor = _calculateSelectedColor(_colorSliderPosition);
  }

  /*
    Có 2 việc phải làm:
    1. viết function(input màu) => initPosition
    2. sử dụng initSliderPosition để set vị trí ban đầu của Slider
  */

  Color _calculateSelectedColor(double position) {
    //determine color
    double positionInColorArray = (position / widget.width * (_colors.length - 1));
    int index = positionInColorArray.truncate();
    double remainder = positionInColorArray - index;
    if (remainder == 0.0) {
      currentColor = _colors[index];
    } else {
      //calculate new color
      int redValue = _colors[index].red == _colors[index + 1].red
        ? _colors[index].red
        : (_colors[index].red + (_colors[index + 1].red - _colors[index].red) * remainder).round();
      int greenValue = _colors[index].green == _colors[index + 1].green
        ? _colors[index].green
        : (_colors[index].green + (_colors[index + 1].green - _colors[index].green) * remainder).round();
      int blueValue = _colors[index].blue == _colors[index + 1].blue
        ? _colors[index].blue
        : (_colors[index].blue + (_colors[index + 1].blue - _colors[index].blue) * remainder).round();
      currentColor = Color.fromARGB(255, redValue, greenValue, blueValue);
    }
    return currentColor;
  }

  _colorChangeHandler(double position) {
    //handle out of bounds positions
    if (position > widget.width) {
      position = widget.width;
    }
    if (position < 0) {
      position = 0;
    }
    
    setState(() {
      _colorSliderPosition = position;
      currentColor = _calculateSelectedColor(_colorSliderPosition);
    });

    try {
      widget.onChanged.call(currentColor);
    } catch (err) {
      print(err);
    }
  }
  
  @override
  Widget build(BuildContext context) { 
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        _colorChangeHandler(details.localPosition.dx);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _colorChangeHandler(details.localPosition.dx);
      },
      onTapDown: (TapDownDetails details) {
        _colorChangeHandler(details.localPosition.dx);
      },
      //This outside padding makes it much easier to grab the   slider because the gesture detector has
      // the extra padding to recognize gestures inside of
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(colors: _colors),
        ),
        child: CustomPaint(
          painter: _SliderIndicatorPainter(_colorSliderPosition, widget.height),
        ),
      ),
    );
  }
}

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final double height;
  _SliderIndicatorPainter(this.position, this.height);

  @override
  void paint(Canvas canvas, Size size) {
    var topTrianglePath = Path();
    var bottomTrianglePath = Path();
 
    topTrianglePath.moveTo(position, 0);
    topTrianglePath.lineTo(position - 5, -8);
    topTrianglePath.lineTo(position + 5, -8);
    topTrianglePath.close();

    bottomTrianglePath.moveTo(position, height);
    bottomTrianglePath.lineTo(position - 5, height + 8);
    bottomTrianglePath.lineTo(position + 5, height + 8);
    bottomTrianglePath.close();
 
    canvas.drawPath(topTrianglePath, Paint()..color = const Color(0xFFC9C9C9));
    canvas.drawPath(bottomTrianglePath, Paint()..color = const Color(0xFFC9C9C9));
  }
  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}

