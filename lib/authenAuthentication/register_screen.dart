import 'dart:io';  // للتعامل مع الملفات
import 'package:firebase_auth/firebase_auth.dart';  // Firebase Authentication
import 'package:firebase_storage/firebase_storage.dart';  // Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  // Image Picker
import 'package:geolocator/geolocator.dart';  // للحصول على الموقع الجغرافي
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';  // لتخصيص حقول الإدخال
import '../widgets/error_dialog.dart';  // لعرض رسائل الخطأ
import '../widgets/loading_dialog.dart';  // لعرض رسالة التحميل
import 'package:shared_preferences/shared_preferences.dart';  // لتخزين البيانات محليًا

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // بقية الحقول اختيارية
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  String userImageUrl = "";
  Position? position;
  String completeAddress = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  Future<void> formValidation() async {
    if (phoneController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      // التأكد من إدخال رقم الهاتف وكلمة السر
      showDialog(
        context: context,
        builder: (c) {
          return LoadingDialog(
            message: "Registering Account",
          );
        },
      );

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      if (imageXFile != null) {
        Reference reference = FirebaseStorage.instance.ref().child("users").child(fileName);
        UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((url) {
          userImageUrl = url;
          authenticateUserAndSignUp();
        });
      } else {
        authenticateUserAndSignUp(); // إذا لم يتم تحميل صورة
      }
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please enter your phone number and password.",
          );
        },
      );
    }
  }

  void authenticateUserAndSignUp() async {
    // منطق إنشاء المستخدم مع Firebase وتخزين البيانات مع رقم الهاتف وكلمة السر
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: phoneController.text.trim() + "@phone.com",  // نستخدم رقم الهاتف كبديل للبريد الإلكتروني
      password: passwordController.text.trim(),
    ).then((auth) {
      // باقي منطق التسجيل وحفظ البيانات
      saveUserData(auth.user);
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: error.message.toString(),
          );
        },
      );
    });
  }

  Future<void> saveUserData(User? currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser!.uid).set({
      "userUID": currentUser.uid,
      "userPhone": phoneController.text.trim(),
      "userPassword": passwordController.text.trim(),
      "userName": nameController.text.trim(),
      "userEmail": emailController.text.trim(),
      "userAvatarUrl": userImageUrl,
      "location": locationController.text.trim(),
    });

    // حفظ البيانات محليًا باستخدام SharedPreferences
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("uid", currentUser.uid);
    await sharedPreferences.setString("phone", phoneController.text.trim());
    await sharedPreferences.setString("name", nameController.text.trim());
    await sharedPreferences.setString("photoUrl", userImageUrl);
    await sharedPreferences.setString("location", locationController.text.trim());

    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (c) =>  HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 10,),
          InkWell(
            onTap: () { _getImage(); },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundColor: Colors.white,
              backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
              child: imageXFile == null ? Icon(Icons.add_photo_alternate, size: MediaQuery.of(context).size.width * 0.20, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 10,),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.phone,
                  controller: phoneController,
                  hintText: "Phone",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.lock,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecre: true,
                ),
                // الحقول الاختيارية
                CustomTextField(
                  data: Icons.person,
                  controller: nameController,
                  hintText: "Name (Optional)",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.email,
                  controller: emailController,
                  hintText: "Email (Optional)",
                  isObsecre: false,
                ),
                CustomTextField(
                  data: Icons.my_location,
                  controller: locationController,
                  hintText: "Address (Optional)",
                  isObsecre: false,
                  enabled: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
            onPressed: () { formValidation(); },
            child: const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}
