package com.example.city_watch; // Ensure this matches your package name

import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.os.Bundle;
import com.google.firebase.FirebaseApp;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        boolean isDebuggable = (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;

        if (isDebuggable) { // Check if app is in debug mode
            FirebaseApp firebaseApp = FirebaseApp.getInstance(); // Get Firebase instance

            SharedPreferences prefs = getSharedPreferences(
                    "com.google.firebase.appcheck.debug.store." + firebaseApp.getPersistenceKey(),
                    Context.MODE_PRIVATE
            );

            prefs.edit()
                    .putString(
                            "com.google.firebase.appcheck.debug.DEBUG_SECRET",
                            "your_key"
                    )
                    .apply();
        }
    }
}
