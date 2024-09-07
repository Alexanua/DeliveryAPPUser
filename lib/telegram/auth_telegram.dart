import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../mainScreens/home_screen.dart';


// وظيفة لإرسال رسالة إلى Telegram
Future<void> sendMessageToTelegram(String chatId, String message) async {
  String token = '7520797773:AAG7HmA0zENvBsa_czUak2v1uDW1s0RvRuE';  // توكن البوت الخاص بك
  var url = 'https://api.telegram.org/bot$token/sendMessage';

  var response = await http.post(
    Uri.parse(url),
    body: json.encode({
      'chat_id': chatId,  // معرف المستخدم في Telegram
      'text': message,
    }),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    print('Message sent successfully!');
  } else {
    print('Failed to send message. Error: ${response.body}');
  }
}

// وظيفة للحصول على chat_id الخاص بالمستخدم من Telegram
Future<void> getChatId() async {
  String token = '7520797773:AAG7HmA0zENvBsa_czUak2v1uDW1s0RvRuE';  // توكن البوت الخاص بك
  var url = 'https://api.telegram.org/bot$token/getUpdates';

  var response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);

    if (jsonResponse['result'].isNotEmpty) {
      var chatId = jsonResponse['result'][0]['message']['chat']['id'].toString();
      print('Chat ID: $chatId');
    } else {
      print('No messages found in the bot. Please send a message to the bot to get the chat ID.');
    }
  } else {
    print('Failed to get updates. Error: ${response.body}');
  }
}


// وظيفة لحفظ بيانات المستخدم في Firebase Firestore
Future<void> saveTelegramUserData(String telegramUserId, String name) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> saveTelegramUserData() async {
    String telegramUserId = '2141537419';  // معرف المستخدم
    String userName = 'مجدي';  // اسم المستخدم

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('users').doc(telegramUserId).set({
      'name': userName,
      'telegramUserId': telegramUserId,
      'createdAt': DateTime.now(),
    });

    print('User data saved successfully');
  }


  await firestore.collection('users').doc(telegramUserId).set({
    'name': name,
    'telegramUserId': telegramUserId,
    'createdAt': DateTime.now(),
  });

  print('User data saved successfully');
}

// وظيفة للتحقق من هوية المستخدم باستخدام معرف Telegram في Firebase
// وظيفة للتحقق من هوية المستخدم باستخدام معرف Telegram في Firebase
Future<void> authenticateUser(BuildContext context, String telegramUserId) async {
  var userDocument = await FirebaseFirestore.instance.collection('users').doc(telegramUserId).get();

  if (userDocument.exists) {
    print('User authenticated successfully');
    // توجيه المستخدم إلى الصفحة الرئيسية
    Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeScreen()));
  } else {
    print('Authentication failed');
    // عرض رسالة خطأ
  }
}




// وظيفة لإرسال تأكيد الطلب للمستخدم عبر Telegram
void sendOrderConfirmation(String telegramUserId) {

  String chatId = '2141537419';  // المعرف الخاص بالمستخدم
  sendMessageToTelegram(chatId, " تم تأكيد  طلبك بنجاح");

}

// واجهة المصادقة باستخدام Telegram
class AuthTelegram extends StatefulWidget {
  const AuthTelegram({Key? key}) : super(key: key);

  @override
  State<AuthTelegram> createState() => _AuthTelegramState();
}

class _AuthTelegramState extends State<AuthTelegram> {
  TextEditingController telegramUserIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telegram Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: telegramUserIdController,
              decoration: const InputDecoration(
                labelText: "Enter Telegram User ID",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String telegramUserId = telegramUserIdController.text;
                // قم بتوثيق المستخدم باستخدام معرف Telegram
                authenticateUser(context, telegramUserId);
              },
              child: const Text("Authenticate"),
            ),
          ],
        ),
      ),
    );
  }
}