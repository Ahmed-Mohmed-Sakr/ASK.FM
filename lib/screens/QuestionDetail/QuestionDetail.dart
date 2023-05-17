import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class QuestionDetailScreen extends StatefulWidget {
  final String questionId;

  QuestionDetailScreen({required this.questionId});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  Map<String, dynamic> _question = {};
  List<dynamic> _answers = [];

  bool _isLoading = false;

  String _errorMessage = "";

  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestion() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
/*
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final response = await http.get(
      'https://your-api-endpoint.com/questions/${widget.questionId}' as Uri,
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);*/
      setState(() {
        //_question = data['question'];
        //_answers = data['answers'];
        _question = {
          "id": "1",
          "text": "What is your favorite color?",
          "askedBy": {
            "username": "Alice",
            "avatarUrl": "https://example.com/avatar.png"
          },
          "answeredBy": {
            "username": "Bob",
            "avatarUrl": "https://example.com/avatar.png"
          },
          "answers": [
            {
              "text": "My favorite color is blue.",
              "user": {
                "username": "Charlie",
                "avatarUrl": "https://example.com/avatar.png"
              }
            },
            {
              "text": "I like green.",
              "user": {
                "username": "Dave",
                "avatarUrl": "https://example.com/avatar.png"
              }
            }
          ]
        };
        _answers = [
          {
            "text": "My favorite color is blue.",
            "user": {
              "username": "Charlie",
              "avatarUrl": "https://example.com/avatar.png"
            }
          },
          {
            "text": "I like green.",
            "user": {
              "username": "Dave",
              "avatarUrl": "https://example.com/avatar.png"
            }
          }
        ];
        _isLoading = false;
      });
      /*
    } else {
      final data = json.decode(response.body);
      setState(() {
        _isLoading = false;
        _errorMessage = data['message'];
      });
    }*/
  }

  Future<void> _submitAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    /*final response = await http.post(
      'https://your-api-endpoint.com/questions/${widget.questionId}/answer' as Uri,
      headers: {'Authorization': 'Bearer $userToken'},
      body: {'text': _answerController.text},
    );

    if (response.statusCode == 200) {*/
      _answerController.clear();
      await _fetchQuestion();
    /*} else {
      final data = json.decode(response.body);
      setState(() {
        _errorMessage = data['message'];
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_isLoading) CircularProgressIndicator(),
            if (_errorMessage != "")
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            Text(
              _question != {} ? _question['text'] : '',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Asked By: ${_question != {} ? _question['askedBy']['username'] : ''}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            if (_answers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answers:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  for (var answer in _answers)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            answer['text'],
                            style: TextStyle(fontSize: 16.0),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Answered By: ${answer['user']['username']}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            SizedBox(height: 16.0),
            // if (_question != {} && _question['answeredBy'] == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Answer:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: 'Enter your answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    child: Text('Submit Answer'),
                    onPressed: _submitAnswer,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}