import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  final String questionText;
  String answerText;

  QuestionDetailScreen({required this.questionId,required this.questionText, required this.answerText});

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {

  bool _isLoading = false;

  String _errorMessage = "";

  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('userToken');

    final client = BrowserClient();
    final response = await client.post(
        Uri.parse('https://askme-service.onrender.com/answers'),
        headers: {'Authorization': 'Bearer $userToken'},
      body: json.encode({'questionId': widget.questionId, 'answerText': _answerController.text}),
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      _answerController.clear();
      final responseData = json.decode(response.body);
      setState(() {
        widget.answerText = responseData['answerText'];
      });
    } else {
      setState(() {
        _errorMessage = "error in sending data";
      });
    }
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
              widget.questionText,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Asked By: Anonymous',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            if (widget.answerText != "")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer:',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
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
                          widget.answerText,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '❤ ^_- ❤',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            if (widget.answerText == "")
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
