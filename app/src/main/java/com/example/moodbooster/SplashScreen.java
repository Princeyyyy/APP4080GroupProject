package com.example.moodbooster;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;

public class SplashScreen extends AppCompatActivity {

    private static int SPLASH = 3000;
    Animation animation;
    private ImageView appImage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);

        appImage = findViewById(R.id.appImage);

        animation = AnimationUtils.loadAnimation(this, R.anim.animation);
        appImage.setAnimation(animation);


        new Handler().postDelayed(() -> {
            Intent intent;
            intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            finish();
        }, SPLASH);
    }
}