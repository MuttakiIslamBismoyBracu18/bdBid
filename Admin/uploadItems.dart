import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;


class UploadPage extends StatefulWidget
{
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{
  bool get wantKeepAlive => true;
  File file;
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _shortInfoTextEditingController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;


  @override
  Widget build(BuildContext context) {
    return file == null ? displayAdminHomeScreen() : displayAdminUploadFormScreen() ;
  }
  displayAdminHomeScreen()
  {
    return Scaffold(
      appBar: AppBar
        (
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
        leading: IconButton(
          icon: Icon(Icons.border_color, color: Colors.black45,),
          onPressed: ()
          {
            Route route = MaterialPageRoute(builder: (C) => AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
              onPressed: (){
                Route route = MaterialPageRoute(builder: (C) => SplashScreen());
                Navigator.pushReplacement(context, route);
              },
              child: Text("Logout",style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 16.0, fontWeight: FontWeight.bold),))
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }
  getAdminHomeScreenBody()
  {
    return Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors :[Colors.white38, Colors.blueAccent],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp ,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, color: Colors.redAccent, size: 200.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                  child: Text("New Product for Auction", style:TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),),
                color: Colors.green,
                onPressed: () => takeImage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  takeImage(mContext)
  {
    return showDialog(
        context: mContext,
        builder: (context)
    {
      return SimpleDialog(
        title: Text("Product Image", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
        children: [
        SimpleDialogOption(
          child: Text("Capture with Camera",style: TextStyle(color: Colors.black), ),
          onPressed: capturePhotoWithCamera,
        ),
          SimpleDialogOption(
            child: Text("Select from Gallery",style: TextStyle(color: Colors.black), ),
            onPressed: pickPhotoFromGallery,
          ),
          SimpleDialogOption(
            child: Text("Cancel",style: TextStyle(color: Colors.black), ),
            onPressed: ()
            {
              Navigator.pop(context);
            },
          ),
        ],
      );
    });
  }
  capturePhotoWithCamera() async
  {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight : 680.0, maxWidth: 970.0);
    setState(() {
      file = imageFile;
    });
  }
  pickPhotoFromGallery() async
  {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      file = imageFile;
    });
  }
  displayAdminUploadFormScreen()
  {
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
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black),onPressed: clearFormInfo),
        title: Text("New Product for Auction", style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),),
        actions: [
          FlatButton(
              onPressed:uploading ? null : ()=> uploadImageAndSaveItemInfo(),
              child: Text("Add",style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),))
        ],
      ),
      body: ListView(
        children: [
          uploading ? circularProgress() : Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width *0.8 ,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 12.0)
          ),
          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.black),
            title: Container(
              width:250.0,
              child: TextField(
                style: TextStyle(color: Colors.redAccent),
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                hintText: "Product Name",
                hintStyle: TextStyle(color: Colors.redAccent),
                border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),

          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.black),
            title: Container(
              width:250.0,
              child: TextField(
                style: TextStyle(color: Colors.redAccent),
                controller:  _shortInfoTextEditingController,
                decoration: InputDecoration(
                  hintText: "Product details",
                  hintStyle: TextStyle(color: Colors.redAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),

          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.black),
            title: Container(
              width:250.0,
              child: TextField(
                style: TextStyle(color: Colors.redAccent),
                controller: _descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Product Description",
                  hintStyle: TextStyle(color: Colors.redAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),

          ListTile(
            leading: Icon(Icons.perm_device_information, color: Colors.black),
            title: Container(
              width:250.0,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.redAccent),
                controller: _priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Minimum Bid Price",
                  hintStyle: TextStyle(color: Colors.redAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black,),

        ],
      ),
    );

  }
  clearFormInfo()
  {
    setState(() {
      file = null;
      _descriptionTextEditingController.clear();
      _priceTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _titleTextEditingController.clear();
    });
  }
  uploadImageAndSaveItemInfo() async
  {
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl = await uploadItemImage(file);
    saveItemInfo(imageDownloadUrl);
  }
  Future<String> uploadItemImage(mFileImage) async
  {
    final StorageReference storageReference = FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask = storageReference.child("product_$productId.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  saveItemInfo(String downloadUrl)
  {
    final itemsRef = Firestore.instance.collection("items");
    itemsRef.document(productId).setData({
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": _priceTextEditingController.text,
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
    });
    setState(() {
      file=null;
      uploading=false;
      productId= DateTime.now().millisecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
    });
  }
}
