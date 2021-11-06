import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _cpasswordTextEditingController = TextEditingController();
  final GlobalKey _formkey = GlobalKey<FormState>();
  String UserImageURL = "";
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height; //fix the screen according to the size of the screen
    return SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap : _selectAndPickImage,
                child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile==null ? null: FileImage(_imageFile), // displays image if you have it
                  child: _imageFile==null
                      ? Icon(Icons.add_photo_alternate, size: _screenWidth*0.15, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 8.0,),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameTextEditingController,
                      data: Icons.person,
                      hintText: "Name",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _emailTextEditingController ,
                      data: Icons.email,
                      hintText: "Email",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _passwordTextEditingController ,
                      data: Icons.visibility_off,
                      hintText: "Password",
                      isObscure: true,
                    ),
                    CustomTextField(
                      controller: _cpasswordTextEditingController ,
                      data: Icons.visibility_off,
                      hintText: "Confirm Password",
                      isObscure: true,
                    )
                  ],
                ),
              ),
              RaisedButton(
                  onPressed: ()
                    { uploadAndSaveImage(); },
                  color: Colors.green,
                  child: Text("Sign up", style: TextStyle(color: Colors.white),),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                height: 4.0,
                width: _screenWidth*0.8,
                color: Colors.pink,
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ));
  }
  Future<void> _selectAndPickImage() async{
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadAndSaveImage() async
  {
    if(_imageFile == null)
      {
        showDialog(
            context: context ,
            builder: (c)
            {
              return ErrorAlertDialog(message: "Please Select an Image",);
            }
        );
      }
    else {
      _passwordTextEditingController.text == _cpasswordTextEditingController.text
          ? _emailTextEditingController.text.isNotEmpty &&
          _passwordTextEditingController.text.isNotEmpty &&
          _cpasswordTextEditingController.text.isNotEmpty &&
          _nameTextEditingController.text.isNotEmpty

          ? uploadToStorage()

          : displayDialog("Please Fill up the complete form")

          :displayDialog("Password do not Match");
    }
    }
    displayDialog(String msg)
    {
      showDialog(
          context: context,
          builder: (c)
      {
        return ErrorAlertDialog(message: msg,);
      }
      );
    }

    uploadToStorage() async
    {
      showDialog(
          context: context,
          builder: (c) {
            return LoadingAlertDialog(message: "Authenticating, Please wait...",);
          }
      );
      String imageFileName = DateTime.now().millisecondsSinceEpoch.toString(); //select an unique image name
      StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName); //set storage of Firebase
      StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);
      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
      await taskSnapshot.ref.getDownloadURL().then((urlImage) {
        UserImageURL = urlImage;
        _registerUser();
      });
    }

    FirebaseAuth _auth = FirebaseAuth.instance;
    void _registerUser() async{
      FirebaseUser firebaseUser;

      await _auth.createUserWithEmailAndPassword
        (
        email: _emailTextEditingController.text.trim(),
        password: _passwordTextEditingController.text.trim(),
      ).then((auth) {
        firebaseUser = auth.user;
      }).catchError((error) {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (c)
        {
          return ErrorAlertDialog(message : error.message.toString(),);
        });
      });
      if(firebaseUser != null)
        {
          saveUserInfoToFireStore(firebaseUser).then((value) {
            Navigator.pop(context);
            Route route = MaterialPageRoute(builder: (C) => StoreHome());
            Navigator.pushReplacement(context, route);
          });
        }
    }
    Future saveUserInfoToFireStore (FirebaseUser f_user) async
    {
      Firestore.instance.collection("users").document(f_user.uid).setData({
        "uid" : f_user.uid,
        "email" : f_user.email,
        "name" : _nameTextEditingController.text.trim(),
        "url" : UserImageURL,
        EcommerceApp.userCartList: ["garbage value"],
      });

      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userUID, f_user.uid);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, f_user.email);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, _nameTextEditingController.text.trim());
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, UserImageURL);
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
    }
  }