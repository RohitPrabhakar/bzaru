// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class SectionWebView extends StatefulWidget {
//   final String url;
//   final String className;

//   const SectionWebView({Key key, @required this.url, @required this.className})
//       : super(key: key);
//   @override
//   _SectionWebViewState createState() => _SectionWebViewState();
// }

// class _SectionWebViewState extends State<SectionWebView> {
//   InAppWebViewController webView;
//   String _url = 'https://bzaru.com';
//   bool isLoaded = false;

//   @override
//   void didUpdateWidget(SectionWebView oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget != oldWidget) {
//       isLoaded = false;
//       webView.loadUrl(
//         urlRequest: URLRequest(
//           url: Uri(path: widget.url ?? _url),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 450,
//       margin: const EdgeInsets.all(16.0),
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(color: Colors.white, boxShadow: [
//         BoxShadow(blurRadius: 11.0, spreadRadius: 1.0, color: Colors.black26)
//       ]),
//       alignment: Alignment.center,
//       child: Stack(
//         children: [
//           Offstage(
//             offstage: !isLoaded,
//             child: InAppWebView(
//               onWebViewCreated: (controller) {
//                 webView = controller;
//               },
//               onLoadStop: (InAppWebViewController controller, Uri url) {
//                 controller
//                     .evaluateJavascript(
//                         source:
//                             "document.body.innerHTML=document.getElementsByClassName"
//                             "('${widget.className}')[0].innerHTML;")
//                     .whenComplete(() {
//                   setState(() {
//                     isLoaded = true;
//                   });
//                 });
//               },
//             ),
//           ),
//           if (!isLoaded)
//             Center(
//               child: CircularProgressIndicator(),
//             )
//         ],
//       ),
//     );
//   }
// }
