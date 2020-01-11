# Flutter Fft

Plugin at pub-dev: https://pub.dev/packages/flutter_fft

**Warning:** *Currently works only on Android! This plugin makes use of platform channels, and only the Java/Android platform channel has been implemented.*

**The plugin was developed and tested in a Pixel 2 emulator, API 29. Does not work on iOS at the moment, due to the platform channel having yet to be implemented.**

**Minimum SDK version >= 24**: You can update the minimum SDK requirements at `"/android/app/build.gradle"` in the line `minSdkVersion 16`.

The following needs to be added to your project's `"android/app/src/main/AndroidManifest.xml"`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

This is my first (and currently only) Flutter plugin and Java project.

I was gathering ideas my personal guitar tuner application on Flutter, when I realized that I couldn't find any examples of audio analysis/processing/manipulation with Flutter.

Flutter doesn't have great support for device specific hardware, such as microphone input. Obviously, it is the fundamental pillar for anything that deals with audio processing in real-time.  
Since Flutter has "just" started to become mainstream, there are still not many real-world projects or examples around.

The plan I ended up coming up with was to code a platform channel for android, which is basically a way to call native code from within Flutter - i.e. Calling Java functions through Dart code, using Flutter.

The problem with this is that, as it calls native platform code, the "one codebase" Flutter feature is rendered useless, since I would have to code the same thing for both platforms. (Objective-C/Swift for iOS & Java/Kotlin for Android)

Because of that, at the moment, I only coded the android platform channel. An iOS platform channel is in the plans for future versions.

## How to use

As mentioned above, this plugin was purely intended for usage in my personal project, however, since I couldn't find similar implementations, I decided to upload it here, in case anyone else goes through the same process.

Because of this, what you can do with the plugin is very strict: Start recording, get data back from the platform channel, and stop recording.

If you know how to program however, you can easily modify the code for your own needs.

There are many getters and setters for the processed and default data, which are going to be discussed further below.

Simple example:

```dart
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
    print("starting...");
    await flutterFft.startRecorder();
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
```

## Methods

When we instantiate the plugin, a method channel variable is created, with the tag `"com.slins.flutterfft/record"`.

This is the variable responsible for estabilishing a connection between Dart and the platform channel.

***For the section below, it is assumed that the plugin was instantiated and stored in a variable called "flutterFft".***

### Three main methods

1. `flutterFft.onRecorderStateChanged`
   - Stream that listens to the updates from the recorder..  
2. `flutterFft.startRecording()`
   - Starts recording using the data from the plugin's **local** instance. In other words,  if you want to pass custom values as arguments, you have to set them inside the `flutterFft` instance before starting the recorder. i.e. `flutterFft.setSampleRate = 22050`
3. `flutterFft.stopRecording()`
   - Stops recording.

### Variables, default values, getters, setters and descriptions

| Variable                | Default Value                          | Type                 | Getter                               | Setter                                                                                                                                                                                              | Description                                                                                                                                                                                                                                                               |
| ----------------------- | -------------------------------------- | -------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_tuning`               | `["E4", "B3", "G3", "D3", "A2", "E2"]` | `List<String>`       | `flutterFft.getTuning`               | `flutterFft.setTuning`      controller for the tuning target. Format: `["E4", "B3", "G3", "D3", "A2", "E2"]` (The detected frequency is compared to these values in order to gather the above data) |
| `_isRecording`          | `false`                                | `bool`               | `flutterFft.getIsRecording`          | `flutterFft.setIsRecording`                                                                                                                                                                         | Controller for the recorder state.                                                                                                                                                                                                                                        |
| `_subscriptionDuration` | `0.25`                                 | `double`             | `flutterFft.getSubscriptionDuration` | `flutterFft.setSubscriptionDuration`                                                                                                                                                                | Controller for the interval between platform channel function calls.                                                                                                                                                                                                      |
| `_numChannels`          | `1`                                    | `int`                | `flutterFft.getNumChannels`          | `flutterFft.setNumChannels`                                                                                                                                                                         | Controller for the number of channels that gets passed to the pitch detector.                                                                                                                                                                                             |
| `_sampleRate`           | `44100`                                | `int`                | `flutterFft.getSampleRate`           | `flutterFft.setSampleRate`                                                                                                                                                                          | Controller for the sample rate that gets passed to the pitch detector.                                                                                                                                                                                                    |
| `_androidAudioSource`   | `AndroidAudioSource.MIC`               | `AndroidAudioSource` | `flutterFft.getAndroidAudioSource`   | `flutterFft.setAndroidAudioSource`                                                                                                                                                                  | Controller for the audio source. (Microphone, etc.)                                                                                                                                                                                                                       |
| `_tolerance`            | `1.00`                                 | `double`             | `flutterFft.getTolerance`            | `flutterFft.setTolerance`                                                                                                                                                                           | Controller for the tolerance. (How far apart can the current frequency from the target frequency in order to be considered on pitch)                                                                                                                                      |
| `_frequency`            | `0`                                    | `double`             | `flutterFft.getFrequency`            | `flutterFft.setFrequency`                                                                                                                                                                           | Controller for the frequency.                                                                                                                                                                                                                                             |
| `_note`                 | `""`                                   | `String`             | `flutterFft.getNote`                 | `flutterFft.setNote`                                                                                                                                                                                | Controller for the note                                                                                                                                                                                                                                                   |
| `_target`               | `0`                                    | `double`             | `flutterFft.getTarget`               | `flutterFft.setTarget`                                                                                                                                                                              | Controller for the target frequency. (Based on the current selected tuning, calculate the nearest frequency in tune to be considered as the target, i.e: `IF currentNote == A && A.frequency.distanceToB IS SmallestTargetDistance -> _target = A.frequency.distanceToB`) |
| `_distance`             | `0`                                    | `double`             | `flutterFft.getDistance`             | `flutterFft.setDistance`                                                                                                                                                                            | Controller for the distance between the current frequency and the target frequency.                                                                                                                                                                                       |
| `_octave`               | `0`                                    | `int`                | `flutterFft.getOctave`               | `flutterFft.setOctave`                                                                                                                                                                              | Controller for the detected octave.                                                                                                                                                                                                                                       |
| `_nearestNote`          | `""`                                   | `String`             | `flutterFft.getNearestNote`          | `flutterFft.setNearestNote`                                                                                                                                                                         | Controller for nearest note. (Based on the current note)                                                                                                                                                                                                                  |
| `_nearestTarget`        | `0`                                    | `double`             | `flutterFft.getNearestTarget`        | `flutterFft.setNearestTarget`                                                                                                                                                                       | Controller for nearest target. (Second smallest distance, as the smallest distance is already `_target`)                                                                                                                                                                  |
| `_nearestDistance`      | `0`                                    | `double`             | `flutterFft.getNearestDistance`      | `flutterFft.setNearestDistance`                                                                                                                                                                     | Controller for nearest distance. (Second smallest distance)                                                                                                                                                                                                               |
| `_nearestOctave`        | `0`                                    | `int`                | `flutterFft.getNearestOctave`        | `flutterFft.setNearestOctave`                                                                                                                                                                       | Controller for nearest octave. (Based on the "nearest" data)                                                                                                                                                                                                              |
| `_isOnPitch`            | `false`                                | `bool`               | `flutterFft.getIsOnPitch`            | `flutterFft.setIsOnPitch`                                                                                                                                                                           | Controller for the pitch                                                                                                                                                                                                                                                  |
