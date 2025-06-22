# Keep TensorFlow Lite GPU Delegate and its options
-keep class org.tensorflow.lite.gpu.** { *; }

# Specifically keep inner classes and factory options
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }

# Prevent obfuscation or shrinking of TFLite GPU delegate
-dontwarn org.tensorflow.lite.gpu.**

## ---- GSON RULES (official) ----

# Keep generic signatures
-keepattributes Signature

# Keep annotations
-keepattributes *Annotation*

# Don’t warn about sun.misc
-dontwarn sun.misc.**

# Type adapters and serializers
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# SerializedName field protection
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Retain TypeToken metadata
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken


## ---- FLUTTER LOCAL NOTIFICATIONS PLUGIN ----

# Keep all classes and methods used by the plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Don’t warn about the plugin internals
-dontwarn com.dexterous.flutterlocalnotifications.**

# Keep ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }

# Keep ScheduledNotificationBootReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }

## ---- OPTIONAL: Keep your app's classes if referenced from native plugin code ----
# Update `your.app.package` accordingly
-keep class com.example.dummy_flutterlocalnotification2.** { *; }
