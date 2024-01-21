import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:implicitly_animated_reorderable_list_2/implicitly_animated_reorderable_list_2.dart';
import 'package:implicitly_animated_reorderable_list_2/transitions.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

import '../views/home/pickup_user.dart';
import '../widgets/search_city/place.dart';
import '../widgets/search_city/search_model.dart';

// ignore: non_constant_identifier_names
late Place pickup_place;
late MapController mapController;
late Position _currentLocation;
// void main() {
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       systemNavigationBarColor: Colors.white,
//     ),
//   );

//   runApp(
//     MaterialApp(
//       title: 'Material Floating Search Bar Example',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light().copyWith(
//         iconTheme: const IconThemeData(
//           color: Color(0xFF4d4d4d),
//         ),
//         floatingActionButtonTheme: const FloatingActionButtonThemeData(
//           elevation: 4,
//         ),
//       ),
//       home: Directionality(
//         textDirection: TextDirection.ltr,
//         child: ChangeNotifierProvider(
//           create: (_) => SearchModel(),
//           child: const Home(),
//         ),
//       ),
//     ),
//   );
// }
class LocationPickup extends StatefulWidget {
  @override
  LocationPickupState createState() => LocationPickupState();
}

class LocationPickupState extends State<LocationPickup> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Search Bar Example',
      theme: ThemeData.light().copyWith(
        iconTheme: const IconThemeData(
          color: Color(0xFF4d4d4d),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: ChangeNotifierProvider(
          create: (_) => SearchModel(),
          child: Home(),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = FloatingSearchBarController();

  // ignore: non_constant_identifier_names
  int _index = 0;

  int get index => _index;

  set index(int value) {
    _index = min(value, 2);
    _index == 2 ? controller.hide() : controller.show();
    setState(() {});
  }

  @override
  void initState() {
    getCurrentLocation();
    // TODO: implement initState
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: Drawer(
        child: Container(
          width: 200,
        ),
      ),
      body: buildSearchBar(),
    );
  }

  Widget buildSearchBar() {
    final actions = [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.place),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ];

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Consumer<SearchModel>(
      builder: (context, model, _) => FloatingSearchBar(
        automaticallyImplyBackButton: false,
        controller: controller,
        clearQueryOnClose: true,
        hint: 'Search Pickup Location',
        iconColor: Colors.grey,
        transitionDuration: const Duration(milliseconds: 800),
        transitionCurve: Curves.easeInOutCubic,
        physics: const BouncingScrollPhysics(),
        axisAlignment: isPortrait ? 0.0 : -1.0,
        openAxisAlignment: 0.0,
        openWidth: isPortrait ? 600 : 500,
        actions: actions,
        progress: model.isLoading,
        debounceDelay: const Duration(milliseconds: 500),
        onQueryChanged: model.onQueryChanged,
        scrollPadding: EdgeInsets.zero,
        transition: CircularFloatingSearchBarTransition(),
        builder: (context, _) => buildExpandableBody(model),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        //    Stack(
        //   fit: StackFit.expand,
        //   children: [
        //     Expanded(
        //         child:    buildMap(),
        //       ),
        //
        //
        //   ],
        // ),
        // Expanded(
        //   child: IndexedStack(
        //     index: min(index, 2),
        //     children: const [
        //
        //
        //       // SomeScrollableContent(),
        //     ],
        //   ),
        // ),
        Flexible(
          child: buildMap(),
        ),

        buildPlaceCard(),

        buildBottomNavigationBar(),
      ],
    );
  }

  Widget buildExpandableBody(SearchModel model) {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: ImplicitlyAnimatedList<Place>(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        items: model.suggestions.take(6).toList(),
        areItemsTheSame: (a, b) => a == b,
        itemBuilder: (context, animation, place, i) {
          return SizeFadeTransition(
            animation: animation,
            child: buildItem(context, place),
          );
        },
        updateItemBuilder: (context, animation, place) {
          // print(place.name);
          return FadeTransition(
            opacity: animation,
            child: buildItem(context, place),
          );
        },
      ),
    );
  }

  Widget buildItem(BuildContext context, Place place) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final model = Provider.of<SearchModel>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            print(place);
            setState(() {
              mapController.move(LatLng(place.lat, place.long), 15);
              pickup_place = place;
            });
            FloatingSearchBar.of(context)!.close();
            Future.delayed(
              const Duration(milliseconds: 500),
              () => model.clear(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: model.suggestions == history ? const Icon(Icons.history, key: Key('history')) : const Icon(Icons.place, key: Key('place')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: textTheme.subtitle1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.level2Address,
                        style: textTheme.bodyText2?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // if (model.suggestions.isNotEmpty && place != model.suggestions.last)
        //   const Divider(height: 0),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (value) => index = value,
      currentIndex: index,
      elevation: 16,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      selectedFontSize: 11.5,
      unselectedFontSize: 11.5,
      unselectedItemColor: const Color(0xFF4d4d4d),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.homeVariantOutline),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.car),
          label: 'My Rides',
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.accountSettings),
          label: 'Settings',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(MdiIcons.plusCircleOutline),
        //   label: 'Contribute',
        // ),
        // BottomNavigationBarItem(
        //   icon: Icon(MdiIcons.bellOutline),
        //   label: 'Updates',
        // ),
      ],
    );
  }

  Widget buildPlaceCard() {
    return Positioned(
        left: 80.0,
        right: 80.0,
        bottom: 20.0,
        child: pickup_place != null
            ? Container(
                width: 500,
                // margin: margin,
                // padding: padding,
                child: Material(
                  type: MaterialType.canvas,
                  color: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)), side: BorderSide(color: Colors.green)),
                  elevation: 15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    child: ElevatedButton(
                      onPressed: () {
                        // print(selectedPlace.geometry.location);
                        // Navigator.of(context).push(new MaterialPageRoute(builder: (context)=>PickupUser(selectedPlace)));
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 4)),
                          backgroundColor: MaterialStateProperty.all(
                            Colors.amber,
                          ),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))))),
                      child: Column(
                        children: [
                          pickup_place == null ? Container() : Text(pickup_place.display_name ?? ""),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50.0,
                            margin: EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => PickupUser(pickup_place)));
                              },
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.all(0.0)),
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.amber,
                                  ),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)))),
                              child: Ink(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Select Location',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          // ElevatedButton(child: Text(
                          //     "Select Here",
                          //     style: CustomTextStyle.regularTextStyle
                          //         .copyWith(color: Colors.white),
                          //   ),),
                          // Text(
                          //   "Select Here",
                          //   style: CustomTextStyle.regularTextStyle
                          //       .copyWith(color: Colors.black),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container());
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);
    setState(() {
      _currentLocation = position;
    });
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: pickup_place != null
            ? LatLng(pickup_place.lat, pickup_place.long)
            : _currentLocation != null
                ? LatLng(_currentLocation.latitude, _currentLocation.longitude)
                : LatLng(6.965176, 79.922377),
        zoom: 10,
      ),
      layers: [
        TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
        pickup_place != null
            ? MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 120.0,
                    height: 120.0,
                    point: LatLng(pickup_place.lat, pickup_place.long),
                    builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              )
            : MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(7.8731, 80.7718),
                    builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              )
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class Map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildMap(),
        // buildPlaceCard(),
      ],
    );
  }

  Widget buildFabs() {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16, end: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.gps_fixed, color: Color(0xFF4d4d4d)),
            ),
            const SizedBox(height: 16),
            // FloatingActionButton(
            //   onPressed: () {},
            //   backgroundColor: Colors.blue,
            //   child: const Icon(Icons.directions),
            // ),
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(7.8731, 80.7718),
        zoom: 8.5,
      ),
      layers: [
        TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
        pickup_place != null
            ? MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 100.0,
                    height: 100.0,
                    point: LatLng(pickup_place.lat, pickup_place.long),
                    builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              )
            : MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(7.8731, 80.7718),
                    builder: (ctx) => Container(
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              )
      ],
    );
  }
}

class SomeScrollableContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingSearchBarScrollNotifier(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        itemCount: 100,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}

// class FloatingSearchAppBarExample extends StatelessWidget {
//   const FloatingSearchAppBarExample({Key key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//   }
// }
