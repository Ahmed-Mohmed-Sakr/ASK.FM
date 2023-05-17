import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../QuestionDetail/QuestionDetail.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _questions = [];

  bool _isLoading = false;

  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');
/*
    final response = await http.get('https://your-api-endpoint.com/questions' as Uri,
        headers: {'Authorization': 'Bearer $userToken'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data['questions'];
        _isLoading = false;
      });
    } else {
      final data = json.decode(response.body);
      setState(() {
        _isLoading = false;
        _errorMessage = data['message'];
      });
    }*/

    setState(() {
      _questions = [
        {
          'id': '1',
          'text': 'What is your favorite color?',
          'askedBy': {
            'username': 'Alice',
            'avatarUrl': 'https://example.com/avatar.png'
          },
          'answeredBy': {
            'username': 'Bob',
            'avatarUrl': 'https://example.com/avatar.png'
          },
          'answers': [
            {
              'text': 'My favorite color is blue.',
              'user': {
                'username': 'Charlie',
                'avatarUrl': 'https://example.com/avatar.png'
              }
            },
            {
              'text': 'I like green.',
              'user': {
                'username': 'Dave',
                'avatarUrl': 'https://example.com/avatar.png'
              }
            }
          ]
        },
        {
          'id': '2',
          'text': 'What is the capital of France?',
          'askedBy': {
            'username': 'Eve',
            'avatarUrl': 'https://example.com/avatar.png'
          },
          'answeredBy': null,
          'answers': []
        },
        {
          'id': '3',
          'text': 'What is the meaning of life?',
          'askedBy': {
            'username': 'Frank',
            'avatarUrl': 'https://example.com/avatar.png'
          },
          'answeredBy': {
            'username': 'Grace',
            'avatarUrl': 'https://example.com/avatar.png'
          },
          'answers': [
            {
              'text': 'The meaning of life is to be happy.',
              'user': {
                'username': 'Henry',
                'avatarUrl': 'https://example.com/avatar.png'
              }
            }
          ]
        }
      ];
      _isLoading = false;
    });

  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASK.FM'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/Profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/Settings');
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('Ask a Question'),
              onPressed: () {
                Navigator.pushNamed(context, '/AskQuestion')
                .then((value) {
                  if (value == true) {
                    _fetchQuestions();
                  }
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
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return ListTile(
                      title: Text(question['text']),
                      subtitle: Text(
                          'Asked By: ${question['askedBy']['username']}, Answered By: ${question['answeredBy'] != null ? question['answeredBy']['username'] : 'None'}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuestionDetailScreen(
                                  questionId: question['id'])),
                        )
                        .then((value) {
                          if (value == true) {
                            _fetchQuestions();
                          }
                        });
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
