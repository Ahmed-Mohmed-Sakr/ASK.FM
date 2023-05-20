import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../PersonProfile/PersonProfile.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<dynamic> _people = [];

  bool _isLoading = false;

  String _errorMessage = "";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchPeople();
  }

  Future<void> _fetchPeople() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final client = BrowserClient();
    final response = await client.get(
      Uri.parse('https://askme-service.onrender.com/users/all'),
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _people = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "error in fetching users";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final filteredPeople = _people
        .where((person) =>
        person['userName'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('People'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_errorMessage != "")
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPeople.length,
                  itemBuilder: (context, index) {
                    final person = filteredPeople[index];
                    return ListTile(
                      title: Text(person['userName']),
                      onTap: () {
                        // Navigate to the person's profile page.
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PersonProfileScreen(person: person)),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}