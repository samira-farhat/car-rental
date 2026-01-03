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
  //Samira
  final uri= Uri.parse('http://localhost:8000/api/accounts/register/');
  // final uri = Uri.parse(
  //   //Mohammad
  //   'http://192.168.10.20:8000/api/accounts/register/',
  // );

  var request = http.MultipartRequest('POST', uri);

  request.fields['first_name'] = firstName;
  if (middleName != null) {
    request.fields['middle_name'] = middleName;
  }
  request.fields['last_name'] = lastName;
  request.fields['age'] = age;
  request.fields['address'] = address;
  request.fields['phone'] = phone;
  request.fields['email'] = email;
  request.fields['password'] = password;

  if (kIsWeb) {
    if (documentBytes != null) {
      String ext = documentExtension ?? 'png'; // fallback to png
      request.files.add(
        http.MultipartFile.fromBytes(
          'document_image',
          documentBytes,
          filename:
          'license_${DateTime.now().millisecondsSinceEpoch}.$ext', // dynamic filename
        ),
      );
    }
  } else {
    if (documentFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'document_image',
          documentFile.path,
          filename:
          documentFile.path.split('/').last, // dynamic filename
        ),
      );
    }
  }

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return {"success": true, "message": "User registered successfully"};
    } else {
      var data = jsonDecode(response.body);
      return {"success": false, "message": data.toString()};
    }
  } catch (e) {
    return {"success": false, "message": e.toString()};
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color midnightBlue = Color(0xFF004760);
  final Color steelBlue = Color(0xFF218BA2);

  int currentStep = 0;

  bool _obscurePassword = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
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
                      if (currentStep == 0) stepOne(),
                      if (currentStep == 1) stepTwo(),
                      if (currentStep == 2) stepThree(),

                      SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: currentStep == 0
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.spaceBetween,
                        children: [

                          // BACK button
                          if (currentStep > 0)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  currentStep--;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Back',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                          // NEXT button (steps 0 & 1)
                          if (currentStep < 2)
                            TextButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    currentStep++;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),

                          // REGISTER (final step only)
                          if (currentStep == 2)
                            ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                if (documentFile == null && documentBytes == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please upload your license')),
                                  );
                                  return;
                                }

                                var result = await registerUser(
                                  firstName: firstNameController.text,
                                  middleName: middleNameController.text.isEmpty
                                      ? null
                                      : middleNameController.text,
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
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: steelBlue,
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              ),
                              child: Text(
                                'REGISTER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 6),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(color: Colors.white),
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

  // STEPS

  Widget stepOne() {
    return Column(
      children: [
        firstNameField(),
        SizedBox(height: 10),
        middleNameField(),
        SizedBox(height: 10),
        lastNameField(),
        SizedBox(height: 10),
        ageField(),
      ],
    );
  }

  Widget stepTwo() {
    return Column(
      children: [
        addressField(),
        SizedBox(height: 10),
        phoneField(),
        SizedBox(height: 10),
        emailField(),
      ],
    );
  }

  Widget stepThree() {
    return Column(
      children: [
        passwordField(),
        SizedBox(height: 10),
        confirmPasswordField(),
        SizedBox(height: 15),
        uploadLicenseButton(),
      ],
    );
  }

  // FIELDS

  Widget firstNameField() => buildRequiredField(
      firstNameController, 'First Name', 'First name is required');

  Widget middleNameField() => TextFormField(
    controller: middleNameController,
    style: TextStyle(color: Colors.white),
    decoration:
    InputDecoration(labelText: 'Middle Name', labelStyle: TextStyle(color: Colors.white)),
  );

  Widget lastNameField() => buildRequiredField(
      lastNameController, 'Last Name', 'Last name is required');

  Widget ageField() =>
      buildRequiredField(ageController, 'Age', 'Age is required');

  Widget addressField() =>
      buildRequiredField(addressController, 'Address', 'Address is required');

  Widget phoneField() => buildRequiredField(
      phoneController, 'Phone Number', 'Phone number is required');

  Widget emailField() =>
      buildRequiredField(emailController, 'Email', 'Email is required');

  Widget passwordField() => buildPasswordField(
      passwordController, 'Password', 'Password is required');

  Widget confirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      style: TextStyle(color: Colors.white),
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: 'Confirm Password',
            style: TextStyle(color: Colors.white),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          color: Colors.white,
          iconSize: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Confirm password is required';
        }
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget uploadLicenseButton() {
    final bool hasFile = documentFile != null || documentBytes != null;

    return GestureDetector(
      onTap: () async {
        // Mobile permission
        if (!kIsWeb) {
          PermissionStatus status = await Permission.storage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required'),
              ),
            );
            return;
          }
        }

        // Pick file
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
          withData: kIsWeb,
        );

        if (result != null) {
          setState(() {
            if (kIsWeb) {
              documentBytes = result.files.single.bytes;
              documentExtension = result.files.single.extension;
            } else {
              documentFile = File(result.files.single.path!);
            }
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? Colors.greenAccent : Colors.redAccent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_file,
              color: hasFile ? Colors.greenAccent : Colors.white,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasFile
                    ? 'License Selected'
                    : 'Upload Driver License *',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }


  Widget buildRequiredField(
      TextEditingController controller, String label, String error) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.white),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return error;
        return null;
      },
    );
  }

  Widget buildPasswordField(
      TextEditingController controller, String label, String error) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.white),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility),
          color: Colors.white,
          iconSize: 20,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return error;
        return null;
      },
    );
  }
}
