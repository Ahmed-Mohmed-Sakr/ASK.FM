import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/browser_client.dart';
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
  String _userNmae = "";

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
    _userNmae = prefs.getString('userName')!;
    // await prefs.getString('id');

    // final response = await http.get('https://your-api-endpoint.com/questions' as Uri,
    //     headers: {'Authorization': 'Bearer $userToken'});

    final client = BrowserClient();
    final response = await client.get(
      Uri.parse('https://askme-service.onrender.com/auth/authenticate'),
        headers: {'Authorization': 'Bearer $userToken'}
    );

    print("----------------------------------");
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _questions = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "error in fetching data try to login again :(";
      });
    }

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
            Text(
              'Welcome, ${_userNmae}!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.0),
            SizedBox(height: 16.0),
            if (_isLoading)
              CircularProgressIndicator()
            else
              if (_errorMessage != "")
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
                        title: Text(question['questionText']),
                        subtitle: Text('Answered By: Anonymous'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    QuestionDetailScreen(
                                        questionId: question['id'],
                                        questionText: question['questionText'],
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4.0),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  // Navigate to the home page (this page).
                },
              ),
              IconButton(
                icon: Icon(Icons.people),
                onPressed: () {
                  Navigator.pushNamed(context, '/people');
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/AskQuestion')
                .then((value) {
              if (value == true) {
                _fetchQuestions();
              }
            });
          },
        ),
      ),
      // Add padding directly to the Scaffold widget
    );
  }
}