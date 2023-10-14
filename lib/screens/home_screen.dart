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
import 'package:koan/screens/list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  int _currentIndex = 0;
  bool isDataLoading = true;
  int? id;
  int? count;
  String title = "";
  String koanDesc = "";

  int? currentStreak = 0;

  late Future<Koan?> localKoan;
  late Future<Streak?> localStreak;

  late DateTime now = DateTime.now();
  String localDate = "";

  final List<Color> colorRange = [
    Colors.grey[400]!,
    Colors.blueGrey[300]!,
    Colors.blueGrey[500]!,
    Colors.blueGrey[700]!,
    Colors.blue[900]!,
    Colors.red[700]!,
    Colors.red[900]!,
  ];

  Color getColorFromNumber(int number) {
    if (number >= 1 && number <= 7) {
      return colorRange[number - 1];
    } else {
      return Colors.grey[400]!;
    }
  }

  int randomNumber(int total) => Random().nextInt(total) + 1;

  @override
  void initState() {
    super.initState();
    localKoan = _getKoan();
    localStreak = _getStreak();
    getKoanFromLocal();
  }

  Future<void> getKoanFromLocal() async {
    localKoan = _getKoan();
    localKoan.then((koan) async {
      if (koan == null) {
        print("no koan");
        countKoan();
      } else {
        print("local koan");
        String currentDate =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        if (currentDate == koan.date) {
          id = koan.id!;
          title = koan.title;
          koanDesc = koan.koan;
          localDate = koan.date!;
          currentStreak = await fetchStreak();
        } else {
          countKoan();
        }
        setState(() {
          isDataLoading = false;
        });
      }
    });
  }

  Future<void> countKoan() async {
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
      }
    });
  }

  Future<void> loadKoan(int id) async {
    if (id == 0) {
      countKoan();
    }
    currentStreak = await fetchStreak();

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
          String currentDate =
              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

          // need a logic here
          // if (currentDate != data[0].date) {
          Koan fetchedKoan = Koan(
            serverId: data[0].id,
            title: data[0].title,
            koan: data[0].koan,
            status: data[0].status,
            date: data[0].date,
          );

          DatabaseService().insertKoan(fetchedKoan);
          // }
        }

        setState(() {
          isDataLoading = false;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    // this need work as you can see data is inserted in table.
    countKoan();
  }

  Future<Koan?> _getKoan() async {
    return await _databaseService.getActiveKoan();
  }

  Future<Streak?> _getStreak() async {
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

      String currentDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      if (localDate.isEmpty) {
        localDate = currentDate;
        print("im working");
      }
      final dateDifference = calculateDateDifference(currentDate, localDate);
      if (dateDifference == 1) {
        Streak updateStreak = Streak(
          id: 1,
          count: currentStreak! + 1,
        );
        DatabaseService().updateStreak(updateStreak);
      } else if (dateDifference > 1) {
        final resetStreak = Streak(id: 1, count: 1);
        await DatabaseService().updateStreak(resetStreak);
      }
      return currentStreak!;
    }
  }

  int calculateDateDifference(String date1, String date2) {
    final DateTime dateTime1 = DateTime.parse(date1);
    final DateTime dateTime2 = DateTime.parse(date2);
    final difference = dateTime1.difference(dateTime2);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koan'),
        actions: <Widget>[
          if (currentStreak! < 8)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message:
                    'The button changes colors everyday.\nWhat color is the button on the eighth day?',
                child: IconButton(
                  onPressed: () {
                    // Button logic here
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
              onPressed: () {
                // Button logic here
              },
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
                                    ),
                                  ),
                                ),
                              ),
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
          currentIndex: 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const KoansScreen()));
            }
          },
        ),
      ),
    );
  }
}
