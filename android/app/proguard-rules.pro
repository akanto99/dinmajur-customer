# Flutter's own embedding classes are already kept by the Flutter Gradle plugin's
# default rules. The entries below cover this app's plugins that rely on
# reflection and aren't always fully covered by their bundled consumer rules.

# OneSignal push notifications
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Firebase / Google Play services (messaging, maps)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Socket.IO / engine.io (uses reflection for its transport implementations)
-keep class io.socket.** { *; }
-dontwarn io.socket.**

# Facebook SDK (facebook_app_events) - relies on reflection internally;
# without these, R8 can strip/rename classes it needs in release builds,
# causing App Events to silently stop reaching Events Manager.
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Gson-based (or similar) model classes some plugins deserialize via reflection
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends java.lang.Exception
