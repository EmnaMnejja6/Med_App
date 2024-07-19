import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({super.key});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final adresseController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? dateNaissance;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ajouter un patient"),
          backgroundColor: Colors.blue,
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nom du Patient',
                    hintText: 'Entrer le nom du patient',
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Prenom du Patient',
                    hintText: 'Entrer le prénom du patient',
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    hintText: "Entrer l'adresse",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    return null;
                  },
                  controller: adresseController,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: "Entrer le numéro de téléphone",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tu dois remplir ce champ";
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return "Le numéro de téléphone doit être numérique";
                    }
                    return null;
                  },
                  controller: phoneController,
                ),
                const SizedBox(height: 10),
                DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: 'Date de Naissance',
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
                const SizedBox(height: 10),
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
                        final adresse = adresseController.text;
                        final phone = phoneController.text;

                        print("$nom $prenom $adresse $phone");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Envoi en cours")),
                        );
                        FocusScope.of(context).requestFocus(FocusNode());

                        CollectionReference patientsRef =
                        FirebaseFirestore.instance.collection("patients");
                        patientsRef.add({
                          'Nom': nom,
                          'Prenom': prenom,
                          'Adresse': adresse,
                          'tel': phone,
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
                    child: const Text(
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
