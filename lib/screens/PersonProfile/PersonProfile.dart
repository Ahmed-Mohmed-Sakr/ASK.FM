import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../QuestionDetail/QuestionDetail.dart';

class PersonProfileScreen extends StatefulWidget {
  final dynamic person;

  PersonProfileScreen({required this.person});

  @override
  _PersonProfileScreenState createState() => _PersonProfileScreenState();
}

class _PersonProfileScreenState extends State<PersonProfileScreen> {
  List<dynamic> _questions = [];

  bool _isLoading = false;

  String _errorMessage = "";
  String _searchQuery = "";

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
/*
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final response = await http.get(
      'https://your-api-endpoint.com/questions?personId=${widget.person['id']}' as Uri,
      headers: {'Authorization': 'Bearer $userToken'},
    );

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
    }

 */
    setState(() {
      _questions =  [
        {
          'id': '1',
          'questionText': 'What is your favorite color?',
          'personId': '1',
          'answer': 'Blue',
        },
        {
          'id': '2',
          'questionText': 'What is your favorite food?',
          'personId': '1',
          'answer': 'Pizza',
        },
        {
          'id': '3',
          'questionText': 'What is your favorite movie?',
          'personId': '1',
          'answer': 'The Godfather',
        },
        {
          'id': '4',
          'questionText': 'What is your favorite book?',
          'personId': '1',
          'answer': null,
        },
        {
          'id': '5',
          'questionText': 'What is your favorite hobby?',
          'personId': '1',
          'answer': null,
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _postQuestion(String questionText) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
/*
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final response = await http.post(
      'https://your-api-endpoint.com/questions' as Uri,
      headers: {'Authorization': 'Bearer $userToken'},
      body: {
        'questionText': questionText,
        'personId': widget.person['id'],
      },
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        _questions.add(data['question']);
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
      // _questions.add(data['question']);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _questions
        .where((question) =>
        question['questionText'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person['username']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Ask a question',
                prefixIcon: Icon(Icons.question_answer),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_searchQuery.isNotEmpty) {
                      await _postQuestion(_searchQuery);
                      setState(() {
                        _searchQuery = "";
                      });
                    }
                  },
                ),
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
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    final question = filteredQuestions[index];
                    return ListTile(
                      title: Text(question['questionText']),
                      subtitle: Text(question['answer'] ?? 'Not yet answered'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  QuestionDetailScreen(
                                    questionId: question['id'],
                                    questionText: question["questionText"],
                                  )
                          ),
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