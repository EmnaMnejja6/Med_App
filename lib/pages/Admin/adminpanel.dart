import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enis/pages/Admin/AdminManagement4Admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/Admin/MonprofilAdmin.dart';
import 'package:enis/pages/SuperAdmin&Admin/DoctorManagement.dart';
import 'package:enis/pages/SuperAdmin&Admin/PatientManagement.dart';
import '../home_page .dart';

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

class AdminPanel extends StatefulWidget {
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String adminName = "";

  String adminEmail = "";

  String? uid;

  void initState() {
    super.initState();
    uid = getCurrentUserUid();
    if (uid != null) {
      fetchAdminData(uid!).then((data) {
        if (data != null) {
          setState(() {
            adminName = data['prenom'];
            adminEmail = data['mail'];
          });
        }
      });
    }
  }

  Widget buildGridItem(String text, IconData iconData, Color backgroundColor,
      BuildContext context, Widget dest) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, PageRouteBuilder(pageBuilder: (_, __, ___) => dest));
        },
        child: Container(
          height: 100.0,
          width: 100.0,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: "montserrat",
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 5),
                Icon(
                  iconData,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin '),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(adminName),
              accountEmail: Text(adminEmail),
        currentAccountPicture: CircleAvatar(
          child: Text(
            adminName!.isNotEmpty ? adminName![0] : '',
            style: TextStyle(fontSize: 40.0),
          ),
        )),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AdminPanel()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mon Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MonprofilAdmin()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewHomePage()));
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Number of columns in the grid
        children: [
          buildGridItem("Admin", Icons.admin_panel_settings_sharp, Colors.green,
              context, ManageAdmin4Admin()),
          buildGridItem("Doctors", Icons.medical_information,
              Color.fromARGB(255, 255, 95, 20), context, ManageDoctors()),
          buildGridItem(
              "Patients", Icons.people, Colors.blue, context, ManagePatients()),
        ],
      ),
    );
  }
}
