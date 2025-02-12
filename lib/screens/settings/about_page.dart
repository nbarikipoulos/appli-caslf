import 'dart:async';

import 'package:caslf/services/application_service.dart';
import 'package:caslf/services/messaging/fcm_init_service.dart';
import 'package:caslf/widgets/advanced/advanced_mode.dart';
import 'package:caslf/widgets/heading_item.dart';
import 'package:caslf/widgets/localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart'
  show AuthorizationStatus;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<void>? _future;

  String? appName;
  String? version;
  String? buildNumber;

  String? fcmToken;
  AuthorizationStatus? authStatus;

  late bool _showExtra; // aka display on user's action
  late int count;
  Timer? _timer;

  final bool isWeb = ApplicationService().isWebApp;

  @override
  void initState() {
    super.initState();
    _future = _init();
    _showExtra = ApplicationService().isAdvancedMode;
    count = 0;
  }

  @override
  Widget build(BuildContext context) {
    bool isAdvancedMode = context.select<ApplicationService, bool>(
      (service) => service.isAdvancedMode
    );

    List<Widget> f(String left, String right) => [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left),
          Text(right)
        ]
      ),
      const Divider()
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(context)!.screen_about_title
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _future,
          builder: (context, AsyncSnapshot snapshot) => SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: snapshot.connectionState != ConnectionState.done
            ? const CircularProgressIndicator()
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: HeadingItem(
                    title: appName!.toUpperCase(),
                    //style: Theme.of(context).textTheme.headlineSmall
                  ),
                ),
                const SizedBox(height: 32.0),
                InkWell(
                  hoverColor: Colors.transparent,
                  mouseCursor: SystemMouseCursors.basic,
                  onTap: () {
                    if(isAdvancedMode) { // Early exit
                      return;
                    }
                    _timer ??= Timer(
                      const Duration(seconds: 30),
                      () { setState(() {
                        if (context.mounted) count = 0;});
                      }
                    );

                    setState(() {
                      count++;
                      if (count == 7) {
                        _timer?.cancel();
                        _timer = null;
                        count = 0;
                        _showExtra = !_showExtra;
                      }
                    });
                  },
                  child: Column(
                    children: f(
                      tr(context)!.screen_about_version,
                      version!
                    )
                  )
                ),
                ...[(
                  left: tr(context)!.screen_about_build,
                  right: buildNumber!
                ), (
                  left: tr(context)!.screen_about_authorization,
                  right: authStatus!.name
                )
                ].map((item) => f(item.left, item.right))
                  .expand((i) => i),
                if (isWeb) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: Text(
                          overflow: TextOverflow.clip,
                            tr(context)!.screen_about_fcm_token
                        ),
                      ),
                      Flexible(
                        child: Text(
                          fcmToken ?? '---',
                          overflow: TextOverflow.clip
                        ),
                      )
                    ]
                  ),
                  const Divider()
                ],
                if (isAdvancedMode || _showExtra) ...[
                  const SizedBox(height: 16.0),
                  Center(
                    child: HeadingItem(
                      title: tr(context)!.screen_about_advanced_mode
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const AdvancedMode()
                ]
              ],
            ),
          )
        ),
      )
    );
  }

  Future<void> _init() async {
    // version/build
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    // Messaging / FCM
    FcmInitService service = FcmInitService();

    fcmToken = service.fcmToken;
    authStatus = service.getAuthorizationStatus;

  }

}