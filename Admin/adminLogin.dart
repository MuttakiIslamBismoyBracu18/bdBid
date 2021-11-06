import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';




class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              colors :[Colors.white38, Colors.blueAccent],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp ,
            ),
          ),
        ),
        title: Text (
          "bdBid",
          style: TextStyle(fontSize: 55.0, color: Colors.white, fontFamily: "Signatra"),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}


class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen>
{
  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  colors :[Colors.white38, Colors.blueAccent],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp ,
                ),
              ),
              child: Image.asset(
                "images/admin.png",
                height: 240.0,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Padding(padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin",
                style: TextStyle(color: Colors.white, fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIDTextEditingController,
                    data: Icons.person,
                    hintText: "ID",
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.visibility_off,
                    hintText: "Password",
                    isObscure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                _adminIDTextEditingController.text.isNotEmpty &&
                    _passwordTextEditingController.text.isNotEmpty
                    ? loginAdmin()
                    : showDialog(
                  context: context,
                  builder: (C) {
                    return ErrorAlertDialog(
                      message: "Please write Email & Password.",);
                  },);
              },
              color: Colors.green,
              child: Text("Log In", style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.white,
            ),
            SizedBox(
              height: 20.0,
            ),
            FlatButton.icon(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AuthenticScreen())),
              icon: (Icon(Icons.people, color: Colors.black87,)),
              label: Text("I'm not an Admin", style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold),),
            ),
            SizedBox(
              height: 50.0,
            )
          ],
        ),
      ),
    );
  }
  loginAdmin()
  {
    Firestore.instance.collection("admins").getDocuments().then((snapshot){
      snapshot.documents.forEach((result){
        if(result.data["id"]!= _adminIDTextEditingController.text.trim())
          {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your Id is not correct!"),));
          }
       else if(result.data["password"]!= _passwordTextEditingController.text.trim())
         {
           Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your Password is incorrect!"),));
         }
       else
         {
           Scaffold.of(context).showSnackBar(SnackBar(content: Text("Login Successful,"+result.data["name"]),));
           setState(() {
             _adminIDTextEditingController.text = "";
             _passwordTextEditingController.text="";
           });
           Route route = MaterialPageRoute(builder: (C) => UploadPage());
           Navigator.pushReplacement(context, route);
         }
      });
    });
  }
}
