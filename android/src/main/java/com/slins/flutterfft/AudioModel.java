package com.slins.flutterfft;

import android.media.AudioFormat;
import android.media.AudioRecord;

public class AudioModel {
    protected int subsDurationMillis = 500; // DEFAULT INTERVAL (0.5s)

    private AudioRecord audioRecorder; // AUDIO RECORDER
    private Runnable recorderTicker; // RECORDER RUNNABLE

    protected int audioFormat = AudioFormat.ENCODING_PCM_16BIT; // FORMAT IN WHICH THE AUDIO GETS RECORDED AND PROCESSED

    private short[] audioData; // AUDIO DATA

    protected short[] getAudioData() {
        return audioData;
    } // AUDIO DATA GETTER

    protected void setAudioData(short[] audioData) {
        this.audioData = audioData;
    } // AUDIO DATA SETTER

    protected AudioRecord getAudioRecorder() {
        return audioRecorder;
    } // AUDIO RECORDER GETTER

    protected void setAudioRecorder(AudioRecord audioRecorder) {
        this.audioRecorder = audioRecorder;
    } // AUDIO RECORDER SETTER

    protected Runnable getRecorderTicker() {
        return recorderTicker;
    } // RECORDER RUNNABLE GETTER

    protected void setRecorderTicker(Runnable recorderTicker) {
        this.recorderTicker = recorderTicker;
    } // RECORDER RUNNABLE SETTER
}