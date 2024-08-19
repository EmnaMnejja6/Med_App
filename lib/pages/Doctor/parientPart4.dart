import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/Doctor/patientPart5.dart'; // Update import statement

class IntubationDetailsPage extends StatefulWidget {
  final String nom;
  final String prenom;
  final String adresse;
  final DateTime? dateNaissance;
  final String poids;
  final String taille;
  final String? asaScore;
  final String? acteChirurgical;

  const IntubationDetailsPage({
    super.key,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.dateNaissance,
    required this.poids,
    required this.taille,
    required this.asaScore,
    required this.acteChirurgical,
  });

  @override
  State<IntubationDetailsPage> createState() => _IntubationDetailsPageState();
}

class _IntubationDetailsPageState extends State<IntubationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  String? inductionType;
  String? intubationAttempts;
  String? alternativeTechnique;
  String? cormackLehaneGrade;
  Future<String> _getNextPatientId() async {
    final counterRef = FirebaseFirestore.instance.collection('counters').doc('patientCounter');
    final doc = await counterRef.get();

    if (doc.exists) {
      final currentId = doc.data()?['currentId'] as int? ?? 0;
      final newId = currentId + 1;

      // Update the counter in Firestore
      await counterRef.update({'currentId': newId});

      return newId.toString(); // Convert to string for use as ID
    } else {
      // If the document doesn't exist, create it with ID 1
      await counterRef.set({'currentId': 1});
      return '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Induction et intubation oro-trachéale"),
        backgroundColor: Color(0xFF084cac),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Type d'induction :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                RadioListTile<String>(
                  title: const Text("Séquence lente"),
                  value: "Séquence lente",
                  groupValue: inductionType,
                  onChanged: (value) {
                    setState(() {
                      inductionType = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Séquence rapide"),
                  value: "Séquence rapide",
                  groupValue: inductionType,
                  onChanged: (value) {
                    setState(() {
                      inductionType = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Nombre de tentatives d'intubation :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                RadioListTile<String>(
                  title: const Text("1 tentative"),
                  value: "1 tentative",
                  groupValue: intubationAttempts,
                  onChanged: (value) {
                    setState(() {
                      intubationAttempts = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("2 tentatives"),
                  value: "2 tentatives",
                  groupValue: intubationAttempts,
                  onChanged: (value) {
                    setState(() {
                      intubationAttempts = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("plus que 2 tentatives"),
                  value: "plus que 2 tentatives",
                  groupValue: intubationAttempts,
                  onChanged: (value) {
                    setState(() {
                      intubationAttempts = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Mise en oeuvre d'une technique alternative :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                RadioListTile<String>(
                  title: const Text("Oui"),
                  value: "Oui",
                  groupValue: alternativeTechnique,
                  onChanged: (value) {
                    setState(() {
                      alternativeTechnique = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Non"),
                  value: "Non",
                  groupValue: alternativeTechnique,
                  onChanged: (value) {
                    setState(() {
                      alternativeTechnique = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Classification de Cormack et Lehane :",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Image(image: AssetImage('assets/images/cormack.jpg')),
                RadioListTile<String>(
                  title: const Text("Cormack 1"),
                  value: "Cormack 1",
                  groupValue: cormackLehaneGrade,
                  onChanged: (value) {
                    setState(() {
                      cormackLehaneGrade = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Cormack 2"),
                  value: "Cormack 2",
                  groupValue: cormackLehaneGrade,
                  onChanged: (value) {
                    setState(() {
                      cormackLehaneGrade = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Cormack 3"),
                  value: "Cormack 3",
                  groupValue: cormackLehaneGrade,
                  onChanged: (value) {
                    setState(() {
                      cormackLehaneGrade = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Cormack 4"),
                  value: "Cormack 4",
                  groupValue: cormackLehaneGrade,
                  onChanged: (value) {
                    setState(() {
                      cormackLehaneGrade = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF084cac)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final doctorId = FirebaseAuth.instance.currentUser?.uid;

                        if (doctorId != null) {
                          try {
                            // Get the next patient ID
                            final patientId = await _getNextPatientId();

                            await FirebaseFirestore.instance.collection('patients').doc(patientId).set({
                              'patientNom': widget.nom,
                              'patientPrenom': widget.prenom,
                              'patientAdress': widget.adresse,
                              'DateNaissance': widget.dateNaissance != null
                                  ? Timestamp.fromDate(widget.dateNaissance!)
                                  : null,
                              'Poids': widget.poids,
                              'Taille': widget.taille,
                              'ASAScore': widget.asaScore,
                              'ActeChirurgical': widget.acteChirurgical,
                              'InductionType': inductionType,
                              'IntubationAttempts': intubationAttempts,
                              'AlternativeTechnique': alternativeTechnique,
                              'CormackLehaneGrade': cormackLehaneGrade,
                              'doctorId': doctorId,
                              'avatar': widget.nom + widget.prenom,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Patient ajouté avec succès")),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoUploadPage(
                                  doctorId: doctorId,
                                  patientId: patientId,
                                  patientNom: widget.nom,
                                  patientPrenom: widget.prenom,
                                  patientAddress: widget.adresse,
                                  patientBirthDate: widget.dateNaissance,
                                  patientWeight: widget.poids,
                                  patientHeight: widget.taille,
                                  asaScore: widget.asaScore,
                                  surgicalAct: widget.acteChirurgical,
                                ),
                              ),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Erreur: $error")),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Veuillez remplir tous les champs")),
                        );
                      }
                    }
                    ,
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
      ),
    );
  }
}
