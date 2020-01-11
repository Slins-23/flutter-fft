import 'package:flutter/material.dart';
import 'package:flutter_fft/flutter_fft.dart';

void main() => runApp(Application());

class Application extends StatefulWidget {
  @override
  ApplicationState createState() => ApplicationState();
}

class ApplicationState extends State<Application> {
  double
      frequency; // Frequency variable which will be updated with th-> data returned by the plugin.
  String
      note; // Note variable which will be updated with th-> data returned by the plugin
  bool
      isRecording; // Is recording variable which will be updated with th-> data returned by the plugin

  FlutterFft flutterFft = new FlutterFft();

  @override
  void initState() {
    // Initialize some values, then call the "_initialize()" function, which will initialize the recorder.
    isRecording = flutterFft.getIsRecording;
    frequency = flutterFft.getFrequency;
    note = flutterFft.getNote;
    super.initState();
    _initialize();
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
              // If the plugin is recording, return the current note, otherwise, return "Not recording..."
              isRecording
                  ? Text(
                      "Current note: $note",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    )
                  : Text(
                      "Not recording",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
              // If the plugin is recording, return the current frequency, otherwise, return "Not recording..."
              isRecording
                  ? Text(
                      "Current frequency: ${frequency.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    )
                  : Text(
                      "Not recording",
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

  _initialize() async {
    print("Starting recorder...");
    await flutterFft
        .startRecorder(); // Waits for the recorder to properly start.
    print("Recorder started.");
    setState(() => isRecording = flutterFft
        .getIsRecording); // Set the local "isRecording" variable to true once the recorder has started.

    // Listens to the update stream, whenever there's ne-> data, update the local "frequency" and "note"
    // with one of the values returned by the plugin.
    // Also update the plugin's local note and frequency variables.
    flutterFft.onRecorderStateChanged.listen(
      (data) => {
        setState(
          () => {
            // Data indexes at the end of file.
            frequency = data[1],
            note = data[2],
          },
        ),
        flutterFft.setNote = note,
        flutterFft.setFrequency = frequency,
      },
    );
  }

  // Tolerance (int) -> data[0]
  // Frequency (double) -> data[1];
  // Note (string) -> data[2];
  // Target (double) -> data[3];
  // Distance (double) -> data[4];
  // Octave (int) -> data[5];

  // NearestNote (string) -> data[6];
  // NearestTarget (double) -> data[7];
  // NearestDistance (double) -> data[8];
  // NearestOctave (int) -> data[9];

  // IsOnPitch (bool) -> data[10];
}
