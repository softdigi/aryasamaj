import 'package:flutter/material.dart';

/// Global navigator key passed to GoRouter so we can navigate
/// from outside of a build context (e.g. FCM background handlers).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
