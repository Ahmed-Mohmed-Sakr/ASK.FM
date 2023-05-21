import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../QuestionDetail/QuestionDetail.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Add these two state variables
  bool _isLoading = false;
  String _errorMessage = "";

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

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');


    final client = BrowserClient();
    final response = await client.get(
      Uri.parse(
          'https://askme-service.onrender.com/answers/my'),
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questionsAnswered = data;
        _allQuestions.addAll(List.from(_questionsAnswered));;
        _numQuestionsAsked = _allQuestions.length;
        _numQuestionsAnswered = _questionsAnswered.length;
      });
    }else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching profile data";
      });
    }
    final client2 = BrowserClient();
    final response2 = await client2.get(
      Uri.parse(
          'https://askme-service.onrender.com/questions/unanswered'),
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response2.statusCode == 200) {
      final data = json.decode(response2.body);
      setState(() {
        _questionsUnanswered = data;
        _questionsUnanswered = _questionsUnanswered.map((question) {
          Map<String, dynamic> modifiedQuestion = Map.from(question);
          modifiedQuestion["answerText"] = "";
          return modifiedQuestion;
        }).toList();
        _allQuestions.addAll(List.from(_questionsUnanswered));
        _numQuestionsAsked = _allQuestions.length;
        _isLoading = false;
      });
    }else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching profile data";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('My Profile'),
            pinned: true,
            flexibleSpace: Container(
              // color: Colors.grey[200],
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text('Username: $_username', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.teal),
                          SizedBox(width: 4.0),
                          Text('$_numQuestionsAnswered'),
                        ],
                      ),
                      SizedBox(width: 16.0),
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.grey),
                          SizedBox(width: 4.0),
                          Text('${_numQuestionsAsked - _numQuestionsAnswered}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: ToggleButtons(
                children: <Widget>[
                  Icon(Icons.all_inclusive),
                  Icon(Icons.check),
                  Icon(Icons.clear),
                ],
                isSelected: _getFilterSelections(),
                onPressed: _handleFilterButtonPress,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (_getQuestionsToShow().isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 16.0),
                    Text(_getQuestionsTitle()),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _getQuestionsToShow().length,
                      itemBuilder: (context, index) {
                        final question = _getQuestionsToShow()[index];
                        return ListTile(
                          title: Text(question['questionText']),
                          subtitle: Text(question['answerText'] == "" ? 'Not yet answered' : question['answerText']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      QuestionDetailScreen(
                                        questionId: question['id'].toString(),
                                        questionText: question["questionText"],
                                          answerText: question['answerText']
                                      )
                              ),
                            )
                                .then((value) {
                              // if (value == true) {
                                _fetchProfile();
                              // }
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              if (_isLoading) Center(child: CircularProgressIndicator()),
              if (_errorMessage != "")
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ]),
          ),
        ],
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