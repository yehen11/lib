/*
@Author - Anuruddha
@Date - 2025/02/11
 */

class Routes {
  Routes._();

  static const List<String> allRoutes = [
    home,
    search,
    settings,
    profile,
    inbox,
    login,
    signUp,
    reelScreen,
    verificationScreen,
    profileSettings,
    profileEdit,
    profileFriends,
    accountSettings,
    privacySettings,
    notificationSettings,
    resetpasswordScreen,
    sendVerificationCodeScreen,
    newPasswordScreen,
    otpVerificationForgotPWScreen,
    //test routes
    profileContactDetails,
    profileInsertDetails,
    profileSellerGallery,
    profileSubscriptions,

    welcomeShop,
  ];

  static const String home = '/home';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String profile = '/profileScreen';
  static const String inbox = '/inbox';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String reelScreen = '/reelScreen';
  static const String contactDetails = '/contactDetails';
  static const String insertDetails = '/insertDetails';
  static const String welcomeShop = '/welcomeShop';

  static const String categories = '/categories';

  static const String subscriptions = '/subscriptions';

  static const String sellerGallery = '/sellerGallery';
  static const String verificationScreen = '/verificationScreen';
  static const String resetpasswordScreen = '/resetpasswordScreen';
  static const String sendVerificationCodeScreen = '/sendVerificationCodeScreen';
  static const String newPasswordScreen = '/newPasswordScreen';
  static const String otpVerificationForgotPWScreen = '/otpVerificationForgotPWScreen';


  static const String profileEdit = '/profileScreen/edit';
  static const String profileFriends = '/profileScreen/friends';
  static const String profileLogin = '/profileScreen/login';
  static const String profileSignUp = '/profileScreen/signUp';
  static const String profileSettings = '/profileScreen/settings';

  static const String homeReelScreen = '/home/reelScreen';





  //test routes
  static const String profileContactDetails = '/profileScreen/contactDetails';
  static const String profileInsertDetails = '/profileScreen/insertDetails';
  static const String profileSellerGallery = '/profileScreen/sellerGallery';
  static const String profileSubscriptions = '/profileScreen/subscriptions';

  static String userProfile(String userId) => '/profile/$userId';


  static const String accountSettings = '/settings/account';
  static const String privacySettings = '/settings/privacy';
  static const String notificationSettings = '/settings/notifications';

  static const String verificationToHome = '/verificationScreen/home';

  

  static bool isValidRoute(String route) {
    return allRoutes.contains(route);
  }


}
