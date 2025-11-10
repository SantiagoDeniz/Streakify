Android widget setup notes:
- This project includes sample layout files under android/app/src/main/res/layout and res/xml.
- Ensure you add the receiver entry to AndroidManifest.xml (also included here).
- The home_widget package requires additional native setup (see package README on pub.dev):
  https://pub.dev/packages/home_widget
- After adding the project to Android Studio, run `flutter pub get` and build/run on an Android device.