import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enis/pages/SuperAdmin/ApprovalRequestPage4SuperAdmin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:enis/pages/SuperAdmin/SuperAdminManagment.dart';
import 'package:enis/pages/SuperAdmin&Admin/DoctorManagement.dart';
import 'package:enis/pages/SuperAdmin&Admin/PatientManagement.dart';
import 'package:enis/pages/SuperAdmin/AdminManagement4SuperAdmin.dart';
import 'package:enis/pages/SuperAdmin/MonProfilSuperAdmin.dart';
import 'package:enis/pages/SuperAdmin/ApprovalRequest.dart';

import '../home_page .dart';

String? getCurrentUserUid() {
  User? user = FirebaseAuth.instance.currentUser;
  print('Utilisateur courrant : UID: ${user?.uid}');
  return user?.uid;
}

Future<Map<String, dynamic>?> fetchSuperAdminData(String uid) async {
  try {
    DocumentSnapshot superadminData = await FirebaseFirestore.instance
        .collection('superadmin')
        .doc(uid)
        .get();
    if (superadminData.exists) {
      print('Superadmin data trouvé: ${superadminData.data()}');
      return superadminData.data() as Map<String, dynamic>?;
    } else {
      print('Data superadmin introuvable UID: $uid');
      return null;
    }
  } catch (e) {
    print('Erreur fetching superadmin data: $e');
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
          print('Data est null for UID: $uid');
        }
      });
    } else {
      print('UID est null');
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
                    fontFamily: "Montserrat",
                    color: Colors.white,
                    fontSize: 16, // Adjusted font size for better readability
                  ),
                ),
                SizedBox(height: 5),
                Icon(
                  iconData,
                  color: Colors.white,
                  size: 24.0, // Adjusted icon size for better fit
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(superadminName),
              accountEmail: Text(superadminEmail),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  superadminName.isNotEmpty ? superadminName[0] : '',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFF084cac),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Menu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SuperAdminPanel()));
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
              leading: Icon(Icons.approval),
              title: Text('Approval Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CombinedRequestsPage4SuperAdmin()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF084cac),
        title: Text("SuperAdminPanel"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust grid item size based on screen width
          double itemSize = constraints.maxWidth / 4 - 16; // 4 items per row with margin
          return GridView.count(
            crossAxisCount: (constraints.maxWidth < 600) ? 2 : 4, // Adjust crossAxisCount based on screen width
            childAspectRatio: (constraints.maxWidth < 600) ? 1 : 1.2, // Adjust aspect ratio for responsiveness
            children: [
              buildGridItem("Super Admin", Icons.admin_panel_settings,
                  Color(0xffe60db3), context, ManageSuperAdmin()),
              buildGridItem("Admin", Icons.admin_panel_settings_sharp, Color(
                  0xff07d140),
                  context, ManageAdmin4SuperAdmin()),
              buildGridItem("Doctors", Icons.medical_information,
                  Color(0xffea8707), context, ManageDoctors()),
              buildGridItem(
                  "Patients", Icons.people, Color(0xff08d687), context, ManagePatients()),
            ],
          );
        },
      ),
    );
  }
}
