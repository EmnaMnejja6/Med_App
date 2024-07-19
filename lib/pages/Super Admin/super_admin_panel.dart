import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/Super%20Admin/AdminManagement4SuperAdmin.dart';
import 'package:enis/pages/Super%20Admin/SuperAdminManagment.dart';
import 'package:enis/pages/SuperAdmin&Admin/DoctorManagement.dart';
import 'package:enis/pages/SuperAdmin&Admin/PatientManagement.dart';
import 'package:enis/pages/home_page%20.dart';
import 'package:enis/pages/Super%20Admin/MonProfilSuperAdmin.dart';

String? getCurrentUserUid() {
  User? user = FirebaseAuth.instance.currentUser;
  print('Current user UID: ${user?.uid}');
  return user?.uid;
}

Future<Map<String, dynamic>?> fetchSuperAdminData(String uid) async {
  try {
    DocumentSnapshot superadminData = await FirebaseFirestore.instance
        .collection('superadmin')
        .doc(uid)
        .get();
    if (superadminData.exists) {
      print('Superadmin data found: ${superadminData.data()}');
      return superadminData.data() as Map<String, dynamic>?;
    } else {
      print('No superadmin data found for UID: $uid');
      return null;
    }
  } catch (e) {
    print('Error fetching superadmin data: $e');
    return null;
  }
}

class SuperAdminPanel extends StatefulWidget {
  @override
  State<SuperAdminPanel> createState() => _SuperAdminPanelState();
}

class _SuperAdminPanelState extends State<SuperAdminPanel> {
  String superadminName = "";
  String superadminEmail = "";
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = getCurrentUserUid();
    if (uid != null) {
      fetchSuperAdminData(uid!).then((data) {
        if (data != null) {
          setState(() {
            superadminName = data['prenom'] ?? 'No Name';
            superadminEmail = data['mail'] ?? 'No Email';
          });
        } else {
          print('Data is null for UID: $uid');
        }
      });
    } else {
      print('UID is null');
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
                )
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(superadminName),
              accountEmail: Text(superadminEmail),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  superadminName!.isNotEmpty ? superadminName![0] : '',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SuperAdminPanel()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Mon Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MonprofilSuperAdmin()));
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("SuperAdminPanel"),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Number of columns in the grid
        children: [
          buildGridItem("Super Admin", Icons.admin_panel_settings,
              Color.fromARGB(255, 255, 17, 176), context, ManageSuperAdmin()),
          buildGridItem("Admin", Icons.admin_panel_settings_sharp, Colors.green,
              context, ManageAdmin4SuperAdmin()),
          buildGridItem("Doctors", Icons.medical_information,
              Color.fromARGB(255, 255, 95, 20), context, ManageDoctors()),
          buildGridItem(
              "Patients", Icons.people, Colors.blue, context, ManagePatients()),
        ],
      ),
    );
  }
}
