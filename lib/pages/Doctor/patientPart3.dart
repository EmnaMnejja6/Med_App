import 'package:flutter/material.dart';
import 'package:enis/pages/doctor/parientPart4.dart';

class AdditionalCriteriaPage extends StatefulWidget {
  final String nom;
  final String prenom;
  final String adresse;
  final DateTime? dateNaissance;
  final String poids;
  final String taille;
  final String? asaScore;
  final String? acteChirurgical;

  const AdditionalCriteriaPage({
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
  State<AdditionalCriteriaPage> createState() => _AdditionalCriteriaPageState();
}

class _AdditionalCriteriaPageState extends State<AdditionalCriteriaPage> {
  final _formKey = GlobalKey<FormState>();
  final List<String> criteria = [
    "Antécédent d'intubation difficile",
    "Dysmorphie cranio-faciale (hydrocéphalie, microcéphalie, rétrogmatisme, hypoplasie hémifaciale...)",
    "Syndrome d'apnée de sommeil, ronflement nocturne, hypertrophie amygdalienne",
    "Infection des voies aériennes en cours"
  ];
  Map<String, bool> criteriaSelected = {};

  @override
  void initState() {
    super.initState();
    for (var criterion in criteria) {
      criteriaSelected[criterion] = false;
    }
    criteriaSelected["Aucun"] = false;
    criteriaSelected["Other"] = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Induction et intubation oro-trachéale"),
        backgroundColor: Color(0xFF084cac),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...criteria.map((criterion) => CheckboxListTile(
                title: Text(criterion),
                value: criteriaSelected[criterion],
                onChanged: (bool? value) {
                  setState(() {
                    criteriaSelected[criterion] = value ?? false;
                  });
                },
              )),
              CheckboxListTile(
                title: const Text("Aucun"),
                value: criteriaSelected["Aucun"],
                onChanged: (bool? value) {
                  setState(() {
                    criteriaSelected["Aucun"] = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Other"),
                value: criteriaSelected["Other"],
                onChanged: (bool? value) {
                  setState(() {
                    criteriaSelected["Other"] = value ?? false;
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IntubationDetailsPage(
                            nom: widget.nom,
                            prenom: widget.prenom,
                            adresse: widget.adresse,
                            dateNaissance: widget.dateNaissance,
                            poids: widget.poids,
                            taille: widget.taille,
                            asaScore: widget.asaScore,
                            acteChirurgical: widget.acteChirurgical,
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
