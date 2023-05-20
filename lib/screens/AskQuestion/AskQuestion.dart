import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AskQuestionScreen extends StatefulWidget {
  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _question = "";
  int userID = 0;
  bool _isLoading = false;

  String _errorMessage = "";

  Future<void> _askQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final userToken = prefs.getString('userToken');
      final userEmail = prefs.getString("userEmail");

      final client = BrowserClient();
      final response = await client.get(
        Uri.parse(
            'https://askme-service.onrender.com/users/email?email=${userEmail}'),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        userID = data['id'];

        // send qution now
        final client2 = BrowserClient();
        final response2 = await client2.post(
          Uri.parse('https://askme-service.onrender.com/questions'),
          headers: {'Authorization': 'Bearer $userToken'},
          body: json.encode({
            'recipientId': userID,
            'questionText': _question,
            'anonymity': true
          }),
        );
        if (response.statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "error in fetching user data";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "error in fetching user data";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask a Question'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_isLoading) CircularProgressIndicator(),
              if (_errorMessage != "")
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Question'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your question';
                  }
                  return null;
                },
                onChanged: (value) {
                  _question = value;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Ask Question'),
                onPressed: _isLoading ? null : _askQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}