/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/Admin/adminpanel.dart';
import 'package:enis/pages/Super%20Admin/super_admin_panel.dart';
import 'package:enis/pages/Doctor/home_doctor.dart';
import 'package:enis/user_auth/firebase_implementation/firebase_auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "MedApp",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Connectez-vous à votre compte",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 44.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: "Email de l'utilisateur",
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Colors.blue,
                  )),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Mot de passe",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.blue,
                  )),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const SizedBox(
              height: 44.0,
            ),
            Container(
              width: double.infinity,
              child: RawMaterialButton(
                fillColor: Color(0xFF0069FE),
                elevation: 0.0,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onPressed: _signIn,
                child: Text(
                  "Se Connecter",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    var result = await _auth.signInWithEmailAndPassword(email, password);

    if (result != null) {
      User? user = result['user'];
      String role = result['role'];

      if (role == 'doctor') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeDoctor()),
        );
      } else if (role == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPanel()),
        );
      } else if (role == 'super_admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminPanel()),
        );
      } else {
        print("Role not recognized!");
      }
    } else {
      print("Une erreur s'est produite !");
    }
  }
}
*/