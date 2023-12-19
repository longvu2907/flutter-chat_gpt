enum MessageType { sender, receiver, typing }

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.sender:
        return 'user';
      case MessageType.receiver:
        return 'assistant';
      default:
        return "";
    }
  }
}

class MessageModel {
  final String message;
  final DateTime timestamp;
  final MessageType type;

  MessageModel({
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      type: json['role'] == 'user' ? MessageType.sender : MessageType.receiver,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': message,
      'timestamp': timestamp.toIso8601String(),
      'role': type.value,
    };
  }
}
