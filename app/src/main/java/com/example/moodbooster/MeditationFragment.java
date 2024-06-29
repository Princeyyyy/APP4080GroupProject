package com.example.moodbooster;

import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

public class MeditationFragment extends Fragment {

    private TextView timerTextView;
    private Button startStopButton;
    private Spinner durationSpinner;
    private Spinner soundSpinner;
    private Button playSoundButton;
    private Button stopSoundButton;

    private CountDownTimer countDownTimer;
    private boolean timerRunning = false;
    private long timeLeftInMillis = 0;

    private MediaPlayer mediaPlayer;

    private final int[] durations = {1, 5, 10, 15, 20, 30}; // in minutes
    private final int[] sounds = {R.raw.ocean_waves, R.raw.forest_sounds, R.raw.rain};
    private final String[] soundNames = {"Ocean Waves", "Forest Sounds", "Rain"};

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_meditation, container, false);

        timerTextView = view.findViewById(R.id.timerTextView);
        startStopButton = view.findViewById(R.id.startStopButton);
        durationSpinner = view.findViewById(R.id.durationSpinner);
        soundSpinner = view.findViewById(R.id.soundSpinner);
        playSoundButton = view.findViewById(R.id.playSoundButton);
        stopSoundButton = view.findViewById(R.id.stopSoundButton);

        setupDurationSpinner();
        setupSoundSpinner();

        startStopButton.setOnClickListener(v -> {
            if (timerRunning) {
                stopTimer();
            } else {
                startTimer();
            }
        });

        playSoundButton.setOnClickListener(v -> playSound());
        stopSoundButton.setOnClickListener(v -> stopSound());

        return view;
    }

    private void setupDurationSpinner() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(), android.R.layout.simple_spinner_item);
        for (int duration : durations) {
            adapter.add(duration + " min");
        }
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        durationSpinner.setAdapter(adapter);
    }

    private void setupSoundSpinner() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(), android.R.layout.simple_spinner_item, soundNames);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        soundSpinner.setAdapter(adapter);
    }

    private void startTimer() {
        int selectedDuration = durations[durationSpinner.getSelectedItemPosition()];
        timeLeftInMillis = selectedDuration * 60 * 1000;

        countDownTimer = new CountDownTimer(timeLeftInMillis, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                timeLeftInMillis = millisUntilFinished;
                updateTimerText();
            }

            @Override
            public void onFinish() {
                timerRunning = false;
                startStopButton.setText("Start");
                timerTextView.setText("00:00");
            }
        }.start();

        timerRunning = true;
        startStopButton.setText("Stop");
    }

    private void stopTimer() {
        countDownTimer.cancel();
        timerRunning = false;
        startStopButton.setText("Start");
    }

    private void updateTimerText() {
        int minutes = (int) (timeLeftInMillis / 1000) / 60;
        int seconds = (int) (timeLeftInMillis / 1000) % 60;
        String timeLeftFormatted = String.format("%02d:%02d", minutes, seconds);
        timerTextView.setText(timeLeftFormatted);
    }

    private void playSound() {
        stopSound(); // Stop any currently playing sound
        int selectedSound = sounds[soundSpinner.getSelectedItemPosition()];
        mediaPlayer = MediaPlayer.create(requireContext(), selectedSound);
        mediaPlayer.setLooping(true);
        mediaPlayer.start();
    }

    private void stopSound() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
            mediaPlayer = null;
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }
        stopSound();
    }
}