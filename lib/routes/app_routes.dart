// // 📁 lib/routes/app_routes.dart

// import 'package:flutter/material.dart';
// import 'package:move_m8/models/auth_model.dart';
// import 'package:move_m8/models/community_model.dart';
// import 'package:move_m8/views/auth/login_screen.dart';
// import 'package:move_m8/views/auth/register_screen.dart';
// import 'package:move_m8/views/auth/forgot_password_screen.dart';
// import 'package:move_m8/views/auth/two_factor_screen.dart';
// import 'package:move_m8/views/auth/reset_password_screen.dart';
// import 'package:move_m8/views/community/community_selection_screen.dart';
// import 'package:move_m8/views/community/community_home_screen.dart';
// import 'package:move_m8/views/profile/profile_screen.dart';

// class AppRoutes {
//   static const login             = '/login';
//   static const register          = '/register';
//   static const forgotPassword    = '/forgot-password';
//   static const twoFactor         = '/two-factor';
//   static const resetPassword     = '/reset-password';
//   static const selectCommunity   = '/select-community';
//   static const communityHome     = '/community/home';
//   static const profile             = '/profile';

//   static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());

//       case register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());

//       case forgotPassword:
//         return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

//       case twoFactor:
//         final email = settings.arguments as String;
//         return MaterialPageRoute(builder: (_) => TwoFactorScreen(email: email));

//       case resetPassword:
//         final token = settings.arguments as String;
//         return MaterialPageRoute(builder: (_) => ResetPasswordScreen(resetToken: token));

//       case selectCommunity:
//         final auth = settings.arguments as AuthModel;
//         return MaterialPageRoute(builder: (_) => CommunitySelectionScreen(user: auth));

//       case communityHome:
//         final comm = settings.arguments as CommunityModel;
//         return MaterialPageRoute(builder: (_) => CommunityHomeScreen(community: comm));
    
//       case profile:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());

//       default:
//         // Route inconnue → on redirige vers login
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
//     }
//   }
// }

// 📁 lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:move_m8/models/auth_model.dart';
import 'package:move_m8/models/community_model.dart';
import 'package:move_m8/models/activity_model.dart' as models;

import 'package:move_m8/views/auth/login_screen.dart';
import 'package:move_m8/views/auth/register_screen.dart';
import 'package:move_m8/views/auth/forgot_password_screen.dart';
import 'package:move_m8/views/auth/two_factor_screen.dart';
import 'package:move_m8/views/auth/reset_password_screen.dart';

import 'package:move_m8/views/community/community_selection_screen.dart';
import 'package:move_m8/views/community/community_home_screen.dart';

import 'package:move_m8/views/profile/profile_screen.dart';
import 'package:move_m8/views/profile/edit_profile_screen.dart';

import 'package:move_m8/views/activity/activity_detail_screen.dart';

class AppRoutes {
  // Auth
  static const login              = '/login';
  static const register           = '/register';
  static const forgotPassword     = '/forgot-password';
  static const twoFactor          = '/two-factor';
  static const resetPassword      = '/reset-password';

  // Communities
  static const communitySelection = '/community/selection';
  static const communityHome      = '/community/home';

  // Profile
  static const profile            = '/profile';
  static const editProfile        = '/profile/edit';

  // Activities
  static const activityDetail     = '/activity/detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ---------- Auth ----------
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case twoFactor: {
        // Attend un String (email)
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => TwoFactorScreen(email: email));
      }

      case resetPassword:
       final token = settings.arguments as String;
        return MaterialPageRoute(builder: (_) =>  ResetPasswordScreen(resetToken: token));

      // ---------- Communities ----------
      case communitySelection: {
        // Accepte:
        //  - AuthModel (pickMode=false par défaut)
        //  - Map<String, dynamic> {'user': AuthModel, 'pickMode': bool}
        final args = settings.arguments;
        late AuthModel user;
        var pickMode = false;

        if (args is AuthModel) {
          user = args;
        } else if (args is Map) {
          user = args['user'] as AuthModel;
          pickMode = (args['pickMode'] as bool?) ?? false;
        } else {
          throw ArgumentError('CommunitySelection requiert AuthModel ou {user, pickMode}.');
        }

        return MaterialPageRoute(
          builder: (_) => CommunitySelectionScreen(user: user, pickMode: pickMode),
        );
      }

      case communityHome: {
        final comm = settings.arguments as CommunityModel;
        return MaterialPageRoute(
          builder: (_) => CommunityHomeScreen(community: comm),
        );
      }

      // ---------- Profile ----------
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // ---------- Activities ----------
      case activityDetail: {
        final activity = settings.arguments as models.ActivityDetail;
        return MaterialPageRoute(
          builder: (_) => ActivityDetailScreen(activity: activity),
        );
      }

      // Fallback → login
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
