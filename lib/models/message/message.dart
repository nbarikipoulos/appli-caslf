import 'package:caslf/models/message/message_status.dart';

class Message {
  final String uid;
  final String channelId;
  final String title;
  final String body;
  MessageStatus status;

  Message._({
    required this.uid,
    required this.channelId,
    required this.title,
    required this.body,
    required this.status
  });

  factory Message.create({
    required String uid,
    required String channelId,
    required String title,
    required String body
  }) => Message._(
    uid: uid,
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
    uid: uid,
    channelId: channelId ?? this.channelId,
    title: title ?? this.title,
    body: body ?? this.body,
  );

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'channel_id': channelId,
    'title': title,
    'body': body,
    'status': status.name
  };

}