import 'dart:convert';

import 'package:chat_gpt/models/message_model.dart';
import 'package:chat_gpt/models/thread_list_model.dart';
import 'package:chat_gpt/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MessageListModel extends ChangeNotifier {
  late String? id;
  List<MessageModel> messages;

  List<MessageModel> get data => messages;

  MessageListModel({this.messages = const [], this.id}) {
    id ??= const Uuid().v4();
  }

  void setMessages(MessageListModel messagesListModel) {
    id = messagesListModel.id;
    messages = messagesListModel.messages;

    notify();
  }

  void addMessage(MessageModel message, ThreadListModel threads) async {
    messages.insert(0, message);

    if (messages.length == 1) {
      threads.addThread(
        ThreadModel(
          title: message.message,
          id: id!,
        ),
      );
    }

    notify();
  }

  void removeTypingMessage() {
    messages.removeWhere((element) => element.type == MessageType.typing);
    notify();
  }

  void notify() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(id!, jsonEncode(messages.map((e) => e.toJson()).toList()));

    notifyListeners();
  }

  bool isLoading() {
    return messages.any((element) => element.type == MessageType.typing);
  }

  factory MessageListModel.fromJson(List<dynamic> messages, String id) {
    return MessageListModel(
      id: id,
      messages: messages
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}
