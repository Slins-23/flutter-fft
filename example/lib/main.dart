import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';

void main() => runApp(Application());

class Application extends StatefulWidget {
  @override
  ApplicationState createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  double frequency;
  String note;
  bool isRecording;

  FlutterFft flutterFft = new FlutterFft();

  @override
  void initState() {
    isRecording = flutterFft.getIsRecording;
    frequency = flutterFft.getFrequency;
    note = flutterFft.getNote;
    super.initState();
    _async();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple flutter fft example",
      theme: ThemeData.dark(),
      color: Colors.blue,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isRecording
                  ? Text(
                      "Current frequency: $note",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    )
                  : Text(
                      "None yet",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
              isRecording
                  ? Text(
                      "Current frequency: ${frequency.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    )
                  : Text(
                      "None yet",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  _async() async {
    print("Starting recorder...");
    await flutterFft.startRecorder();
    print("Recorder started.");
    setState(() => isRecording = flutterFft.getIsRecording);
    flutterFft.onRecorderStateChanged.listen(
      (data) => {
        setState(
          () => {
            frequency = data[1],
            note = data[2],
          },
        ),
        flutterFft.setNote = note,
        flutterFft.setFrequency = frequency,
      },
    );
  }
}
