import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:enis/pages/doctor/patientPart2.dart';
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
  DateTime? dateNaissance;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un patient "),
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
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdditionalInfoPage(
                            nom: nomController.text,
                            prenom: prenomController.text,
                            adresse: adresseController.text,
                            dateNaissance: dateNaissance,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez remplir tous les champs")),
                      );
                    }
                  },
                  child: const Text(
                    "Suivant",
                    style: TextStyle(color: Colors.white),
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
