package com.slins.flutterfft;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Handler;
import android.media.AudioRecord;
import android.util.Log;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import be.tarsos.dsp.pitch.FastYin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class FlutterFftPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, AudioInterface {

    final public static String TAG = "FlutterFftPlugin"; // ANDROID STUDIO DEBUG CHANNEL

    final private static String RECORD_STREAM = "com.slins.flutterfft/record"; // PLATFORM CHANNEL NAME
    // ERROR CODES
    public static final String ERROR_RECORDER_IS_NULL = "ERROR_RECORDER_IS_NULL";
    public static final String ERROR_FAILED_RECORDER_INITIALIZATION = "ERROR_FAILED_RECORDER_INITIALIZATION";
    public static final String ERROR_RECORDER_IS_NOT_INITIALIZED = "ERROR_RECORDER_IS_NOT_INITIALIZED";
    public static final String ERROR_FAILED_RECORDER_PROGRESS = "ERROR_FAILED_RECORDER_PROGRESS";
    public static final String ERROR_FAILED_RECORDER_UPDATE = "ERROR_FAILED_RECORDER_UPDATE";
    public static final String ERROR_WRONG_BUFFER_SIZE = "ERROR_WRONG_BUFFER_SIZE";
    public static final String ERROR_FAILED_FREQUENCIES_AND_OCTAVES_INSTANTIATION = "ERROR_FAILED_FREQUENCIES_AND_OCTAVES_INSTANTIATION";

    public static int bufferSize; // AUDIO DATA BUFFER SIZE

    private boolean doneBefore = false;

    public static float frequency = 0; // FREQUENCY THAT GETS RETURNED TO THE FLUTTER APPLICATION

    public static String note = ""; // NOTE THAT GETS RETURNED TO THE FLUTTER APPLICATION
    public static float target = 0;
    public static float distance = 0;
    public static int octave = 0; // OCTAVE THAT GETS RETURNED TO THE FLUTTER APPLICATION

    public static String nearestNote = "";
    public static float nearestTarget = 0;
    public static float nearestDistance = 0;
    public static int nearestOctave = 0;

    private final ExecutorService taskScheduler = Executors.newSingleThreadExecutor(); // MAIN THREAD

    private static Registrar reg; // REGISTERED PLUGIN

    final private AudioModel audioModel = new AudioModel(); // INITIALIZATION OF AUDIO MODEL CLASS
    final private PitchModel pitchModel = new PitchModel(); // INITIALIZATION OF PITCH MODEL CLASS

    public static MethodChannel channel; // PLATFORM CHANNEL

    final static public Handler recordHandler = new Handler(); // RECORDER HANDLER

    final static public Handler mainHandler = new Handler(); // MAIN APPLICATION HANDLER

    public static void registerWith(Registrar registrar) { // PLUGIN REGISTRATION AND METHOD CHANNEL INSTANTIATION
        channel = new MethodChannel(registrar.messenger(), RECORD_STREAM);
        channel.setMethodCallHandler(new FlutterFftPlugin());
        reg = registrar;
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {  // HANDLING METHOD CALLS
        switch (call.method) {
        case "startRecorder": // WHEN "startRecorder" GETS CALLED FROM FLUTTER, RUN LOCAL startRecorder method, with given parameters
            taskScheduler.submit(() -> {
                List<Object> tuning = call.argument("tuning");
                Integer sampleRate = call.argument("sampleRate"); // SAMPLE RATE, DEFAULT: 22050
                Integer numChannels = call.argument("numChannels"); // NUMBER OF CHANNELS, DEFAULT: 1
                int androidAudioSource = call.argument("androidAudioSource"); // AUDIO SOURCE, DEFAULT: MICROPHONE
                double tolerance = call.argument("tolerance"); // HOW APART CAN THE CURRENT PITCH AND TARGET PITCH BE TO CONSIDER IT ON PITCH, DEFAULT: 1.0
                startRecorder(tuning, numChannels, sampleRate, androidAudioSource, (float) tolerance, result); // CALL LOCAL "startRecorder" METHOD (JAVA IMPLEMENTATION)
            });
            break;
        case "stopRecorder":
            taskScheduler.submit(() -> stopRecorder(result)); // CALL METHOD THAT STOPS RECORDING
            break;
        case "setSubscriptionDuration":
            if (call.argument("sec") == null) return;
            double duration = call.argument("sec");
            setSubscriptionDuration(duration, result); // SET DURATION OF SUBSCRIPTION, IN OTHER WORDS, INTERVAL BETWEEN PITCH ESTIMATIONS
            break;
        default:
            result.notImplemented(); // IF THE METHOD THAT WAS CALLED FROM FLUTTER IS NOT ONE OF THE ABOVE, RETURN THIS
            break;
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) { // CHECK IF MICROPHONE RECORDING PERMISSION IS GRANTED
        final int REQUEST_RECORD_AUDIO_PERMISSION = 200;
        switch (requestCode) {
        case REQUEST_RECORD_AUDIO_PERMISSION:
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                return true;
            }
            break;
        }

        return false;
    }

    @Override
    public void startRecorder(List<Object> tuning, Integer numChannels, Integer sampleRate, int androidAudioSource, Float tolerance, final Result result) { // START RECORDING
        checkIfPermissionGranted(result); // CHECKS IF PERMISSION IS GRANTED

        if (!doneBefore) {
            try {
                pitchModel.getFrequenciesAndOctaves(result);
                doneBefore = true;
            }
            catch(Exception err) {
               result.error(ERROR_FAILED_FREQUENCIES_AND_OCTAVES_INSTANTIATION, "Could not get frequencies and octaves, error: " + err.toString(), null);
            }
        }

        initializeAudioRecorder(result, tuning, sampleRate, numChannels, androidAudioSource, tolerance); // INITIALIZE THE AUDIO RECORDER

        audioModel.getAudioRecorder().startRecording(); // START THE AUDIO RECORDER
        recordHandler.removeCallbacksAndMessages(null);

        audioModel.setRecorderTicker(() -> pitchModel.updateFrequencyAndNote(result, audioModel)); // PROCESS AUDIO IN LOOP

        recordHandler.post(audioModel.getRecorderTicker()); // UPDATES RECORD HANDLER

        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                result.success("Recorder successfully set up.");
            }
        }); // UPDATES THE MAIN HANDLER
    }

    @Override
    public void stopRecorder(final Result result) { // STOP RECORDING
        recordHandler.removeCallbacksAndMessages(null);

        if (audioModel.getAudioRecorder() == null) { // IF THE AUDIO RECORDER IS ALREADY NULL, IN OTHER WORDS, ALREADY STOPPED, RETURN AN ERROR
            result.error(ERROR_RECORDER_IS_NULL, "Can't stop recorder, it is NULL.", null);
        }

        audioModel.getAudioRecorder().stop();
        audioModel.getAudioRecorder().release();
        audioModel.setAudioRecorder(null);

        mainHandler.post(new Runnable() { // UPDATES THE MAIN HANDLER
            @Override
            public void run() {
                result.success("Recorder stopped.");
            }
        });
    }

    @Override
    public void setSubscriptionDuration(double sec, Result result) { // SET SUBSCRIPTION DURATION/INTERVAL (TIME INTERVAL IN WHICH THE PITCH GETS UPDATED)
        audioModel.subsDurationMillis = (int) (sec * 1000);
        result.success("setSubscriptionDuration: " + audioModel.subsDurationMillis);
    }

    @Override
    public void checkIfPermissionGranted(Result result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (reg.activity()
                    .checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                reg.activity().requestPermissions(new String[]{Manifest.permission.RECORD_AUDIO,}, 0);
                result.error(TAG, "NO PERMISSION GRANTED", Manifest.permission.RECORD_AUDIO);
            }
        }
    }

    @Override
    public void initializeAudioRecorder(Result result, List<Object> tuning, Integer sampleRate, Integer numChannels, int androidAudioSource, Float tolerance) {
        if (audioModel.getAudioRecorder() == null) { // IF THE AUDIO RECORDER IS NOT NULL, IN OTHER WORDS, NOT ALREADY RUNNING, WE START IT
            bufferSize = 0;

            try {
                bufferSize = AudioRecord.getMinBufferSize(sampleRate, numChannels, audioModel.audioFormat) * 3; // CALCULATE AND UPDATE BUFFER SIZE

                if (bufferSize != AudioRecord.ERROR_BAD_VALUE) { // CONTINUE WITH THE PROCESS IF THE BUFFER SIZE IS VALID, OTHERWISE RETURN AN ERROR
                    audioModel.setAudioRecorder(new AudioRecord(androidAudioSource, sampleRate, numChannels, audioModel.audioFormat, bufferSize)); // RECORDER INSTANTIATION
                    audioModel.setAudioData(new short[bufferSize / 2]); // AUDIO BUFFER INSTANTIATION
                    pitchModel.setPitchDetector(new FastYin(sampleRate, bufferSize / 2)); // PITCH DETECTOR INSTANTIATION
                    pitchModel.setTolerance(tolerance);
                    pitchModel.setTuning(tuning);
                }

                else {
                    result.error(ERROR_WRONG_BUFFER_SIZE, "Failed to initialize recorder, wrong buffer data: " + bufferSize, null);
                }

            } catch (Exception e) {
                result.error(ERROR_FAILED_RECORDER_INITIALIZATION, "Error: " + e.toString(), null);
            }


        } else {
            audioModel.getAudioRecorder().release();
        }
    }
}