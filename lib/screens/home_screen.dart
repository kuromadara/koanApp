import 'dart:math';

import 'package:flutter/material.dart';
import 'package:koan/models/common/koan.dart';
import 'package:koan/models/koan_get.dart';
import 'package:koan/models/streak.dart';
import 'package:koan/services/database/database_service.dart';
import 'package:koan/services/fetch_koan_count.dart';
import 'package:koan/services/fetch_koan_service.dart';
import 'package:koan/ui/loading_dialog.dart';
import 'package:koan/ui/bottom_appbar.dart';
import 'package:koan/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  int _currentIndex = 0;
  bool isDataLoading = true;
  int? id;
  int? count;
  String title = "";
  String koanDesc = "";
  DateTime now = DateTime.now();
  String localDate = "";

  int? newId;

  int? currentStreak = 0;

  late Future<Koan?> localKoan = _getKoan();
  late Future<Streak?> localStreak = _getSteak();

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

  void countKoan() async {
    KoanCountService().fetchCount().then((response) {
      if (response.apiResponse.status == true) {
        var data = response.data;
        data?.forEach((element) {
          count = element.count;
        });

        loadKoan(randomNumber(count!) - 1);

        setState(() {
          isDataLoading = true;
        });
      } else {
        // setState(() {});
      }
    });
  }

  Future<void> loadKoan(int id) async {
    if (id == 0) {
      countKoan();
    }
    currentStreak = await fetchStreak();

    print("current STreak load: $currentStreak");
    KoanService(koanPost: KoanPost(id: id.toString()))
        .fetchKoan()
        .then((response) {
      if (response.apiResponse.status == true) {
        var data = response.data;
        data?.forEach((element) {
          id = element.id!;
          title = element.title;
          koanDesc = element.koan;
        });

        if (data != null && data.isNotEmpty) {
          Koan fetchedKoan = Koan(
            serverId: data[0].id,
            title: data[0].title,
            koan: data[0].koan,
            status: data[0].status,
            date: data[0].date,
          );

          DatabaseService().insertKoan(fetchedKoan);
        }

        setState(() {
          isDataLoading = false;
        });
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _refreshData() async {
    countKoan();
  }

  Future<Koan?> _getKoan() async {
    return await _databaseService.getActiveKoan();
  }

  Future<Streak?> _getSteak() async {
    return await _databaseService.getStreak();
  }

  Future<int> fetchStreak() async {
    final steak = await localStreak;
    if (steak == null) {
      Streak storeStreak = Streak(
        count: 1,
      );
      DatabaseService().insertStreak(storeStreak);

      setState(() {
        currentStreak = 1;
      });
      return 1;
    } else {
      currentStreak = steak.count;

      // update count in database if date is not same
      String currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final dateDifference = calculateDateDifference(currentDate, localDate);
      print("Date diff: $dateDifference");
      if (dateDifference == 1) {
        print("local date working ");
        Streak updateStreak = Streak(
          id: 1,
          count: currentStreak! + 1,
        );

        // Call the insertKoan method to store the fetched Koan
        DatabaseService().updateStreak(updateStreak);
      } else if (dateDifference > 1) {
        final resetStreak = Streak(id: 1, count: 0);
        await DatabaseService().updateStreak(resetStreak);
      }
      return currentStreak!;
    }
  }

  int calculateDateDifference(String date1, String date2) {
    final DateTime dateTime1 = DateTime.parse(date1);
    final DateTime dateTime2 = DateTime.parse(date2);

    print("date 1: $date1");
    print("date 2: $date2");
    final difference = dateTime1.difference(dateTime2);
    return difference.inDays;
  }

  Future<void> getKoanFromLocal() async {
    localKoan = _getKoan();
    localKoan.then((koan) async {
      if (koan == null) {
        countKoan();
      } else {
        String currentDate =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        if (currentDate == koan.date) {
          id = koan.id!;
          title = koan.title;
          koanDesc = koan.koan;
          localDate = koan.date!;

          currentStreak = await fetchStreak();
          print("current STreak local: $currentStreak");
        } else {
          countKoan();
        }
        setState(() {
          isDataLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getKoanFromLocal();
    // currentStreak = fetchStreak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koan'),
        actions: <Widget>[
          if (currentStreak! >= 8)
            Container()
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message:
                    'The button changes colors everyday.\nWhat color is the button on the eight day?',
                child: IconButton(
                  onPressed: () {
                    // print("steak: ${steak}");
                  },
                  icon: Icon(
                    Icons.whatshot,
                    color: getColorFromNumber(currentStreak!),
                  ),
                ),
              ),
            ),
          Tooltip(
            message:
                'The button has a dark mode and a light mode,\nyet it doesn\'t switch modes.\nThe app has no mode, yet it switches modes.\nWhich mode is the true mode?',
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
                                  koanDesc,
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
      floatingActionButton: Tooltip(
        enableFeedback: currentStreak! <= 7 ? true : false,
        message: currentStreak! <= 7
            ? "You have a button to refresh the koan,\nBut you do not know when to press it.\nIs it better to press it often or seldom?\nWhat is the sound of no button pressed?"
            : "",
        child: FloatingActionButton(
          onPressed: currentStreak! >= 7 ? _refreshData : null,
          child: const Icon(Icons.refresh),
        ),
      ),
      floatingActionButtonLocation: currentStreak! >= 7
          ? FloatingActionButtonLocation.endContained
          : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Visibility(
        visible: currentStreak! >= 7,
        child: CustomBottomAppBar(
          currentIndex: 0, // Set the current index for the Home screen
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Handle navigation based on the selected index
            if (index == 1) {
              // Navigate to the SearchScreen when the "Search" item is tapped
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
            }
          },
        ),
      ),
    );
  }
}
