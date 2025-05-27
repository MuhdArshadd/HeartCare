# Keep TensorFlow Lite GPU Delegate and its options
-keep class org.tensorflow.lite.gpu.** { *; }

# Specifically keep inner classes and factory options
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }

# Prevent obfuscation or shrinking of TFLite GPU delegate
-dontwarn org.tensorflow.lite.gpu.**
