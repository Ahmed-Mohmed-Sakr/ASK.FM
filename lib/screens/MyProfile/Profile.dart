import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../QuestionDetail/QuestionDetail.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = "";
  int _numQuestionsAsked = 0;
  int _numQuestionsAnswered = 0;
  List<dynamic> _allQuestions = [];
  List<dynamic> _questionsAnswered = [];
  List<dynamic> _questionsUnanswered = [];

  // 0: all questions, 1: answered questions, 2: unanswered questions
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    /*
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final response = await http.get(
      'https://your-api-endpoint.com/profile' as Uri,
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _username = data['username'];
        _numQuestionsAsked = data['numQuestionsAsked'];
        _numQuestionsAnswered = data['numQuestionsAnswered'];
        _allQuestions = data['questions'];
        _questionsAnswered = _allQuestions.where((question) => question['answer'] != null).toList();
        _questionsUnanswered = _allQuestions.where((question) => question['answer'] == null).toList();
      });
    }*/

    setState(() {
      _username = "Sakr";
      _numQuestionsAsked = 0;
      _numQuestionsAnswered = 0;
      _allQuestions = [
        {
          'id': '1',
          'questionText': 'What is your favorite color?',
          'answer': null,
        },
        {
          'id': '2',
          'questionText': 'What is your favorite food?',
          'answer': null,
        },
        {
          'id': '3',
          'questionText': 'What is your favorite movie?',
          'answer': 'The Godfather',
        },
        {
          'id': '4',
          'questionText': 'What is your favorite book?',
          'answer': 'To Kill a Mockingbird',
        },
        {
          'id': '5',
          'questionText': 'What is your favorite hobby?',
          'answer': 'Playing guitar',
        },
      ];
      _questionsAnswered = _allQuestions.where((question) => question['answer'] != null).toList();
      _questionsUnanswered = _allQuestions.where((question) => question['answer'] == null).toList();
    });
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
            SizedBox(height: 16.0),
            ToggleButtons(
              children: <Widget>[
                Icon(Icons.all_inclusive),
                Icon(Icons.check),
                Icon(Icons.clear),
              ],
              isSelected: _getFilterSelections(),
              onPressed: _handleFilterButtonPress,
            ),
            SizedBox(height: 16.0),
            if (_getQuestionsToShow().isNotEmpty)
              Column(
                children: [
                  Text(_getQuestionsTitle()),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _getQuestionsToShow().length,
                    itemBuilder: (context, index) {
                      final question = _getQuestionsToShow()[index];
                      return ListTile(
                        title: Text(question['questionText']),
                        subtitle: Text(question['answer'] ?? 'Not yet answered'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    QuestionDetailScreen(
                                        questionId: question['id'])),
                          )
                              .then((value) {
                            if (value == true) {
                              _fetchProfile();
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<bool> _getFilterSelections() {
    return List.generate(3, (index) => index == _filterIndex);
  }

  void _handleFilterButtonPress(int index) {
    setState(() {
      _filterIndex = index;
    });
  }

  List<dynamic> _getQuestionsToShow() {
    switch (_filterIndex) {
      case 1:
        return _questionsAnswered;
      case 2:
        return _questionsUnanswered;
      default:
        return _allQuestions;
    }
  }

  String _getQuestionsTitle() {
    switch (_filterIndex) {
      case 1:
        return 'Answered Questions:';
      case 2:
        return 'Unanswered Questions:';
      default:
        return 'All Questions:';
    }
  }
}