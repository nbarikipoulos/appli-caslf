import 'package:caslf/models/location/location.dart';
import 'package:caslf/models/message/channel.dart';
import 'package:caslf/models/message/channel_action.dart';
import 'package:caslf/models/message/channel_type.dart';
import 'package:caslf/models/message/message.dart';
import 'package:caslf/services/admin_service.dart';
import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/grant_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
import 'package:caslf/services/service.dart';
import 'package:caslf/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesService extends ChangeNotifier implements Service {
  MessagesService._();

  static MessagesService? _instance;
  factory MessagesService() => _instance ??= MessagesService._();

  bool get useAlternativeChannels => _useAlternativeChannels;
  bool get isSendOfNotificationSwitchedOff => _switchSendOfNotificationOff;

  final Map<Channel, bool?> _subscriptions = {};

  final _user = UserService().current;
  final _grantService = GrantService(adminService: AdminService());

  final _db = FirebaseFirestore.instance;
  final _fcmInitService = FcmInitService();

  final String _collectionMsgId = 'messages';
  final String _collectionChannelAuthId = 'channel_auth';

  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  final String _altChannelPrefId = 'alt_channel';
  final String _switchSendOfNotificationOffId = 'send_notif_off';

  bool _useAlternativeChannels = false;
  bool _switchSendOfNotificationOff = false;
  final _prefix = 'alt';

  Future<void> toggleChannels() async {
    await clear();

    _useAlternativeChannels = !_useAlternativeChannels;

    await _asyncPrefs.setBool(
      _altChannelPrefId,
      _useAlternativeChannels
    );

    await initSubscriptions(true);

    notifyListeners();
  }

  Future<void> toggleSwitchSendOfNotificationOff () async {
    _switchSendOfNotificationOff = !_switchSendOfNotificationOff;

    await _asyncPrefs.setBool(
      _switchSendOfNotificationOffId,
      _switchSendOfNotificationOff
    );

    notifyListeners();
  }

  Future<void> send(Message message) async {
    // Mainly to ensure that 'guest' can not send any message/notification.
    // See GrantService.
    // + advanced mode for test purposes.
    if (
      !_grantService.isAllowedToSendNotification
      || _switchSendOfNotificationOff
    ) {
      // Early Exit
      return Future.value();
    }

    Message msg = _useAlternativeChannels
      ? message.copyWith(
        channelId: '${_prefix}_${message.channelId}',
        title: '[${_prefix.toUpperCase()}] ${message.title}')
      : message
    ;

    return _db
      .collection(_collectionMsgId)
      .doc()
      .set(msg.toFirestore())
    ;
  }

  bool? getSubscribingFor(Channel channel) {
    return _subscriptions[channel];
  }

  Future<void> setSubscribingFor(
    Channel channel,
    bool value
  ) async {
    bool? old = _subscriptions[channel];

    if (value == old) { // Early exits
      return;
    }

    Function f = value
      ? _subscribeToTopic
      : _unsubscribeFromTopic
    ;

    bool ops = await f.call(channel);

    if (ops) {
      // Update map
      _subscriptions[channel] = value;
      // Update shared prefs, await to avoid toggle effect...
      await _asyncPrefs.setBool(channel.id, value);
      // Notify observers
      notifyListeners();
    }
  }

  Future<bool> _subscribeToTopic(Channel channel) async {
    bool result = true;

    if (!kIsWeb) {
      FirebaseMessaging.instance
        .subscribeToTopic(channel.id)
        .catchError((err) { result = false; })
      ;
    } else {
      try {
        _webUpdateTopic(
            channel: channel,
            action: ChannelAction.subscribe,
            fcmToken: _fcmInitService.fcmToken!
        ).catchError((err) { result = false; });
      } on Error catch (_) { result = false; }
    }

    return Future.value(result);
  }

  Future<bool> _unsubscribeFromTopic(Channel channel) {
    bool result = true;

    if (!kIsWeb) {
      FirebaseMessaging.instance
        .unsubscribeFromTopic(channel.id)
        .catchError((err) { result = false; })
      ;
    } else {
      try {
        _webUpdateTopic(
          channel: channel,
          action: ChannelAction.unsubscribe,
          fcmToken: _fcmInitService.fcmToken!
        ).catchError((err) { result = false; });
      } on Error catch (_) { result = false; }
    }

    return Future.value(result);
  }

  Future<void> _webUpdateTopic({
    required Channel channel,
    required ChannelAction action,
    required String fcmToken
  }) async {
    // Get uid/channel document, if any
    QueryDocumentSnapshot? query;
    try {
      query = await _db
        .collection(_collectionChannelAuthId)
        .where('uid', isEqualTo: _user.uid)
        .where('channel_id', isEqualTo: channel.id)
        .limit(1)
        .get()
        .then((doc) => doc.docs.first)
      ;
    } on StateError catch (_) { query = null; }

    return query != null
      ? _db // Update document
          .collection(_collectionChannelAuthId)
          .doc(query.id)
          .update({
            'fcm': fcmToken,
            'action': action.name,
            'status': 'todo'
          })
      : _db // Create a new document
          .collection(_collectionChannelAuthId)
          .doc()
          .set({
            'uid': _user.uid,
            'fcm': fcmToken,
            'channel_id': channel.id,
            'action': action.name,
            'status': 'todo'
          })
    ;
  }

  List<Channel> getAllowedChannels() {
    if (_subscriptions.keys.isNotEmpty) { // Early exit
      return _subscriptions.keys.toList();
    }

    GrantService grantService = GrantService(adminService: AdminService());

    var result = <Channel>[];

    //
    // Should we use alternative channels?
    //
    String? channelPrefix = _useAlternativeChannels
      ? _prefix : null
    ;

    //
    // Channels for locations
    //

    for (var loc in Location.values) {
      result.addAll([
        Channel(
          type: ChannelType.newSlot,
          location: loc,
          prefix: channelPrefix
        ),
        Channel(
          type: ChannelType.openClose,
          location: loc,
          prefix: channelPrefix
        )
      ]);

      if (grantService.hasAccessTo(loc)) {
        result.add(
          Channel(
            type: ChannelType.askFor,
            location: loc,
            prefix: channelPrefix
          )
        );
      }
    }

    //
    // Channel for news
    //

    result.add(Channel(
      type: ChannelType.news,
      prefix: channelPrefix
    ));

    return result;
  }

  Future<void> initSubscriptions(bool shouldInitializeValue) async {
    _useAlternativeChannels = await _asyncPrefs.getBool(_altChannelPrefId)
      ?? false //aka default
    ;

    // Get Channels
    var channels = getAllowedChannels();

    bool canReallyInit = shouldInitializeValue
      && _fcmInitService.isNotificationGranted
    ;

    for (var channel in channels) {
      bool subscribe = await _asyncPrefs.getBool(channel.id) ?? true;

      if (canReallyInit) { // Aka initial seed
        // Enforce subscription at t0
        setSubscribingFor(channel, subscribe);
      }
    }
  }

  @override
  Future init() async {
    // Executed next to login.
    // Then, let's check if we are not inside the web/ios combo
    // and grants for notifications has not been previously rejected by user.

    bool canInitChannel =
      !ApplicationService().isWeb // Delayed
      || _fcmInitService.isNotificationGranted
    ;

    // Let's perform (pseudo)init of channels.
    // Do not await for result, not needed.
    initSubscriptions(canInitChannel);

    // AdvancedMode/switchNotificationSendOff
    _switchSendOfNotificationOff = await _asyncPrefs.getBool(
      _switchSendOfNotificationOffId
    ) ?? false; //aka default
  }

  @override
  Future clear() async {
    // Shut notifications at logout down....
    // Get Channels
    var channels = _subscriptions.keys.toList(); // getAllowedChannels();

    for (var channel in channels) {
      // should exist in map...
      bool subscribed = _subscriptions[channel]!;
      if (subscribed) {
        _unsubscribeFromTopic(channel);
      }
    }

    // Clean-up map
    _subscriptions.clear();
  }
}
