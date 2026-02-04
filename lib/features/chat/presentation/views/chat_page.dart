// import 'package:chat_package/chat_package.dart';
// import 'package:chat_package/models/chat_message.dart';
// import 'package:chat_package/models/media/chat_media.dart';
// import 'package:chat_package/models/media/media_type.dart';
// import 'package:flutter/material.dart';

// class ChatPage extends StatelessWidget {
//   const ChatPage();

//   @override
//   Widget build(BuildContext context) {
//     // Sample chat messages
//     List<ChatMessage> chatMessages = [
//       ChatMessage(
//         isSender: true,
//         text: 'this is a banana',
//         chatMedia: ChatMedia(
//           url:
//               'https://images.pexels.com/photos/7194915/pexels-photo-7194915.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
//           mediaType: const MediaType.imageMediaType(),
//         ),
//       ),
//       ChatMessage(
//           isSender: false,
//           text: 'this is a sdf',
//           chatMedia:
//               ChatMedia(mediaType: const MediaType.imageMediaType(), url: '')
//           // chatMedia: ChatMedia(
//           //   url:
//           //       'https://images.pexels.com/photos/7194915/pexels-photo-7194915.jpeg?auto=compress&cs=tinysrgb&h=750&w=1260',
//           //   mediaType: MediaType.imageMediaType(),
//           // ),
//           ),

//       // Add more chat messages as needed
//     ];

//     return Scaffold(

//       body: ListView.builder(
//         itemCount: chatMessages.length,
//         itemBuilder: (context, index) {
//           ChatMessage message = chatMessages[index];
//           return Card(
//             child: ListTile(
//               title: AutoSizeText(message.text),
//               // You can add more details here such as the media
//               // For example:
//               // leading: message.chatMedia != null ? Image.network(message.chatMedia!.url) : null,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
