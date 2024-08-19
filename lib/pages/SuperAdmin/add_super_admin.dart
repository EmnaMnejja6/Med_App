import 'package:flutter/material.dart';
import 'package:enis/user_auth/firebase_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSuperAdmin extends StatefulWidget {
  const AddSuperAdmin({super.key});

  @override
  State<AddSuperAdmin> createState() => _AddSuperAdminState();
}

class _AddSuperAdminState extends State<AddSuperAdmin> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
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
          title: Text("Ajouter un Super Admin"),
          backgroundColor: Color(0xFF084cac),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Nom du Super Admin",
                    hintText: "Entrer le nom du Super Admin",
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
                    labelText: "Prenom du Super Admin",
                    hintText: "Entrer le prenom du Super Admin",
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF084cac)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final nom = nomController.text;
                        final prenom = prenomController.text;
                        final mail = mailController.text;
                        final password = passwordController.text;
                        print("$nom $prenom ");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Envoi en cours")),
                        );
                        FocusScope.of(context).requestFocus(FocusNode());
                        try {
                          // Sign up the new user in auth
                          User? user = await _authServices.signUpWithEmailAndPassword(
                              mail, password, 'super_admin', nom, prenom);
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Super Admin ajouté avec succès")),
                            );
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur: $error")),
                          );
                          print("Erreur d'ajout du superadmin: $error");
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Veuillez remplir tous les champs")),
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
