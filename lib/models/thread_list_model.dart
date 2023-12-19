import 'dart:convert';

import 'package:chat_gpt/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThreadListModel extends ChangeNotifier {
  List<ThreadModel> threads = [];

  List<ThreadModel> get data => threads;

  ThreadListModel({this.threads = const []});

  void setThreads(List<ThreadModel> threads) {
    this.threads = threads;
    notifyListeners();
  }

  void addThread(ThreadModel thread) {
    threads.insert(0, thread);
    notify();
  }

  void removeThread(ThreadModel thread) {
    threads.remove(thread);
    notify();
  }

  void notify() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'threads',
      jsonEncode(threads.map((e) => e.toJson()).toList()),
    );

    notifyListeners();
  }
}
