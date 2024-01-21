import 'package:flutter/material.dart';

import '../../models/menu_list_item.dart';
import '../../utils/menu_title.dart';
import '../../widgets/book_late_pick_date.dart';
import '../../widgets/emergency_contact.dart';
import '../../widgets/help_support.dart';
import '../my_trips.dart';
import '../news_offers.dart';
import '../profile.dart';
import '../rate_card.dart';
import '../wallet/wallet_screen.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<MenuListItem> listMenuItem = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // listMenuItem.add(createMenuItem(MenuTitle.MENU_PROFILE, "assets/icons/menu/user.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_PAYMENT, "assets/icons/menu/payment.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_BOOK_LATER, "assets/icons/menu/book_later.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_MY_TRIPS, "assets/icons/menu/my_trips.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_RATE_CARD, "assets/icons/menu/rate_card.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_NEWS_OFFERS, "assets/icons/menu/news_offers.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_EMERGENCY_CONTACTS, "assets/icons/menu/emergency_contacts.png"));
    listMenuItem.add(createMenuItem(MenuTitle.MENU_HELP_SUPPORT, "assets/icons/menu/help_support.png"));
  }

  createMenuItem(String title, String imgIcon) {
    return MenuListItem(title, imgIcon);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView(
      children: <Widget>[
        Card(
          margin: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
          elevation: 0,
          child: Container(
              decoration: BoxDecoration(borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)), boxShadow: [
                BoxShadow(color: Colors.grey.shade50, blurRadius: 1, offset: const Offset(0, 1)),
              ]),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 12, top: 8, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: const AssetImage("assets/icons/menu/user.png"),
                          width: size.width * 0.2,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Profile()));
                            },
                            child: const Text("Profile")),
                        IconButton(
                            key: const Key("CloseIcon"),
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    key: const Key("ListMenu"),
                    shrinkWrap: true,
                    primary: true,
                    itemBuilder: (context, position) {
                      return createMenuListItemWidget(position);
                    },
                    itemCount: listMenuItem.length,
                  ),
                  const SizedBox(height: 8),
                ],
              )),
        )
      ],
    );
  }

  createMenuListItemWidget(int position) {
    return GestureDetector(
      onTap: () {
/*        if (listMenuItem[position].title == MenuTitle.MENU_PROFILE) {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => Profile()));
        } else */
        if (listMenuItem[position].title == MenuTitle.MENU_PAYMENT) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WalletScreen()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_BOOK_LATER) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookLaterDatePicker()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_MY_TRIPS) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyTrips()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_RATE_CARD) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RateCard()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_EMERGENCY_CONTACTS) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmergencyContacts()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_HELP_SUPPORT) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => HelpSupport()));
        } else if (listMenuItem[position].title == MenuTitle.MENU_NEWS_OFFERS) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewsOffers()));
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 8),
            Image(
              image: AssetImage(listMenuItem[position].imgIcon),
            ),
            const SizedBox(width: 14),
            Container(margin: const EdgeInsets.only(left: 12), child: Text(listMenuItem[position].title))
          ],
        ),
      ),
    );
  }
}
