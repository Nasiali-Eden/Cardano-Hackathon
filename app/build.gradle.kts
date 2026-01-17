plugins {
    id ("com.android.application") version "8.7.0" apply false
    id ("org.jetbrains.kotlin.android") version "2.0.20" apply false

    application
}


repositories {
    google()
    // Use Maven Central for resolving dependencies.
    mavenCentral()
}

dependencies {
    // Use JUnit test framework.
    testImplementation("org.junit.jupiter:junit-jupiter:5.8.1")

    testImplementation("junit:junit:4.13.2")

    // This dependency is used by the application.
    implementation("com.google.guava:guava:31.1-jre")

    implementation ("com.google.android.gms:play-services-phenotype:17.0.0")
    implementation("com.google.android.gms:play-services-base:18.5.0")
    // Import the BoM for the Firebase platform
    implementation(platform("com.google.firebase:firebase-bom:33.8.0"))

    // Add the dependencies for the App Check libraries
    implementation("com.google.android.play:integrity:1.4.0")
    // When using the BoM, you don't specify versions in Firebase library dependencies
    implementation("com.google.firebase:firebase-appcheck-playintegrity")
    implementation ("com.google.firebase:firebase-appcheck-debug")

}

// Apply a specific Java toolchain to ease working on different environments.
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

application {
    // Define the main class for the application.
    mainClass.set("org.example.App")
}