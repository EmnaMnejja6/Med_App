import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enis/pages/Admin/adminpanel.dart';
import 'package:enis/pages/Doctor/home_doctor.dart';
import 'package:enis/pages/Super%20Admin/super_admin_panel.dart';

import '../../user_auth/firebase_implementation/firebase_auth_services.dart';
import '../../pages/Super%20Admin/super_admin_panel.dart';

class Newlogin extends StatefulWidget {
  const Newlogin({super.key});

  @override
  State<Newlogin> createState() => _NewloginState();
}

class _NewloginState extends State<Newlogin> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late Color myColor;
  late Size mediaSize;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      var result = await _auth.signInWithEmailAndPassword(email, password);

      if (result != null) {
        User? user = result['user'];
        String role = result['role'];

        if (role == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeDoctor()),
          );
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel()),
          );
        } else if (role == 'super_admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SuperAdminPanel()),
          );
        } else {
          print("Role not recognized!");
        }
      } else {
        print("An error occurred!");
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "L'adresse email est incorrecte";
          break;
        case 'wrong-password':
          message = "Le mot de passe est incorrect";
          break;
        case 'invalid-email':
          message = "L'adresse email est invalide";
          break;
        case 'user-disabled':
          message = "L'utilisateur a été désactivé";
          break;
        case 'too-many-requests':
          message = "Trop de tentatives de connexion. Veuillez réessayer plus tard.";
          break;
        default:
          message = "Une erreur est survenue. Veuillez réessayer.";
      }
      _showErrorMessage(message);
    } catch (e) {
      print("Unknown error: $e");
      _showErrorMessage("Une erreur inconnue est survenue. Veuillez réessayer.");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    myColor = const Color.fromARGB(255, 33, 177, 243);
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/nn.jpg"),
          fit: BoxFit.cover,
          colorFilter:
          ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Positioned(top: 20, child: _buildTop()),
          Positioned(bottom: 0, child: _buildBottom()),
        ]),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "MedApp",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 0.5),
          Image.asset(
            "assets/images/logo.png",
            height: 200,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenu",
          style: TextStyle(
            color: myColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildGreyText("Entrez vos coordonnées s'il vous plait"),
        const SizedBox(height: 30),
        _buildGreyText("Adresse Email"),
        _buildInputField(_emailController),
        const SizedBox(height: 20),
        _buildGreyText("Mot de passe "),
        _buildInputField(_passwordController, isPassword: true),
        const SizedBox(height: 20),
        const SizedBox(height: 10),
        _buildLoginButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : Icon(Icons.done),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: const Text("Se connecter"),
    );
  }
}
