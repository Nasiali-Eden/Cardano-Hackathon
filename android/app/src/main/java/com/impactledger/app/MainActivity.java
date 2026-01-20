package com.impactledger.app;

import android.os.Bundle;
// import android.content.Context;
// import android.content.SharedPreferences;
// import android.content.pm.ApplicationInfo;
// import com.google.firebase.FirebaseApp;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Firebase App Check debug configuration is disabled for now.
        // boolean isDebuggable = (getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
        // if (isDebuggable) {
        //     FirebaseApp firebaseApp = FirebaseApp.getInstance();
        //     SharedPreferences prefs = getSharedPreferences(
        //             "com.google.firebase.appcheck.debug.store." + firebaseApp.getPersistenceKey(),
        //             Context.MODE_PRIVATE
        //     );
        //     prefs.edit()
        //             .putString(
        //                     "com.google.firebase.appcheck.debug.DEBUG_SECRET",
        //                     "your_key"
        //             )
        //             .apply();
        // }
    }
}