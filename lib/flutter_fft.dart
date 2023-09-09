import 'dart:async';
import 'package:flutter/services.dart';

class FlutterFft {
  static const MethodChannel _channel =
      const MethodChannel("com.slins.flutterfft/record");

  StreamController<List<Object>>? _recorderController;

  /// Returns the recorder stream
  Stream<List<Object>> get onRecorderStateChanged =>
      _recorderController!.stream;

  bool _isRecording = false;

  double _subscriptionDuration = 0.25;

  int _numChannels = 1;
  int _sampleRate = 44100;
  AndroidAudioSource _androidAudioSource = AndroidAudioSource.MIC;
  double _tolerance = 1.0;

  double _frequency = 0;

  String _note = "";
  double _target = 0;
  double _distance = 0;
  int _octave = 0;

  String _nearestNote = "";
  double _nearestTarget = 0;
  double _nearestDistance = 0;
  int _nearestOctave = 0;

  bool _isOnPitch = false;

  /// Highest to lowest string
  List<String> _tuning = ["E4", "B3", "G3", "D3", "A2", "E2"];

  /// Returns whether it's recording or not
  bool get getIsRecording => _isRecording;

  /// Returns subscription duration
  ///
  /// How often data gets updated
  double get getSubscriptionDuration => _subscriptionDuration;

  /// Returns channels
  int get getNumChannels => _numChannels;

  /// Returns sample rate
  int get getSampleRate => _sampleRate;

  /// Returns android audio source
  AndroidAudioSource get getAndroidAudioSource => _androidAudioSource;

  /// Returns tolerance
  ///
  /// How many HZ away can a frequency be from the target and still be considered on pitch
  double get getTolerance => _tolerance;

  /// Returns current frequency
  double get getFrequency => _frequency;

  /// Returns current note
  String get getNote => _note;

  /// Returns current target
  double get getTarget => _target;

  /// Returns distance between current frequecy and target
  double get getDistance => _distance;

  /// Returns current octave
  int get getOctave => _octave;

  /// Returns nearest target note
  ///
  /// Note which is in the tuning target and has the closest frequency
  String get getNearestNote => _nearestNote;

  /// Returns nearest target frequency
  ///
  /// Frequency which is in the tuning target and has the least distance to the current frequency
  double get getNearestTarget => _nearestTarget;

  /// Returns distance of the nearest target note
  ///
  /// Smallest distance between the current frequency and one (the nearest) that is in the tuning target
  double get getNearestDistance => _nearestDistance;

  /// Returns octave of the nearest target note
  int get getNearestOctave => _nearestOctave;

  /// Returns whether the current note/frequency is on pitch
  ///
  /// Considered on pitch when current frequency/note is in the tuning target and within a given error (local tolerance) of the closest frequency
  bool get getIsOnPitch => _isOnPitch;

  /// Returns current tuning
  ///
  /// List of strings where each element is a string containing 2 characters, the 1st is the note as an alphabetic letter and the 2nd is a number indicating the octave.
  /// i.e. ["E2", "A2", "D3", "G3", "B3", "E4"];
  List<String> get getTuning => _tuning;

  set setIsRecording(bool isRecording) => _isRecording = isRecording;
  set setSubscriptionDuration(double subscriptionDuration) =>
      _subscriptionDuration = subscriptionDuration;
  set setTolerance(double tolerance) => _tolerance = tolerance;
  set setFrequency(double frequency) => _frequency = frequency;

  set setNumChannels(int numChannels) => _numChannels = numChannels;
  set setSampleRate(int sampleRate) => _sampleRate = sampleRate;
  set setAndroidAudioSource(AndroidAudioSource androidAudioSource) =>
      _androidAudioSource = androidAudioSource;

  set setNote(String note) => _note = note;
  set setTarget(double target) => _target = target;
  set setDistance(double distance) => _distance = distance;
  set setOctave(int octave) => _octave = octave;

  set setNearestNote(String nearestNote) => _nearestNote = nearestNote;
  set setNearestTarget(double nearestTarget) => _nearestTarget = nearestTarget;
  set setNearestDistance(double nearestDistance) =>
      _nearestDistance = nearestDistance;
  set setNearestOctave(int nearestOctave) => _nearestOctave = nearestOctave;

  set setIsOnPitch(bool isOnPitch) => _isOnPitch = isOnPitch;

  set setTuning(List<String> tuning) => _tuning = tuning;

  /// Sets up the recorder stream and call handler
  Future<void> _setRecorderCallback() async {
    if (_recorderController == null) {
      _recorderController = new StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      // List<Object> newARGS = [
      //   call.arguments[0],
      //   call.arguments[1],
      //   call.arguments[2],
      //   call.arguments[3],
      //   call.arguments[4],
      //   call.arguments[5],
      //   call.arguments[6],
      //   call.arguments[7],
      //   call.arguments[8],
      //   call.arguments[9],
      //   call.arguments[10]
      // ];

      // List<Object> ok = call.arguments;

      // print("Runtime args: ${call.arguments.runtimeType}");
      // print("Runtime newARGS: ${newARGS.runtimeType}");
      // print("Equal?: ${call.arguments == newARGS}");
      // print("Equal2?: ${ok == newARGS}");
      // _recorderController!.add(newARGS);
      // _recorderController!.add(call.arguments.toString());
      // _recorderController!.add(["Equipe rocket"]);

      switch (call.method) {
        case "updateRecorderProgress":
          if (_recorderController != null) {
            List<Object> newARGS = [
              call.arguments[0],
              call.arguments[1],
              call.arguments[2],
              call.arguments[3],
              call.arguments[4],
              call.arguments[5],
              call.arguments[6],
              call.arguments[7],
              call.arguments[8],
              call.arguments[9],
              call.arguments[10]
            ];
            // print("Arguments: ${call.arguments}");
            // _recorderController!.add(call.arguments);
            _recorderController!.add(newARGS);
          } else {
            throw new ArgumentError(
                "updateRecorderProgress called but recorder controller is null.");
          }
          break;
        default:
          throw new ArgumentError("Unknown method: ${call.method}");
      }
      return null;
    });
  }

  /// Closes the recorder stream
  Future<void> _removeRecorderCallback() async {
    if (_recorderController != null) {}
    // _recorderController!.close();
    _recorderController!
      ..add([])
      ..close();
    _recorderController = null;
  }

  /// Returns whether microphone permission was granted
  Future<bool> checkPermission() async {
    return await _channel.invokeMethod("checkPermission");
  }

  /// Prompts the user to grant permission to use the microphone
  requestPermission() {
    _channel.invokeMethod("requestPermission");
  }

  /// Sets subscription duration, starts recorder from the platform channel, then sets up recorder stream
  Future<String> startRecorder() async {
    try {
      await _channel.invokeMethod("setSubscriptionDuration",
          <String, double>{'sec': this.getSubscriptionDuration});
    } catch (err) {
      print("Could not set subscription duration, error: $err");
    }

    if (this.getIsRecording) {
      throw new RecorderRunningException("Recorder is already running.");
    }

    try {
      String result =
          await _channel.invokeMethod('startRecorder', <String, dynamic>{
        'tuning': this.getTuning,
        'numChannels': this.getNumChannels,
        'sampleRate': this.getSampleRate,
        'androidAudioSource': this.getAndroidAudioSource.value,
        'tolerance': this.getTolerance,
      });

      _setRecorderCallback();
      this.setIsRecording = true;

      return result;
    } catch (err) {
      throw new Exception(err);
    }
  }

  /// Stops recorder from the platform channel, then closes recorder stream
  Future<String> stopRecorder() async {
    if (!this.getIsRecording) {
      throw new RecorderStoppedException("Recorder is not running.");
    }

    String result = await _channel.invokeMethod("stopRecorder");
    this.setIsRecording = false;
    _removeRecorderCallback();

    return result;
  }
}

class RecorderRunningException implements Exception {
  final String message;
  RecorderRunningException(this.message);
}

class RecorderStoppedException implements Exception {
  final String message;
  RecorderStoppedException(this.message);
}

class AndroidAudioSource {
  final _value;
  const AndroidAudioSource._internal(this._value);
  toString() => 'AndroidAudioSource.$_value';
  int get value => _value;

  static const DEFAULT = const AndroidAudioSource._internal(0);
  static const MIC = const AndroidAudioSource._internal(1);
  static const VOICE_UPLINK = const AndroidAudioSource._internal(2);
  static const VOICE_DOWNLINK = const AndroidAudioSource._internal(3);
  static const CAMCORDER = const AndroidAudioSource._internal(4);
  static const VOICE_RECOGNITION = const AndroidAudioSource._internal(5);
  static const VOICE_COMMUNICATION = const AndroidAudioSource._internal(6);
  static const REMOTE_SUBMIX = const AndroidAudioSource._internal(7);
  static const UNPROCESSED = const AndroidAudioSource._internal(8);
  static const RADIO_TUNER = const AndroidAudioSource._internal(9);
  static const HOTWORD = const AndroidAudioSource._internal(10);
}
