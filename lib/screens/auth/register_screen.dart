import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // Detect web
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode



Future<Map<String, dynamic>> registerUser({

  required String firstName,
  String? middleName,
  required String lastName,
  required String age,
  required String address,
  required String phone,
  required String email,
  required String password,
  required File? documentFile,
  required Uint8List? documentBytes,
  String? documentExtension,
}) async {
  final uri= Uri.parse('http://192.168.0.110:8000/api/accounts/register/');

  var request= http.MultipartRequest('POST', uri);

  request.fields['first_name']= firstName;
  if(middleName != null) {
    request.fields['middle_name']= middleName;
  }
  request.fields['last_name']= lastName;
  request.fields['age']= age;
  request.fields['address']= address;
  request.fields['phone']= phone;
  request.fields['email']= email;
  request.fields['password']= password;

  if(kIsWeb) {
    if (documentBytes != null) {
      String ext= documentExtension ?? 'png'; // fallback to png
      request.files.add(http.MultipartFile.fromBytes(
        'document_image',
        documentBytes,
        filename: 'license_${DateTime.now().millisecondsSinceEpoch}.$ext', // dynamic filename
      ));
    }
  }else{
    if(documentFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'document_image',
        documentFile.path,
        filename: documentFile.path.split('/').last, // dynamic filename
      ));
    }
  }

  try{
    var streamedResponse= await request.send();
    var response= await http.Response.fromStream(streamedResponse);

    if(response.statusCode == 201){
      return {"success": true, "message": "User registered successfully"};
    }else{
      var data= jsonDecode(response.body);
      return {"success": false, "message": data.toString()};
    }
  }catch(e){
      return {"success": false, "message": e.toString()};
  }

}



class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class  _RegisterScreenState extends State<RegisterScreen> {
  final Color midnightBlue = Color(0xFF004760);
  final Color steelBlue = Color(0xFF218BA2);

  bool _obscurePassword= true;

  final TextEditingController firstNameController= TextEditingController();
  final TextEditingController middleNameController= TextEditingController();
  final TextEditingController lastNameController= TextEditingController();
  final TextEditingController ageController= TextEditingController();
  final TextEditingController addressController= TextEditingController();
  final TextEditingController phoneController= TextEditingController();
  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController= TextEditingController();
  final TextEditingController confirmPasswordController= TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? documentFile; // used fo mobile
  Uint8List? documentBytes; // used for web
  String? documentExtension; // for web file extension


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Image.asset(
                  'assets/images/registration.jpeg',
                  height: 200,
                  fit: BoxFit.contain,
              ),

              Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: midnightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'First Name',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'First name is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: middleNameController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Middle Name',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Last Name',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: ageController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Age',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Age is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Address',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Phone Number',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Email',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Password',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            color: Colors.white,
                            iconSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 10,),

                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Confirm Password',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            color: Colors.white,
                            iconSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value== null || value.isEmpty){
                            return 'Confirm password is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 15,),

                      GestureDetector(
                          onTap: () async {
                            // on mobile:
                            if(!kIsWeb){
                              PermissionStatus status= await Permission.storage.request();
                              if(!status.isGranted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Storage permission is required to upload the license')),
                                );
                                return;
                              }
                            }

                            // pick file
                            FilePickerResult? result= await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                              withData: kIsWeb, // to import from web
                            );

                            if(result != null){
                              setState(() {
                                if(kIsWeb){
                                  documentBytes= result.files.single.bytes; // for web
                                  documentExtension = result.files.single.extension; // save extension
                                }
                                else{
                                  documentFile= File(result.files.single.path!); // for mobile
                                }
                              });
                            }
                          },
                          child: Text(
                            (documentFile != null || documentBytes != null) ? 'License Selected' : 'Upload License *',
                            style: TextStyle(color: Colors.redAccent,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                      ),

                      SizedBox(height: 40,),

                      ElevatedButton(
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              if (documentFile == null && documentBytes == null){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please upload your license')),
                                );
                                return;
                              }

                              var result = await registerUser(
                                firstName: firstNameController.text,
                                middleName: middleNameController.text.isEmpty ? null : middleNameController.text,
                                lastName: lastNameController.text,
                                age: ageController.text,
                                address: addressController.text,
                                phone: phoneController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                documentFile: documentFile,
                                documentBytes: documentBytes,
                                documentExtension: documentExtension,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );

                              if (result['success']) {
                                Navigator.pushNamed(context, '/login');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: steelBlue,
                            padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),

                          ),
                          child: Text(
                            'REGISTER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),

                      SizedBox(height: 6,),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
