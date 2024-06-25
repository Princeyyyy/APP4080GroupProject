package com.example.moodbooster;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.text.method.HideReturnsTransformationMethod;
import android.text.method.PasswordTransformationMethod;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;

import java.util.Objects;

public class LoginActivity extends AppCompatActivity {

    private EditText logEmail;
    private EditText logPassword;
    private Button logBtn;
    private FirebaseAuth mAuth;
    private ProgressBar load;
    private ImageView shownhide;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_login);

        logEmail = findViewById(R.id.logEmail);
        logPassword = findViewById(R.id.logPassword);
        logBtn = findViewById(R.id.btnLogin);

        mAuth = FirebaseAuth.getInstance();
        load = findViewById(R.id.login_load);

        //Show/Hide Password
        shownhide = findViewById(R.id.logshow);
        shownhide.setImageResource(R.drawable.ic_show_pwd);
        shownhide.setOnClickListener(view -> {
            if (logPassword.getTransformationMethod().equals(HideReturnsTransformationMethod.getInstance())) {
                //If password is visible the hide it
                logPassword.setTransformationMethod(PasswordTransformationMethod.getInstance());
                //Change Icon
                shownhide.setImageResource(R.drawable.ic_show_pwd);
            } else {
                //Show password
                logPassword.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                //Change Icon
                shownhide.setImageResource(R.drawable.ic_hide_pwd);
            }
        });

        if (mAuth.getCurrentUser() != null) {
            Intent intent = new Intent(LoginActivity.this, DashboardActivity.class);
            startActivity(intent);
        }

        logBtn.setOnClickListener(v -> {
            String emailString = logEmail.getText().toString();
            String passwordString = logPassword.getText().toString();

            if (TextUtils.isEmpty(emailString)) {
                logEmail.setError("Email is Required");
            }

            if (TextUtils.isEmpty(passwordString)) {
                logPassword.setError("Password is Required");
            } else {
                load.setVisibility(View.VISIBLE);
                logBtn.setEnabled(false);
                logBtn.setText("Logging in");

                mAuth.signInWithEmailAndPassword(emailString, passwordString).addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        load.setVisibility(View.GONE);
                        Intent intent = new Intent(LoginActivity.this, DashboardActivity.class);
                        startActivity(intent);
                        finish();
                    } else {
                        Toast.makeText(LoginActivity.this, Objects.requireNonNull(task.getException()).toString(), Toast.LENGTH_SHORT).show();
                        load.setVisibility(View.GONE);
                        logBtn.setText("Log in");
                        logBtn.setEnabled(true);
                    }
                });
            }
        });
    }

    public void onRegistrationClick(View view) {
        Intent intent = new Intent(this, RegistrationActivity.class);
        startActivity(intent);
    }
}