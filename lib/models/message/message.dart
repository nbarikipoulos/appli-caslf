import 'package:caslf/models/message/message_status.dart';

class Message {
  final String channelId;
  final String title;
  final String body;
  MessageStatus status;

  Message._({
    required this.channelId,
    required this.title,
    required this.body,
    required this.status
  });

  factory Message.create({
    required String channelId,
    required String title,
    required String body
  }) => Message._(
    channelId: channelId,
    title: title,
    body: body,
    status: MessageStatus.toSend
  );

  Message copyWith({
    String? channelId,
    String? title,
    String? body
  }) => Message.create(
    channelId: channelId ?? this.channelId,
    title: title ?? this.title,
    body: body ?? this.body
  );

  Map<String, dynamic> toFirestore() => {
    'channel_id': channelId,
    'title': title,
    'body': body,
    'status': status.name
  };

}