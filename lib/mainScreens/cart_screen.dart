import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../assistantMethods/assistant_methods.dart';
import '../assistantMethods/cart_Item_counter.dart';
import '../assistantMethods/total_amount.dart';
import '../models/items.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/cart_item_design.dart';
import '../widgets/progress_bar.dart';
import '../widgets/text_widget_header.dart';
import 'address_screen.dart';

class CartScreen extends StatefulWidget {
  final String? sellerUID;

  CartScreen({this.sellerUID});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<int>? separateItemQuantityList;
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();

    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotalAmount(0);

    separateItemQuantityList = separateItemQuantities();
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
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: () {
            clearCartNow(context);
          },
        ),
        title: const Text(
          "iFood",
          style: TextStyle(fontSize: 45, fontFamily: "Signatra"),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Stack(
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.cyan,
                ),
                onPressed: () {
                  print("clicked");
                },
              ),
              Positioned(
                child: Stack(
                  children: <Widget>[
                    const Icon(
                      Icons.brightness_1,
                      size: 20.0,
                      color: Colors.green,
                    ),
                    Positioned(
                      top: 3,
                      right: 4,
                      child: Center(
                        child: Consumer<CartItemCounter>(
                          builder: (context, counter, c) {
                            return Text(
                              counter.count.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn1",
              label: const Text(
                "Clear Cart",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.cyan,
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                clearCartNow(context);

                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => const MySplashScreen()));

                Fluttertoast.showToast(msg: "Cart has been cleared.");
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: "btn2",
              label: const Text(
                "Check Out",
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.cyan,
              icon: const Icon(Icons.navigate_next),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => AddressScreen(
                      totalAmount: totalAmount.toDouble(),
                      sellerUID: widget.sellerUID,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // Overall total amount
          SliverPersistentHeader(
            pinned: true,
            delegate: TextWidgetHeader(title: "My Cart List"),
          ),

          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: cartProvider.count == 0
                        ? Container(
                            child: Center(
                              child: Text('No items added yet!'),
                            ),
                          )
                        : Text(
                            "Total Price: " + amountProvider.tAmount.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // Display cart items with quantity number
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("items")
                .where("itemID", whereIn: separateItemIDs())
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                      ),
                    )
                  : snapshot.data!.docs.length == 0
                      ? //startBuildingCart()
                      Container()
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              Items model = Items.fromJson(
                                snapshot.data!.docs[index].data()!
                                    as Map<String, dynamic>,
                              );

                              if (index == 0) {
                                totalAmount = 0;
                                totalAmount = totalAmount +
                                    (model.price! *
                                        separateItemQuantityList![index]);
                              } else {
                                totalAmount = totalAmount +
                                    (model.price! *
                                        separateItemQuantityList![index]);
                              }

                              if (snapshot.data!.docs.length - 1 == index) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (timeStamp) {
                                    Provider.of<TotalAmount>(context,
                                            listen: false)
                                        .displayTotalAmount(
                                      totalAmount.toDouble(),
                                    );
                                  },
                                );
                              }

                              return CartItemDesign(
                                model: model,
                                context: context,
                                quanNumber: separateItemQuantityList![index],
                              );
                            },
                            childCount: snapshot.hasData
                                ? snapshot.data!.docs.length
                                : 0,
                          ),
                        );
            },
          ),
        ],
      ),
    );
  }
}
