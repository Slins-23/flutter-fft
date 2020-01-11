package com.slins.flutterfft;

import io.flutter.plugin.common.MethodChannel;

interface PitchInterface {
    void updateFrequencyAndNote(MethodChannel.Result result, AudioModel audioModel);
    void processPitch(float floatInHz, MethodChannel.Result result);
    void getFrequenciesAndOctaves(MethodChannel.Result result);
}
