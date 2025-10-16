import 'package:get/get.dart';
import 'package:tracker_app/features/auth/Widgets/Auth_Page/Login_SignUp_Pages.dart';
import 'package:tracker_app/features/leads/LeadList_Edit_Page.dart';
import 'package:tracker_app/features/leads/Lead_Page.dart';
import 'package:tracker_app/features/leads/Profile_Page.dart';


class RouteHelper {
  static const String loginPage = "/login_page";
  static const String leadPage = "/lead_page";
  static const String profilePage = "/profile_page";
  static const String editPage = "/edit_page";

  static String getLoginPage() => loginPage;
  static String getLeadPage() => leadPage;
  static String getProfilePage() => profilePage;
  static String getEditPage() => editPage;


  static List<GetPage> routes = [
    GetPage(name: loginPage, page: () => const LoginPage()),
    GetPage(name: leadPage, page: () =>  LeadPage()),
    GetPage(name: profilePage, page: () => const ProfilePage()),
    GetPage(
      name: editPage,
      page: () => LeadListEditPage(),
    ),
  ];
}
