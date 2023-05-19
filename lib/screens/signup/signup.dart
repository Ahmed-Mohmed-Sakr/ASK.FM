import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/browser_client.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";
  String _password = "";

  bool _isLoading = false;

  String _errorMessage = "";

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    print(_name);
    print(_email);
    print(_password);
    final client = BrowserClient();
    final response = await client.post(
      Uri.parse('https://askme-service.onrender.com/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
          {
            'userName': _name,
            'email': _email,
            'password': _password
          }
      ),
    );
    print("----------------------------------");
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // final data = json.decode(response.body);
      setState(() {
        _isLoading = false;
        _errorMessage = "error in userName or Email is already used";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Sign Up'),
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _signup();
                  }
                },
              ),
              if (_errorMessage != "")
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}