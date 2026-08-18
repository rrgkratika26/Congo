import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Color/Colorclass.dart';
import '../util/sharedpreference/shared_preference.dart';
import 'LoginNardanaScreen.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? unitName;
  String? departmentName;
  String? userTypeName;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final loadedUser = await AppSession.getUserType();
      final loadedUnit = await AppSession.getUnit();
      final loadedDept = await AppSession.getDepartment();
      final loadedUserType = await AppSession.getUserType();

      if (!mounted) return;

      setState(() {
        userName = loadedUser;
        unitName = loadedUnit;
        departmentName = loadedDept;
        userTypeName = loadedUserType;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Profile load error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1000;

    final horizontalPadding = isDesktop
        ? size.width * 0.25
        : isTablet
        ? 40.0
        : 20.0;

    return Scaffold(
      backgroundColor: C.brand50,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: C.appBar3))
            : SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 54,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: C.primaryblue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: C.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? "User Name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: C.bg,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              "Unit: ${unitName ?? 'N/A'}",
                              style: const TextStyle(color: C.bg),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Department: ${departmentName ?? 'N/A'}",
                              style: const TextStyle(color: C.bg),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "User Type: ${userTypeName ?? 'N/A'}",
                              style: const TextStyle(color: C.bg),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                const SizedBox(height: 80),

                /// 🔹 Logout Button
                Center(
                  child: SizedBox(
                    width: isDesktop ? 250 : 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await InStockService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}