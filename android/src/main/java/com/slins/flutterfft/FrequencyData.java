package com.slins.flutterfft;

import java.util.Objects;

public class FrequencyData<F, S, T> {
    public final F first;
    public final S second;
    public final T third;

    public FrequencyData(F first, S second, T third) {
        this.first = first;
        this.second = second;
        this.third = third;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof FrequencyData)) {
            return false;
        }
        FrequencyData<?, ?, ?> fData = (FrequencyData<?, ?, ?>) o;
        return Objects.equals(fData.first, first) && Objects.equals(fData.second, second) && Objects.equals(fData.third, third);
    }

    @Override
    public int hashCode() {
        return (first == null ? 0 : first.hashCode()) ^ (second == null ? 0 : second.hashCode() ^ (third == null ? 0 : third.hashCode()));
    }

    @Override
    public String toString() {
        return "FrequencyData{" + String.valueOf(first) + " " + String.valueOf(second) + " " + String.valueOf(third) + "}";
    }

    public static <A, B, C> FrequencyData <A, B, C> create(A a, B b, C c) {
        return new FrequencyData<A, B, C>(a, b, c);
    }
}