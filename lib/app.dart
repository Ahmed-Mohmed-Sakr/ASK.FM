import 'package:flutter/material.dart';
import 'package:learningf/screens/AskQuestion/AskQuestion.dart';
import 'package:learningf/screens/Profile/Profile.dart';
import 'package:learningf/screens/QuestionDetail/QuestionDetail.dart';
import 'package:learningf/screens/Settings/Settings.dart';
import 'package:learningf/screens/homepage/homepage.dart';
import 'package:learningf/screens/login/login.dart';
import 'package:learningf/screens/signup/signup.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASK.FM',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => SignupScreen(),
        '/AskQuestion': (context) => AskQuestionScreen(),
        '/Settings':(context) => SettingsScreen(),
        '/Profile':(context) => ProfileScreen(),
      },
    );
  }

}