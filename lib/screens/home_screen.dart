import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koan/models/koan.dart';
import 'package:koan/services/fetch_koan_count.dart';
import 'package:koan/services/fetch_koan_service.dart';
import 'package:koan/ui/loading_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDataLoading = true;
  int? id;
  int? count;
  String title = "";
  String koan = "";

  int? newId;

  int? steak;

  List<Color> colorRange = [
    Colors.grey[400]!, // Gray
    Colors.blueGrey[300]!,
    Colors.blueGrey[500]!,
    Colors.blueGrey[700]!,
    Colors.blue[900]!,
    Colors.red[700]!,
    Colors.red[900]!, // Red
  ];

  Color getColorFromNumber(int number) {
    if (number >= 1 && number <= 7) {
      return colorRange[number - 1];
    } else {
      return Colors.grey[400]!;
    }
  }

  int randomNumber(int total) {
    return newId = Random().nextInt(total) + 1;
  }

  int fetchSteak() {
    // fetch steak from local db
    return 5;
  }

  void countKoan() async {
    KoanCountService().fetchCount().then((response) {
      if (response.apiResponse.status == true) {
        var data = response.data;
        data?.forEach((element) {
          count = element.count;
        });

        print(count);

        loadKoan(randomNumber(count!) - 1);

        setState(() {
          isDataLoading = true;
        });
      } else {
        // setState(() {});
      }
    });
  }

  void loadKoan(int id) async {
    print("id: ${id}");
    if (id == 0) {
      countKoan();
    }
    KoanService(koanPost: KoanPost(id: id.toString()))
        .fetchKoan()
        .then((response) {
      if (response.apiResponse.status == true) {
        var data = response.data;
        data?.forEach((element) {
          id = element.id;
          title = element.title;
          koan = element.koan;
        });

        print(title);

        setState(() {
          isDataLoading = false;
        });
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _refreshData() async {
    // You can add any data fetching logic here that you want to run when refreshing.
    countKoan();
  }

  @override
  void initState() {
    super.initState();
    countKoan();
    steak = fetchSteak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Koan'),
        actions: <Widget>[
          if (steak! >= 8)
            Container()
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message:
                    'The button changes colors everyday. What color is the button on the eight day?',
                child: IconButton(
                  onPressed: () {
                    // print("steak: ${steak}");
                  },
                  icon: Icon(
                    Icons.whatshot,
                    color: getColorFromNumber(steak!),
                  ),
                ),
              ),
            ),
          Tooltip(
            message:
                'The button has a dark mode and a light mode, yet it doesn\'t switch modes. The app has no mode, yet it switches modes.\nWhich mode is the true mode?',
            child: IconButton(
              icon: const Icon(
                Icons.dark_mode,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isDataLoading
                    ? const LoadingDialog(loadingText: "Loading...")
                    : Card(
                        // elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: ListTile(
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),

                              // Content Section
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  koan,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                // Add any additional widgets here
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
