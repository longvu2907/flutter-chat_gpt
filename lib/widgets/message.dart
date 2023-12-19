import 'package:chat_gpt/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final MessageModel data;

  const Message({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: data.type == MessageType.sender
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        data.type == MessageType.receiver || data.type == MessageType.typing
            ? const CircleAvatar(
                child: Text('GPT'),
              )
            : const SizedBox(width: 0),
        Container(
          constraints: const BoxConstraints(maxWidth: 250),
          margin: EdgeInsets.only(
            right: data.type == MessageType.receiver ||
                    data.type == MessageType.typing
                ? 50
                : 0,
            left: data.type == MessageType.sender ? 50 : 5,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: data.type == MessageType.receiver ||
                    data.type == MessageType.typing
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.type == MessageType.typing
                  ? const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: Center(
                          child:
                              CircularProgressIndicator(color: Colors.white)),
                    )
                  : Text(
                      data.message,
                      style: const TextStyle(color: Colors.white),
                    ),
              const SizedBox(height: 5),
              Text(
                DateFormat('HH:mm').format(data.timestamp),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
