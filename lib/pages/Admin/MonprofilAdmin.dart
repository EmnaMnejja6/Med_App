import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

String? getCurrentUserUid() {
  User? user = FirebaseAuth.instance.currentUser;
  print(user?.uid);
  return user?.uid;
}

Future<Map<String, dynamic>?> fetchAdminData(String uid) async {
  DocumentSnapshot adminData =
  await FirebaseFirestore.instance.collection('admin').doc(uid).get();

  return adminData.data() as Map<String, dynamic>?;
}

class MonprofilAdmin extends StatefulWidget {
  @override
  _MonprofilAdminState createState() => _MonprofilAdminState();
}

class _MonprofilAdminState extends State<MonprofilAdmin> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _oldPasswordController;

  String? uid;
  String? firstName = '';
  String? lastName = '';
  String? email = '';

  Future<void> updateProfile() async {
    if (uid != null) {
      await FirebaseFirestore.instance.collection('admin').doc(uid).update({
        'adresse': _addressController.text,
        'tel': _phoneNumberController.text,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    uid = getCurrentUserUid();
    _addressController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _oldPasswordController = TextEditingController();

    if (uid != null) {
      fetchAdminData(uid!).then((data) {
        if (data != null) {
          setState(() {
            firstName = data['prenom'];
            lastName = data['nom'];
            email = data['mail'];
            _addressController.text = data['addresse'] ?? '';
            _phoneNumberController.text = data['tel'] ?? '';
          });
        }
      });
    }
  }

  Future<void> updatePassword() async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        try {
          // Réauthentifier l'utilisateur
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: _oldPasswordController.text,
          );
          print('Réauthentification réussie');

          // Mettre à jour le mot de passe
          await user.updatePassword(_newPasswordController.text);

          // Mettre à jour le mot de passe dans la collection admin de Firestore
          await FirebaseFirestore.instance.collection('admin').doc(user.uid).update({
            'password': _newPasswordController.text, // Assurez-vous que ce champ existe dans Firestore et est utilisé correctement
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mot de passe mis à jour avec succès'),
            ),
          );
        } on FirebaseAuthException catch (e) {
          print('Erreur lors de la mise à jour du mot de passe : ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${e.message}'),
            ),
          );
        } catch (e) {
          print('Erreur inattendue : $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur inattendue : $e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur non trouvé'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneNumberController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text('Prénom : $firstName'),
              Text('Nom : $lastName'),
              Text('Email : $email'),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF084cac),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    updateProfile().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Données mises à jour avec succès'),
                        ),
                      );
                    });
                  }
                },
                child: Text(
                  'Mettre à jour',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.black),
              const SizedBox(height: 20),
              Text(
                'Modifier mot de passe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF084cac)
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Ancien mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF084cac),
                ),
                onPressed: () {
                  updatePassword();
                },
                child: const Text(
                  'Modifier mot de passe',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
