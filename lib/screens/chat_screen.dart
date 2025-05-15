import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User? loggedInUser; // "FireBase User" is deprecated => use "User"

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String messageText;
  final messageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GetCurrentUser();
  }

  void GetCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        // print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshots in _firestore.collection("messages").snapshots()) {
      for (var message in snapshots.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async{
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Center(
            child: Text(
          textAlign: TextAlign.center,
          '⚡️Chat',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        )),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      if (loggedInUser != null &&
                          messageText.trim().isNotEmpty) {
                        _firestore.collection("messages").add(
                          {
                            "text": messageText,
                            "sender": loggedInUser?.email,
                            "timestamp": FieldValue.serverTimestamp(),
                          },
                        );
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("messages")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data?.docs;
        List<MessBubble> messageBubbles = [];
        for (var message in messages!) {
          final data = message.data() as Map<String, dynamic>;
          final messageText = data['text'] ?? '';
          final messageSender = data['sender'] ?? 'Unknown';

          final currentUser = loggedInUser!.email;

          if (currentUser == messageSender) {
            final messageBubble = MessBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
              bblAlign: CrossAxisAlignment.end,
              bubbleColor: Colors.lightGreen,
            );
            messageBubbles.add(messageBubble);
          } else {
            final messageBubble = MessBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
              bubbleColor: Colors.lightBlueAccent,
              bblAlign: CrossAxisAlignment.start,
            );
            messageBubbles.add(messageBubble);
          }
        }
        return Flexible(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessBubble extends StatelessWidget {
  const MessBubble(
      {required this.sender,
      required this.text,
      required this.isMe,
      required this.bubbleColor,
      required this.bblAlign});

  final String sender;
  final String text;
  final bool isMe;
  final bubbleColor;
  final CrossAxisAlignment bblAlign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: bblAlign,
        children: [
          Text(
            sender,
            style: GoogleFonts.poppins(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
          Transform.flip(
            flipX: !isMe,
            child: Material(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              elevation: 5.0,
              color: bubbleColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20.0,
                ),
                child: Transform.flip(
                  flipX: !isMe,
                  child: Text(
                    text,
                    style: GoogleFonts.lato(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// error fix : // /fix Utilities: Error in unawaited Future:Error: 
//Bad state: No running isolate //(inspector is not set).
// ------------------- C O R R E C T I O N -------------------------------------
// The error is likely caused by the use of await on a non-async getter (_auth.currentUser!) in GetCurrentUser,
// and also by inconsistent collection names ("message" vs "messages"); 
//you should remove await from final user = await _auth.currentUser!; 
//and ensure you use the same collection name everywhere.