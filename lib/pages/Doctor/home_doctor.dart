import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfilePage.dart';
import 'PatientList.dart';
import '../home_page .dart';

class HomeDoctor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: NavbarDoctor(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.40,
                decoration: BoxDecoration(
                  color: Color(0xFF084cac),
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage("assets/images/hospital.jpg"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Bienvenu Docteur" ,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Cette étude prospective descriptive vise à prédire à l'aide de l'IA le risque d'intubation difficile chez les enfants âgés de 2 mois à 6 ans, proposés pour une intervention chirurgicale sous anesthésie générale avec intubation oro-trachéale.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 2,
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
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

class NavbarDoctor extends StatefulWidget {
  const NavbarDoctor({super.key});

  @override
  State<NavbarDoctor> createState() => _NavbarDoctorState();
}

class _NavbarDoctorState extends State<NavbarDoctor> {
  String? _name;
  String? _email;
  String? _uid; // Added this variable to store the doctor's UID

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('doctor')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _name = userDoc['prenom'] + ' ' + userDoc['nom'];
          _email = userDoc['mail'];
          _uid = uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_name ?? 'Loading...'),
            accountEmail: Text(_email ?? 'Loading...'),
            currentAccountPicture: CircleAvatar(
              child: Text(
                _name != null && _name!.isNotEmpty ? _name![0] : '', // Added null and empty check
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF084cac),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Mon profil"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MonprofilDoctor()));
            },
          ),
          ListTile(
            leading: Icon(Icons.people_alt),
            title: Text("Mes Patients"),
            onTap: () {
              if (_uid != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientListPage(doctorId: _uid!)), // Pass the UID to the Patient_List_Page
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Déconnexion"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
        ],
      ),
    );
  }
}
