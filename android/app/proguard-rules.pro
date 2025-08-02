# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Isar database rules
-keep class * extends com.isar.IsarGenerated { *; }
-keep class * implements com.isar.IsarEmbedded { *; }
-keepclassmembers class * {
    @com.isar.IsarId *;
    @com.isar.IsarIndex *;
    @com.isar.IsarLink *;
    @com.isar.IsarBacklink *;
}

# Retrofit rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# OkHttp rules
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Dio rules
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**
-dontwarn okio.**

# JSON serialization rules
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep model classes
-keep class com.example.flowmind.data.models.** { *; }

# Keep service classes
-keep class com.example.flowmind.features.**.services.** { *; }

# Keep utility classes
-keep class com.example.flowmind.core.** { *; }

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep onClick methods
-keepclassmembers class * {
    public void onClick(android.view.View);
}

# Keep WebView
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Firebase (if used)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep OAuth2
-keep class com.google.api.client.** { *; }
-keep class com.google.api.services.** { *; }
-dontwarn com.google.api.client.**
-dontwarn com.google.api.services.**

# Keep file picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Keep secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Keep notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep charts
-keep class com.github.mikephil.charting.** { *; }
-dontwarn com.github.mikephil.charting.**

# Keep Lottie
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# Keep Shimmer
-keep class com.facebook.shimmer.** { *; }
-dontwarn com.facebook.shimmer.**

# Keep Cached Network Image
-keep class com.github.bumptech.glide.** { *; }
-dontwarn com.github.bumptech.glide.**

# Keep Quill Editor
-keep class io.flutter.plugins.flutter_quill.** { *; }
-dontwarn io.flutter.plugins.flutter_quill.**

# Keep Audio Players
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Keep Record
-keep class com.llfbandit.record.** { *; }
-dontwarn com.llfbandit.record.**

# Keep Share Plus
-keep class io.flutter.plugins.share.** { *; }
-dontwarn io.flutter.plugins.share.**

# Keep Clipboard
-keep class io.flutter.plugins.clipboard.** { *; }
-dontwarn io.flutter.plugins.clipboard.**

# Keep Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Keep Timeago
-keep class com.jaumard.** { *; }
-dontwarn com.jaumard.**

# Keep UUID
-keep class com.example.uuid.** { *; }
-dontwarn com.example.uuid.**

# Keep Logger
-keep class com.example.logger.** { *; }
-dontwarn com.example.logger.**

# Keep GetIt
-keep class com.example.get_it.** { *; }
-dontwarn com.example.get_it.**

# Keep Injectable
-keep class com.example.injectable.** { *; }
-dontwarn com.example.injectable.**

# Keep BLoC
-keep class com.example.bloc.** { *; }
-dontwarn com.example.bloc.**

# Keep Go Router
-keep class com.example.go_router.** { *; }
-dontwarn com.example.go_router.**

# Keep Flutter SVG
-keep class com.example.flutter_svg.** { *; }
-dontwarn com.example.flutter_svg.**

# Keep Flutter Local Notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep FL Chart
-keep class com.example.fl_chart.** { *; }
-dontwarn com.example.fl_chart.**

# Keep Flutter Quill
-keep class io.flutter.plugins.flutter_quill.** { *; }
-dontwarn io.flutter.plugins.flutter_quill.**

# Keep Record
-keep class com.llfbandit.record.** { *; }
-dontwarn com.llfbandit.record.**

# Keep Audio Players
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.** 