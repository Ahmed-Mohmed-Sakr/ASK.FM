import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "";
  int _numQuestionsAsked = 0;
  int _numQuestionsAnswered = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');
/*
    final response = await http.get('https://your-api-endpoint.com/profile' as Uri,
        headers: {'Authorization': 'Bearer $userToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _username = data['username'];
        _numQuestionsAsked = data['numQuestionsAsked'];
        _numQuestionsAnswered = data['numQuestionsAnswered'];
      });
    }

 */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_username != "") Text('Username: $_username'),
            if (_numQuestionsAsked != "")
              Text('Number of Questions Asked: $_numQuestionsAsked'),
            if (_numQuestionsAnswered != "")
              Text('Number of Questions Answered: $_numQuestionsAnswered'),
          ],
        ),
      ),
    );
  }
}