import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
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

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final client = BrowserClient();
    final response = await client.get(
      Uri.parse('https://askme-service.onrender.com/answers/user/${widget.person['id']}'),
      headers: {'Authorization': 'Bearer $userToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data;
        _isLoading = false;
      });
    } else {
      final data = json.decode(response.body);
      setState(() {
        _isLoading = false;
        _errorMessage = "error in fetching data :(:(";
      });
    }

  }

  Future<void> _postQuestion(String questionText) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');


    final client = BrowserClient();
    final response = await client.post(
      Uri.parse('https://askme-service.onrender.com/questions'),
      headers: {'Authorization': 'Bearer $userToken'},
      body: json.encode({
        'recipientId': widget.person['id'],
        'questionText': questionText,
        'anonymity': true
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _fetchQuestions();
        _errorMessage = "DONE";
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "un expected error :( , we cant send your question";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _questions
        .where((question) =>
        question['questionText'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person['userName']),
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
                      subtitle: Text(question['answerText'] ),
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