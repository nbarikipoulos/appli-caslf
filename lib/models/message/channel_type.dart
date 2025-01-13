import 'package:flutter/material.dart';

enum ChannelType {
  newSlot(channelId: 'new_slot', icon: Icons.new_releases),
  openClose(channelId: 'open_close', icon: Icons.meeting_room),
  askFor(channelId: 'ask_for', icon: Icons.question_mark_sharp),
  news(channelId: 'news', icon: Icons.newspaper);

  final String channelId;
  final IconData icon;

  const ChannelType({
    required this.channelId,
    required this.icon
  });

}