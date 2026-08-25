/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/models/user.dart';
import 'package:adgo_mobile/modules/auth/view/screens/login_screen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/newpassword_screen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/reset_password_screen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/sent_verificationcode_forgotpw_screen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/sign_up_screen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/signup_verificationscreen.dart';
import 'package:adgo_mobile/modules/auth/view/screens/verify_forgot_password_otp.dart';
import 'package:adgo_mobile/modules/contact_details/view/screens/contact_details_screen.dart';
import 'package:adgo_mobile/modules/inbox/view/screens/inbox_screen.dart';
import 'package:adgo_mobile/modules/insert_details/view/screens/insert_details_screen.dart';
import 'package:adgo_mobile/modules/profile/view/screens/new_profile_screen.dart';
import 'package:adgo_mobile/modules/reel_screen/view/screens/reel_screen.dart';
import 'package:adgo_mobile/modules/search/view/screens/search_screen.dart';
import 'package:adgo_mobile/modules/seller_gallery/view/screens/seller_gallery_screen.dart';
import 'package:adgo_mobile/modules/settings/view/screens/settings_screen.dart';
import 'package:adgo_mobile/modules/shop/view/screens/welcome_screen.dart';
import 'package:adgo_mobile/modules/subscription/view/screens/subscription_screen.dart';
import 'package:adgo_mobile/modules/video_feed/view/screens/video_screen.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:adgo_mobile/routes/Routes.dart';
import 'package:go_router/go_router.dart';
import '../layout/base_layout.dart';
import '../modules/video_categories/view/video_categories_screen.dart';



GoRouter getRouter(String initialRoute)
{
  return GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.verificationScreen,
        builder: (context, state) => OtpVerificationScreen(data: state.extra as Map<String, String>,),
        ),
      GoRoute(
        path: Routes.resetpasswordScreen,
        builder: (context, state) => const ResetPasswordScreen(),
        ),
      GoRoute(
        path: Routes.sendVerificationCodeScreen,
        builder: (context, state) => SendVerificationCodeScreen(username: state.extra as String,),
        ),
      GoRoute(
        path: Routes.newPasswordScreen,
        builder: (context, state) => NewPasswordScreen(data: state.extra as Map<String, String>,),
        ),
        GoRoute(
        path: Routes.otpVerificationForgotPWScreen,
        builder: (context, state) => OtpVerificationForgotPWScreen(username: state.extra as String,),
        ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => LayoutScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: Routes.home,
              builder: (context, state) =>  const VideoGridScreen(), 
                  routes: [
                    GoRoute(
                      path: Routes.reelScreen,
                      builder: (context, state) => ReelScreen(
                        initialVideo: state.extra as VideoModel?,
                      ),
                ),
                ]
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.categories,
                builder: (context, state) => const VideoCategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.welcomeShop,
                builder: (context, state) => const WelcomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                      path: Routes.login,
                  builder: (context, state) => const LoginScreen()
                ),
                  GoRoute(
                      path: Routes.signUp,
                  builder: (context, state) => const SignUpScreen()
                ),
                  GoRoute(
                      path: Routes.settings,
                      builder: (context, state) => Settingsscreen(
                            user: state.extra as User,
                          )),
                  GoRoute(
                      path: Routes.contactDetails,
                      builder: (context, state) => const ContactDetailsScreen()),
                  GoRoute(
                      path: Routes.insertDetails,
                      builder: (context, state) => const InsertDetailsScreen()),
                  GoRoute(
                      path: Routes.sellerGallery,
                      builder: (context, state) => const SellerGalleryScreen()),
                  GoRoute(
                      path: Routes.subscriptions,
                      builder: (context, state) => const SubscriptionScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

