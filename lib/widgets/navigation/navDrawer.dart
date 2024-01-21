import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

import '../../Utils/settings.dart';
import '../../views/login.dart';
import '../../views/menu/menu_view.dart';

class NavDrawer extends StatefulWidget {
  // String profileImg = '';

  @override
  _NavDrawerScreen createState() => _NavDrawerScreen();
}

class _NavDrawerScreen extends State<NavDrawer> {
  final logger = Logger(printer: PrettyPrinter(), filter: null);

  String _token = "";
  bool _signed = true;
  late Fluttertoast flutterToast;

  logOut() async {
    await Settings.setUserID("");
    await Settings.setEmail("");
    await Settings.setContactNumber("");
    await Settings.setPassengerCode("");
    await Settings.setToken("");
    await Settings.setUserProfilePic("");
    await Settings.setSigned(false);

    setState(() {});

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return const Drawer(
      /* child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Color.fromRGBO(249, 168, 38, 1),
                  child: Image.asset(
                    'assets/images/user_dashboard/group_197.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: width * 0.02, bottom: width * 0.02),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Profile()));
                      },
                      child: CircleAvatar(
                        radius: width * 0.1,
                        // backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                        backgroundImage: AssetImage('assets/icons/menu/user.png'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Ride'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       Icon(
          //         Icons.fastfood_rounded,
          //         color: UserDashBoardStyles.fontColor,
          //       ),
          //       SizedBox(
          //         width: 10.0,
          //       ),
          //       const Text('Foods'),
          //     ],
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.featured_play_list_rounded,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Packages'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       Icon(
          //         Icons.lightbulb,
          //         color: UserDashBoardStyles.fontColor,
          //       ),
          //       SizedBox(
          //         width: 10.0,
          //       ),
          //       const Text('Your Tips'),
          //     ],
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Wallet'),
              ],
            ),
            onTap: () {
              logger.i('Wallet');
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
              //Navigator.pop(context);
            },
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       Icon(
          //         Icons.settings_rounded,
          //         color: UserDashBoardStyles.fontColor,
          //       ),
          //       SizedBox(
          //         width: 10.0,
          //       ),
          //       const Text('Settings'),
          //     ],
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.airport_shuttle_rounded,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Drive with TaxiMe'),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Settings'),
              ],
            ),
            onTap: () async {
              SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
              sharedPrefs.setString("deleteAccount", 'yes');

              var dialog = CustomAlertDialog(
                  title: "Delete Account",
                  message: "Do you want delete account ?",
                  onNegativePressed: () {},
                  negativeBtnText: 'No',
                  onPostivePressed: () {
                    Navigator.pop(context);
                  },
                  positiveBtnText: 'Yes');
              showDialog(context: context, builder: (BuildContext context) => dialog);
              Future.delayed(Duration(seconds: 3), () {});
              // _showToast("Successfully Delete Your Account");
            },
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       Icon(
          //         Icons.note_rounded,
          //         color: UserDashBoardStyles.fontColor,
          //       ),
          //       SizedBox(
          //         width: 10.0,
          //       ),
          //       const Text('Legal'),
          //     ],
          //   ),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            title: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: UserDashBoardStyles.fontColor,
                  size: 32,
                ),
                SizedBox(
                  width: 10.0,
                ),
                const Text('Logout'),
              ],
            ),
            onTap: () {
              logOut();
            },
          ),
        ],
      ),*/
      child: Menu(),
    );
  }

  _showToast(String warningMsg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.water_damage_rounded,
            color: Colors.white,
          ),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            warningMsg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, msg: warningMsg, backgroundColor: Colors.orangeAccent, textColor: Colors.white, fontSize: 16.0);
  }
}
