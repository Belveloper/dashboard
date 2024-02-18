import 'dart:async';
import 'dart:io';

import 'package:dashboard/common/constants.dart';
import 'package:dashboard/controllers/BLoC/internet_cubit.dart';
import 'package:dashboard/views/no_internet_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late WebViewController controller = WebViewController();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  //late StreamSubscription _sub;
  int loadingPercentage = 0;
  bool canPop = false;

  @override
  void initState() {
    super.initState();
    // initUniLinks().then((value) {
    // controller.loadRequest(initialLink ?? Uri.parse(defaultWebLink));
    // });

    //this initalize the web view controller and enables all the javascripts
    //this should be launched in the initState() method otherwise it may cause some webview issues (animation lags , responsivity bugs,...)

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (InternetCubit.get(context).isOffline) {
              return NavigationDecision.prevent;
            }
            //this will launch native app from the directed link (istead of launching just a webview) if the link is a Facebook,Instagram or Twitter Link :
            // if (request.url.contains('instagram') ||
            //     request.url.contains('facebook') ||
            //     request.url.contains('twitter')) {
            // //  _launchInAppUrl(Uri.parse(request.url));
            //   return NavigationDecision.prevent;
            // }

            //this targets the support links (email & phone )
            if (request.url.contains('mailto:')) {
              _launchURL(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else if (request.url.contains('tel:')) {
              _launchURL(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }

            // return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            setState(() {
              loadingPercentage = 0;
            });
            // initUniLinks().then((value) {
            //   controller.reload();
            // });
          },

          //  controller..loadRequest(initialLink ?? Uri.parse(defaultWebLink));
        ),
      )
      ..loadRequest(initialLink!);
    addFileSelectionListener();
    //print('web view:$initialLink');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetCubit, InternetStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await controller.reload();
            },
            backgroundColor: Colors.amber,
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                PopScope(
                  canPop: canPop,
                  onPopInvoked: (value) async {
                    if (await controller.canGoBack()) {
                      controller.goBack();
                      setState(() {
                        canPop = false;
                      });
                    } else {
                      setState(() {
                        canPop = true;
                      });
                    }
                  },
                  child: state is InternetConnectionAvailableState
                      ? _buildWebView()
                      : const NoInternetScreen(),
                ),
                if (state is InternetConnectionAvailableState &&
                    loadingPercentage < 100)
                  LinearProgressIndicator(
                    value: loadingPercentage / 100.0,
                    color: Colors.amber,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  _launchURL(url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint('error launching url :$url');
      }
    } catch (e) {
      debugPrint('error launching url :$e');
    }
  }

//method to open native app when requesting a social media link
  // _launchInAppUrl(url) async {
  //   try {
  //     if (await canLaunchUrl(url)) {
  //       await launchUrl(
  //         url,
  //         mode: LaunchMode.externalApplication,
  //       );
  //     } else {
  //       debugPrint('error launching url :$url');
  //     }
  //   } catch (e) {
  //     debugPrint('error launching url :$e');
  //   }
  // }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setOnShowFileSelector(_androidFilePicker);
    } else if (Platform.isIOS) {
      //final iosController = controller.platform as WebKitWebViewController;
    }
  }

  Future<List<String>> _androidFilePicker(
      final FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    List<String> list = [];
    if (result != null) {
      // final file = File(result.files.single.path!);
      List<File> files = result.paths.map((path) => File(path!)).toList();
      for (var fil in files) {
        list.add(fil.uri.toString());
      }
      return list;
    }
    return [];
  }

  // Future<void> initUniLinks() async {
  //   try {
  //     _sub = linkStream.listen((String? link) {
  //       if (link != null) {
  //         print('Stream : $link');
  //         setState(() {
  //           initialLink = Uri.parse(link);
  //           controller.loadRequest(initialLink!);
  //         });
  //         print('initial: $initialLink');
  //       } else {
  //         print('stream null');
  //         // controller.loadRequest(Uri.parse(defaultWebLink));
  //       }
  //     });
  //   } on PlatformException {
  //     print('Stream link failed !');
  //   }
  // }

  Widget _buildWebView() {
    if (controller.platform is AndroidWebViewController) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams
            .fromPlatformWebViewWidgetCreationParams(
          AndroidWebViewWidgetCreationParams(
            controller: controller.platform,
          ),
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(
      controller: controller,
    );
  }
}
