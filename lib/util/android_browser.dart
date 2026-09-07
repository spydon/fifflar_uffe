import 'package:flutter/foundation.dart';

bool get isAndroidBrowser =>
    kIsWeb && defaultTargetPlatform == TargetPlatform.android;
