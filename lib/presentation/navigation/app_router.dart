import 'package:go_router/go_router.dart';
import '../Views/sayim_screen.dart';

import '../Views/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/sayim', builder: (context, state) => const SayimScreen()),
    ],
  );
}
