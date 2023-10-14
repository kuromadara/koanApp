import 'package:flutter/material.dart';
import 'package:koan/models/common/koan.dart';
import 'package:koan/screens/home_screen.dart';
import 'package:koan/services/database/database_service.dart';
import 'package:koan/ui/bottom_appbar.dart';

class KoansScreen extends StatefulWidget {
  const KoansScreen({Key? key}) : super(key: key);

  @override
  State<KoansScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<KoansScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<Koan>?> _koans;

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _koans = _getKoans();
  }

  Future<List<Koan>?> _getKoans() async {
    return await _databaseService.getAllKoans();
  }

  void _showKoanDetails(Koan koan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(koan.title),
          content: Text(
              koan.koan), // Assuming 'koan' is a property in your Koan model.
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koans'),
      ),
      body: FutureBuilder<List<Koan>?>(
        future: _koans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Koans available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final koan = snapshot.data![index];
                return ListTile(
                  title: Text(koan.title),
                  onTap: () {
                    _showKoanDetails(koan);
                  },
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: 1,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pop(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        },
      ),
    );
  }
}
