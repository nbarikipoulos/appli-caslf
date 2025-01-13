import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/channel_type.dart';

class Channel {
  late final String id;
  final ChannelType type;
  final Location? location;
  final String? prefix;

  Channel({
    required this.type,
    this.location,
    this.prefix
  }) : id = computeId(type: type, location: location, prefix: prefix);

  static String computeId({
    required ChannelType type,
    Location? location,
    String? prefix
  }) => [
    prefix,
    location?.name,
    type.channelId
  ].where((v) => v != null)
   .join('_')
  ;

}