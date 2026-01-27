import 'package:flutter/material.dart';
import '../features/notifications/notification_page.dart';

// auth
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/forgot_password_page.dart';

// core pages
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_page.dart';

// profile setup
import '../features/profile_setup/create_username_page.dart';
import '../features/profile_setup/select_favourite_page.dart';

class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';

  // profile setup flow
  static const createUsername = '/profile/create-username';
  static const selectFavourite = '/profile/select-favourite';

  static const notifications = '/notifications';

  static final routes = <String, WidgetBuilder>{
    onboarding: (_) => const OnboardingPage(),
    login: (_) => const LoginPage(),
    signup: (_) => const SignupPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    home: (_) => const HomePage(),

    createUsername: (_) => const CreateUsernamePage(),
    selectFavourite: (_) => const SelectFavouritePage(),

    notifications: (_) => const NotificationPage(),
  };
}
