import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Springy Slider',
      theme: new ThemeData(
        primaryColor: Color(0xFFFF6688),
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
    return Scaffold(
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
            child: Container(),
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
    );
  }
}
