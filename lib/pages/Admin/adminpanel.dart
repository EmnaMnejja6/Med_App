import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enis/pages/Admin/AdminManagement4Admin.dart';
import 'package:enis/pages/Admin/ApprovalRequestPage4Admin.dart';
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
        backgroundColor: Color(0xFF084cac),
        title: Text("AdminPanel"),
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
              leading: Icon(Icons.dashboard),
              title: Text('Approval Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CombinedRequestsPage4Admin()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          ],
        ),
      ),
 
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust grid item size based on screen width
          double itemSize = constraints.maxWidth / 4 - 16; // 4 items per row with margin
          return GridView.count(
            crossAxisCount: (constraints.maxWidth < 600) ? 2 : 4, // Adjust crossAxisCount based on screen width
            childAspectRatio: (constraints.maxWidth < 600) ? 1 : 1.2, // Adjust aspect ratio for responsiveness
            children: [
              buildGridItem("Doctors", Icons.medical_information,
                  Color(0xffea8707), context, ManageDoctors()),
              buildGridItem(
                  "Patients", Icons.people, Color(
                  0xff07d140), context, ManagePatients()),
            ],
          );
        },
      ),
    );
  }
}

