# flutter_onnxruntime: keep the ONNX Runtime Java API when shrinking.
-keep class ai.onnxruntime.** { *; }

# Room reflectively calls the no-arg constructor of its generated *_Impl
# databases. The rule shipped by Room keeps the classes but not their members,
# so R8 drops that constructor and WorkManager (pulled in by ML Kit) throws
# "Failed to create an instance of androidx.work.impl.WorkDatabase" at startup.
-keep class * extends androidx.room.RoomDatabase { <init>(); }

# google_mlkit_text_recognition references every script recognizer; only Latin,
# Chinese and Devanagari are bundled (android/app/build.gradle.kts).
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
