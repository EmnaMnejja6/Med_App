import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:enis/user_auth/firebase_implementation/firebase_auth_services.dart';

class AddDoctor extends StatefulWidget {
  const AddDoctor({super.key});

  @override
  State<AddDoctor> createState() => _AddDoctorState();
}

class _AddDoctorState extends State<AddDoctor> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedSpecialite = "churigien";
  final FirebaseAuthServices _authServices = FirebaseAuthServices();

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    mailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Ajouter un Docteur"),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nom du docteur",
                    hintText: "Entrer le nom du docteur",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: nomController,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Prenom du docteur",
                    hintText: "Entrer le prenom du docteur",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: prenomController,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: "Entrer l'email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: mailController,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mot de Passe',
                    hintText: "Entrer le mot de passe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: passwordController,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(
                      value: 'ophtalmologue',
                      child: Text("Ophtalmologue"),
                    ),
                    DropdownMenuItem(
                      value: 'churigien',
                      child: Text("Churigien"),
                    ),
                    DropdownMenuItem(
                      value: 'nephrologue',
                      child: Text("Nephrologue"),
                    ),
                    DropdownMenuItem(
                      value: 'cardiologue',
                      child: Text("Cardiologue"),
                    ),
                  ],
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialite = value!;
                    });
                  },
                  value: 'churigien',
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final nom = nomController.text;
                        final prenom = prenomController.text;
                        final mail = mailController.text;
                        final password = passwordController.text;
                        final specialite = selectedSpecialite;
                        print("$nom $prenom ");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Envoi en cours")),
                        );
                        FocusScope.of(context).requestFocus(FocusNode());
                        try {
                          // Sign up the new user with FirebaseAuth
                          User? user = await _authServices.signUpWithEmailAndPassword(
                            mail,
                            password,
                            'doctor',
                          );
                          if (user != null) {
                            // Use the user's UID as the document ID in Firestore
                            String uid = user.uid;
                            // Add the new user's data to Firestore
                            await FirebaseFirestore.instance
                                .collection('doctor')
                                .doc(uid)
                                .set({
                              'nom': nom,
                              'prenom': prenom,
                              'mail': mail,
                              'specialite': specialite,
                              'password': password,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Docteur ajouté avec succès")),
                            );
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur: $error")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Veuillez remplir tous les champs"),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Ajouter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
