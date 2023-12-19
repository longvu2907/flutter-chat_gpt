import 'package:chat_gpt/models/message_list_model.dart';
import 'package:chat_gpt/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageList extends StatelessWidget {
  final MessageListModel messages;

  const MessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      reverse: true,
      itemCount: messages.data.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index >= messages.data.length) {
          return null;
        }

        return Message(data: messages.data[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        if (index >= messages.data.length - 1 ||
            messages.data[index].timestamp.day !=
                messages.data[index + 1].timestamp.day) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                DateFormat('dd MMMM yyyy')
                    .format(messages.data[index].timestamp),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          );
        }

        return const SizedBox(height: 10);
      },
    );
  }
}
