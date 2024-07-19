import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/widgets.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final ageController = TextEditingController();
  DateTime? dateNaissance;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Ajouter un patient"),
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
                    labelText: 'Nom du Patient',
                    hintText: 'Entrer le nom du patient',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce texte";
                    }
                    return null;
                  },
                  controller: nomController,
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Prenom du Patient',
                    hintText: 'Entrer le prenom du patient',
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
                    labelText: 'Age',
                    hintText: "Entrer l'age",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: ageController,
                ),
                SizedBox(height: 10),
                DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date Naissance',
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  onDateSelected: (DateTime? value) {
                    dateNaissance = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Tu dois sélectionner une date";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final nom = nomController.text;
                        final prenom = prenomController.text;
                        final age = ageController.text;
                        print("$nom $prenom $age");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Envoi en cours")),
                        );
                        FocusScope.of(context).requestFocus(FocusNode());

                        CollectionReference patientsRef =
                            FirebaseFirestore.instance.collection("patients");
                        patientsRef.add({
                          'Nom': nom,
                          'Prenom': prenom,
                          'Age': age,
                          'DateNais': dateNaissance != null
                              ? Timestamp.fromDate(dateNaissance!)
                              : null,
                          'avatar': nom + prenom
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Patient ajouté avec succès")),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur: $error")),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Veuillez remplir tous les champs")),
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
