import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../assistantMethods/assistant_methods.dart';
import '../models/sellers.dart';
import '../widgets/my_drawer.dart';
import '../widgets/progress_bar.dart';
import '../widgets/sellers_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// This is list of images that
  /// We see in the CarouselSlider in the home screen ...
  final items = [
    "slider/0.jpg",
    "slider/1.jpg",
    "slider/2.jpg",
    "slider/3.jpg",
    "slider/4.jpg",
    "slider/5.jpg",
    "slider/6.jpg",
    "slider/7.jpg",
    "slider/8.jpg",
    "slider/9.jpg",
    "slider/10.jpg",
    "slider/11.jpg",
    "slider/12.jpg",
    "slider/13.jpg",
    "slider/14.jpg",
    "slider/15.jpg",
    "slider/16.jpg",
    "slider/17.jpg",
    "slider/18.jpg",
    "slider/19.jpg",
    "slider/20.jpg",
    "slider/21.jpg",
    "slider/22.jpg",
    "slider/23.jpg",
    "slider/24.jpg",
    "slider/25.jpg",
    "slider/26.jpg",
    "slider/27.jpg",
  ];

  @override
  void initState() {
    super.initState();
    //The method that clears the cart...
    clearCartNow(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.cyan,
              Colors.amber,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text(
          "iFood",
          style: TextStyle(fontSize: 45, fontFamily: "Signatra"),
        ),
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      //A ScrollView that creates custom scroll effects using slivers.
      body: CustomScrollView(
        slivers: <Widget>[
          //A sliver that contains a single box widget.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width,
                // One of the slider's style ...
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * .3,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 2),
                    autoPlayAnimationDuration: const Duration(
                        milliseconds:
                            500), // After this time your slider will be slide to next.
                    autoPlayCurve: Curves.decelerate,
                    enlargeCenterPage: true,
                    scrollDirection:
                        Axis.horizontal, // where to slide the slider...
                  ),
                  items: items.map(
                    (index) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                index,
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),

          /// StreamBuilder is a widget that builds itself
          /// based on the latest snapshot of interaction with a stream.
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("sellers").snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                      ),
                    )
                  : SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 1,
                      staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                      itemBuilder: (context, index) {
                        Sellers sModel = Sellers.fromJson(
                          snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>,
                        );
                        //design for display sellers-cafes-restuarents
                        return SellersDesignWidget(
                          model: sModel,
                          context: context,
                        );
                      },
                      itemCount: snapshot.data!.docs.length,
                    );
            },
          ),
        ],
      ),
    );
  }
}
