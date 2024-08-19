import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/doctor/patientPart3.dart';

class AdditionalInfoPage extends StatefulWidget {
  final String nom;
  final String prenom;
  final String adresse;
  final DateTime? dateNaissance;

  const AdditionalInfoPage({
    super.key,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.dateNaissance,
  });

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final poidsController = TextEditingController();
  final tailleController = TextEditingController();
  String? asaScore;
  String? acteChirurgical;

  @override
  void dispose() {
    poidsController.dispose();
    tailleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Critères prédictifs d'intubation difficile"),
        backgroundColor: Color(0xFF084cac),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Poids (en Kg)',
                  hintText: 'Entrer le poids du patient',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tu dois remplir ce champ";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return "Le poids doit être numérique";
                  }
                  return null;
                },
                controller: poidsController,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Taille (en cm)',
                  hintText: 'Entrer la taille du patient',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tu dois remplir ce champ";
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return "La taille doit être numérique";
                  }
                  return null;
                },
                controller: tailleController,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Score ASA',
                  border: OutlineInputBorder(),
                ),
                value: asaScore,
                items: ['ASA I', 'ASA II', 'ASA III', 'ASA IV']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    asaScore = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tu dois sélectionner un score ASA";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Acte chirurgical proposé',
                  border: OutlineInputBorder(),
                ),
                value: acteChirurgical,
                items: ['Chirurgie abdominale', 'Chirurgie thoracique', 'Chirurgie autre']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    acteChirurgical = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tu dois sélectionner un acte chirurgical";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF084cac)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdditionalCriteriaPage(
                            nom: widget.nom,
                            prenom: widget.prenom,
                            adresse: widget.adresse,
                            dateNaissance: widget.dateNaissance,
                            poids: poidsController.text,
                            taille: tailleController.text,
                            asaScore: asaScore,
                            acteChirurgical: acteChirurgical,
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
