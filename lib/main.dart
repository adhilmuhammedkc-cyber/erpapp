
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }
  runApp(const MyApp());
}

const String kHome = "https://erp.hisaaninternational.com";

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? controller;
  InAppWebViewSettings settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    incognito: false,
    supportMultipleWindows: true,
    transparentBackground: false,
    useOnDownloadStart: true,
    mediaPlaybackRequiresUserGesture: true,
    allowsBackForwardNavigationGestures: true,
    isInspectable: kDebugMode,
  );

  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              if (Platform.isAndroid) {
                await controller?.reload();
              } else if (Platform.isIOS) {
                final url = await controller?.getUrl();
                if (url != null) {
                  await controller?.loadUrl(urlRequest: URLRequest(url: url));
                }
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          if (await controller?.canGoBack() ?? false) {
            await controller?.goBack();
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Hisaan ERP'),
            actions: [
              IconButton(
                tooltip: 'Print',
                icon: const Icon(Icons.print),
                onPressed: () async {
                  await controller?.printCurrentPage();
                },
              ),
              IconButton(
                tooltip: 'Home',
                icon: const Icon(Icons.home),
                onPressed: () async {
                  await controller?.loadUrl(
                    urlRequest: URLRequest(url: WebUri(kHome)),
                  );
                },
              ),
            ],
          ),
          body: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(kHome)),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (c) => controller = c,
            onLoadStop: (c, url) async {
              pullToRefreshController?.endRefreshing();
            },
            onPrintRequest: (c, url, printJobController) async {
              await printJobController?.present();
              return true;
            },
            onCreateWindow: (c, createWindowRequest) async {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: const EdgeInsets.all(8),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: InAppWebView(
                      initialSettings: settings,
                      onWebViewCreated: (childController) async {
                        await childController.loadUrl(
                          urlRequest: URLRequest(url: createWindowRequest.request.url),
                        );
                      },
                      onPrintRequest: (cc, url, pjc) async {
                        await pjc?.present();
                        return true;
                      },
                    ),
                  ),
                ),
              );
              return true;
            },
            shouldOverrideUrlLoading: (c, navAction) async {
              final uri = navAction.request.url;
              if (uri == null) return NavigationActionPolicy.ALLOW;
              final host = uri.host;
              if (host.endsWith("hisaaninternational.com")) {
                return NavigationActionPolicy.ALLOW;
              }
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onDownloadStartRequest: (c, request) async {
              final uri = request.url;
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      ),
    );
  }
}
