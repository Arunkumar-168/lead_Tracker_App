import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/auth/Widgets/Auth_Page/Login_SignUp_Pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['user'] != null) {
      user = args['user'] as User?;
    } else {
      user = FirebaseAuth.instance.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.purple,
          elevation: 0,
          title: Text(
            'Profile Page',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'User ID:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      user?.uid ?? '',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    'Name:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(width: 10),
                  Text(
                    user?.displayName ?? '',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    'Email:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              GestureDetector(
                onTap: () async {
                  popupBox(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.purple),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

void popupBox(BuildContext context) async {
  final logout = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to logout from this App?'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );

  if (logout == true) {
    Get.offAll(() => const LoginPage());
  }
}
