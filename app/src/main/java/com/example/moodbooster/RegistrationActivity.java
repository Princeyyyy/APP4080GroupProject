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

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class RegistrationActivity extends AppCompatActivity {

    private EditText regEmail;
    private EditText regPassword;
    private EditText regUsername;
    private Button btnReg;

    private FirebaseAuth mAuth;
    private ProgressBar load;
    private FirebaseFirestore db;

    private ImageView shownhide;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);

        regEmail = findViewById(R.id.regEmail);
        regPassword = findViewById(R.id.regPassword);
        regUsername = findViewById(R.id.regUsername);
        btnReg = findViewById(R.id.btnReg);

        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
        load = findViewById(R.id.register_load);

        //Show/Hide Password
        shownhide = findViewById(R.id.regshow);
        shownhide.setImageResource(R.drawable.ic_show_pwd);
        shownhide.setOnClickListener(view -> {
            if (regPassword.getTransformationMethod().equals(HideReturnsTransformationMethod.getInstance())) {
                //If password is visible then hide it
                regPassword.setTransformationMethod(PasswordTransformationMethod.getInstance());
                //Change Icon
                shownhide.setImageResource(R.drawable.ic_show_pwd);
            } else {
                //Show password
                regPassword.setTransformationMethod(HideReturnsTransformationMethod.getInstance());
                //Change Icon
                shownhide.setImageResource(R.drawable.ic_hide_pwd);
            }
        });

        btnReg.setOnClickListener(v -> registerUser());
    }

    private void registerUser() {
        String email = regEmail.getText().toString().trim();
        String password = regPassword.getText().toString().trim();
        String username = regUsername.getText().toString().trim();

        if (TextUtils.isEmpty(username)) {
            regUsername.setError("Username is required");
            return;
        }

        if (TextUtils.isEmpty(email)) {
            regEmail.setError("Email is required");
            return;
        }

        if (TextUtils.isEmpty(password)) {
            regPassword.setError("Password is required");
            return;
        }

        load.setVisibility(View.VISIBLE);
        btnReg.setEnabled(false);
        btnReg.setText("Creating Account");

        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(task -> {
                    if (task.isSuccessful()) {
                        String userId = Objects.requireNonNull(mAuth.getCurrentUser()).getUid();

                        Map<String, Object> user = new HashMap<>();
                        user.put("username", username);

                        db.collection("users").document(userId)
                                .set(user)
                                .addOnSuccessListener(aVoid -> {
                                    load.setVisibility(View.GONE);
                                    Toast.makeText(RegistrationActivity.this, "User registered successfully", Toast.LENGTH_SHORT).show();
                                    // Navigate to the next activity (e.g., MainActivity or LoginActivity)
                                    startActivity(new Intent(RegistrationActivity.this, DashboardActivity.class));
                                    finish();
                                })
                                .addOnFailureListener(e -> {
                                    load.setVisibility(View.GONE);
                                    btnReg.setEnabled(true);
                                    btnReg.setText("Create Account");
                                    Toast.makeText(RegistrationActivity.this, "Error saving user data: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                                });
                    } else {
                        load.setVisibility(View.GONE);
                        btnReg.setEnabled(true);
                        btnReg.setText("Create Account");
                        Toast.makeText(RegistrationActivity.this, "Registration failed: " + Objects.requireNonNull(task.getException()).getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }

    public void onLoginClick(View view) {
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
    }
}