package com.slins.flutterfft;

import java.util.List;

import io.flutter.plugin.common.MethodChannel;

interface AudioInterface {
    void startRecorder(List<Object> tuning, Integer numChannels, Integer sampleRate, int androidAudioSource, Float tolerance, MethodChannel.Result result);
    void stopRecorder(MethodChannel.Result result);
    void setSubscriptionDuration(double sec, MethodChannel.Result result);
    void checkIfPermissionGranted();
    void initializeAudioRecorder(MethodChannel.Result result, List<Object> tuning, Integer sampleRate, Integer numChannels, int androidAudioSource, Float tolerance);
}