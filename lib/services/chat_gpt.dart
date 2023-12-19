import 'dart:convert';

import 'package:chat_gpt/models/message_list_model.dart';
import 'package:chat_gpt/models/message_model.dart';
import "package:http/http.dart";

Future<MessageModel> chat(MessageListModel messages) async {
  var url = Uri.https('api.openai.com', '/v1/chat/completions');

  final body = json.encode({
    "model": "gpt-3.5-turbo",
    "messages": messages.data
        .where((element) => element.type != MessageType.typing)
        .map((m) => ({
              "role": m.type.value,
              "content": m.message,
            }))
        .toList()
        .reversed
        .toList(),
  });

  var response = await post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer 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",
    },
    body: body,
  );

  if (response.statusCode == 200) {
    return MessageModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes))["choices"][0]["message"]);
  } else {
    throw (json.decode(response.body));
  }
}
