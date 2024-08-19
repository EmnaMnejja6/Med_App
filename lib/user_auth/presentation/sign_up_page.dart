import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enis/user_auth/firebase_implementation/firebase_auth_services.dart';

import 'WaitingPage.dart';
import 'newlogin.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  final TextEditingController _lastNameController = TextEditingController(); // Controller for 'nom'
  final TextEditingController _firstNameController = TextEditingController(); // Controller for 'prenom'
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'doctor'; // default role
  bool _passwordVisible = false; // password visibility toggle

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top:29.0, left: 10.0),
                child: const Text(
                  "MedApp",
                  style: TextStyle(
                    color: Color(0xFF084cac),
                    fontSize: 45.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: const Text(
                  "Créer un nouveau compte",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 44.0,
              ),
              TextField(
                controller: _lastNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Nom",
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color(0xFF084cac),
                  ),
                ),
              ),
              const SizedBox(
                height: 26.0,
              ),
              TextField(
                controller: _firstNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Prénom",
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Color(0xFF084cac),
                  ),
                ),
              ),
              const SizedBox(
                height: 26.0,
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: Icon(
                    Icons.mail,
                    color: Color(0xFF084cac),
                  ),
                ),
              ),
              const SizedBox(
                height: 26.0,
              ),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: "Mot de passe",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xFF084cac),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons
                          .visibility_off,
                      color: Color(0xFF084cac),
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 11.0,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Vous avez déjà un compte? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                                LoginPage()));
                      },
                      child: Text(
                        "Connectez-vous",
                        style: TextStyle(
                          color: Color(0xFF084cac),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "Choisissez votre rôle",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'doctor',
                    groupValue: _selectedRole,
                    activeColor: Color(0xFF084cac),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  Text('Doctor'),
                  Radio<String>(
                    value: 'admin',
                    groupValue: _selectedRole,
                    activeColor: Color(0xFF084cac),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  Text('Admin'),
                  Radio<String>(
                    value: 'super_admin',
                    groupValue: _selectedRole,
                    activeColor: Color(0xFF084cac),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  Text('Super Admin'),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: RawMaterialButton(
                  fillColor: Color(0xFF084cac),
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  onPressed: _signUp,
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(color: Colors.white
                        , fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    String lastName = _lastNameController.text;
    String firstName = _firstNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (lastName.isEmpty || firstName.isEmpty || email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('pending').add({
        'nom': lastName,
        'prenom': firstName,
        'email': email,
        'password': password,
        'role': _selectedRole,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Votre demande est en cours de traitement.'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WaitingPage()), // Navigate to WaitingPage
      );
    } catch (e) {
      print("Une erreur s'est produite : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur s'est produite. Veuillez réessayer."),
        ),
      );
    }
  }
}