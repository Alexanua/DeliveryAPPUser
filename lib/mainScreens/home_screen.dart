import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc("USER_ID").get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // حالة انتظار تحميل البيانات
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // التعامل مع حالة الخطأ
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            // حالة عدم وجود بيانات
            return Center(child: Text('No data available'));
          } else {
            // التعامل مع البيانات عند توفرها
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Center(child: Text('Welcome, ${userData['name']}'));
          }
        },
      ),
    );
  }
}
