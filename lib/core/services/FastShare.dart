// import 'package:url_launcher/url_launcher.dart';
// import 'package:share_plus/share_plus.dart';
// import 'dart:io' show Platform; // Import Platform to check OS
// import 'package:flutter/foundation.dart' show kIsWeb;

// enum SharePlatform {
//   facebookPost,
//   facebookMessenger,
//   instagram,
//   instagramDirect, // Instagram Direct
//   twitter,
//   snapchat,
//   whatsapp,
//   normalShare, // Added Normal Share
// }

// class FastShare {
//   static Future<void> share({
//     String? text, // Optional text
//     String? link, // Optional link
//     Uri? uri, // Optional URI for normal share
//     required SharePlatform platform,
//   }) async {
//     // Ensure there's something to share
//     if (platform != SharePlatform.normalShare && text == null && link == null) {
//       throw ArgumentError("Either text or link must be provided.");
//     }

//     // If normal share is selected, use the URI directly
//     if (platform == SharePlatform.normalShare && uri != null) {
//       await Share.shareUri(uri);
//       return;
//     }

//     // Construct the full content for other platforms
//     String content = _buildContent(text, link);

//     Uri? platformUri;
//     if (kIsWeb) {
//       // For web platform, use web URLs
//       platformUri = _getPlatformUriForWeb(content, platform);
//     } else if (Platform.isIOS) {
//       platformUri = _getPlatformUriForIOS(content, platform);
//     } else {
//       platformUri = _getPlatformUriForAndroid(content, platform);
//     }

//     // Try opening the native app first
//     if (platformUri != null && await canLaunchUrl(platformUri)) {
//       await launchUrl(platformUri, mode: LaunchMode.externalApplication);
//     } else {
//       // If the app isn't installed, use the web fallback or share dialog
//       _fallbackToWebOrDefault(text, link, platform);
//     }
//   }

//   // Builds the shareable content from text and link
//   static String _buildContent(String? text, String? link) {
//     if (text != null && link != null) {
//       return "$text\n$link";
//     } else if (text != null) {
//       return text;
//     } else if (link != null) {
//       return link;
//     }
//     return "";
//   }

//   // Fallback to web or system share sheet
//   static void _fallbackToWebOrDefault(
//       String? text, String? link, SharePlatform platform) {
//     String content = _buildContent(text, link);
//     Uri? webUrl;

//     switch (platform) {
//       case SharePlatform.facebookPost:
//         webUrl = Uri.parse(
//             "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(content)}");
//         break;

//       case SharePlatform.facebookMessenger:
//         webUrl = Uri.parse("https://www.messenger.com/t/");
//         break;

//       case SharePlatform.instagram:
//         webUrl = Uri.parse("https://www.instagram.com/");
//         break;

//       case SharePlatform.instagramDirect:
//         webUrl = Uri.parse("https://www.instagram.com/direct/inbox/");
//         break;

//       case SharePlatform.twitter:
//         webUrl = Uri.parse(
//             "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(content)}");
//         break;

//       case SharePlatform.snapchat:
//         webUrl = Uri.parse("https://www.snapchat.com/");
//         break;

//       case SharePlatform.whatsapp:
//         webUrl = Uri.parse(
//             "https://web.whatsapp.com/send?text=${Uri.encodeComponent(content)}");
//         break;

//       case SharePlatform.normalShare:
//         webUrl = null; // No need for web fallback with normal share
//         break;
//     }

//     if (webUrl != null) {
//       launchUrl(webUrl, mode: LaunchMode.externalApplication).catchError((_) {
//         Share.share(content); // Final fallback to default share
//       });
//     } else {
//       Share.share(content);
//     }
//   }

//   // Get platform-specific URI for iOS
//   static Uri? _getPlatformUriForIOS(String content, SharePlatform platform) {
//     switch (platform) {
//       case SharePlatform.facebookPost:
//         return Uri.parse("fb://sharer/?u=${Uri.encodeComponent(content)}");
//       case SharePlatform.facebookMessenger:
//         return Uri.parse(
//             "fb-messenger://share/?link=${Uri.encodeComponent(content)}");
//       case SharePlatform.instagram:
//         return Uri.parse("instagram://app"); // Just open Instagram app
//       case SharePlatform.instagramDirect:
//         return Uri.parse("instagram://direct"); // Open Instagram Direct
//       case SharePlatform.twitter:
//         return Uri.parse("twitter://post?text=${Uri.encodeComponent(content)}");
//       case SharePlatform.snapchat:
//         return Uri.parse("snapchat://"); // Just open Snapchat app
//       case SharePlatform.whatsapp:
//         return Uri.parse(
//             "whatsapp://send?text=${Uri.encodeComponent(content)}");
//       case SharePlatform.normalShare:
//         return null; // No URI for normal share
//     }
//   }

//   // Get platform-specific URI for Android
//   static Uri? _getPlatformUriForAndroid(
//       String content, SharePlatform platform) {
//     switch (platform) {
//       case SharePlatform.facebookPost:
//         return Uri.parse(
//             "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(content)}");
//       case SharePlatform.facebookMessenger:
//         return Uri.parse(
//             "fb-messenger://share/?link=${Uri.encodeComponent(content)}");
//       case SharePlatform.instagram:
//         return Uri.parse(
//             "instagram://share?url=${Uri.encodeComponent(content)}");
//       case SharePlatform.instagramDirect:
//         return Uri.parse(
//             "instagram://direct?link=${Uri.encodeComponent(content)}");
//       case SharePlatform.twitter:
//         return Uri.parse(
//             "twitter://post?message=${Uri.encodeComponent(content)}");
//       case SharePlatform.snapchat:
//         return Uri.parse(
//             "snapchat://scan?attachmentUrl=${Uri.encodeComponent(content)}");
//       case SharePlatform.whatsapp:
//         return Uri.parse(
//             "whatsapp://send?text=${Uri.encodeComponent(content)}");
//       case SharePlatform.normalShare:
//         return null; // No URI for normal share
//     }
//   }

//   static Uri? _getPlatformUriForWeb(String content, SharePlatform platform) {
//     switch (platform) {
//       case SharePlatform.facebookPost:
//         return Uri.parse(
//             "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(content)}");
//       case SharePlatform.facebookMessenger:
//         return Uri.parse("https://www.messenger.com/t/");
//       case SharePlatform.instagram:
//         return Uri.parse("https://www.instagram.com/");
//       case SharePlatform.instagramDirect:
//         return Uri.parse("https://www.instagram.com/direct/inbox/");
//       case SharePlatform.twitter:
//         return Uri.parse(
//             "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(content)}");
//       case SharePlatform.snapchat:
//         return Uri.parse("https://www.snapchat.com/");
//       case SharePlatform.whatsapp:
//         return Uri.parse(
//             "https://web.whatsapp.com/send?text=${Uri.encodeComponent(content)}");
//       case SharePlatform.normalShare:
//         return null;
//     }
//   }
// }
