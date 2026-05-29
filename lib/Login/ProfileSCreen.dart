import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../Color/Colorclass.dart';
import '../services/LogoutServices.dart';
import '../util/widget/ThemeController.dart';
import 'LoginNardanaScreen.dart';
import 'LoginScreen.dart';

class ProfileScreen extends StatelessWidget {
  final String? user;
  final String? unit;
  final String? department;
  final String? userType;

  const ProfileScreen({
    Key? key,
    this.user,
    this.unit,
    this.department,
    this.userType,
  }) : super(key: key);


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
      // backgroundColor: const Color(0xFFEAF3FF), // Light blue background
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 10,
        title: const Text(
          "User Profile",
          style: TextStyle(fontWeight: FontWeight.bold,color: C.bg),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.palette, color: Colors.white),
            onSelected: (mode) {
              Get.find<ThemeController>().changeTheme(mode);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text("System"),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text("Light"),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text("Dark"),
              ),
            ],
          ),
        ],
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Profile Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:C.brand500,
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
                          color: Color(0xFF1E5AA8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user ?? "User Name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
        
                            Text(
                              "Unit: ${unit ?? "N/A"}",
                              style: const TextStyle(color: Colors.white),
                            ),
        
                            const SizedBox(height: 4),
        
                            Text(
                              "Department: ${department ?? "N/A"}",
                              style: const TextStyle(color: Colors.white),
                            ),
        
                            const SizedBox(height: 4),
        
                            Text(
                              "User Type: ${userType ?? "N/A"}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        
                const SizedBox(height: 30),
        
                /// 🔹 Menu Tiles
                // _buildTile(Icons.contact_phone, "Contact Us"),
                // _buildTile(Icons.description, "Terms & Conditions"),
                // _buildTile(Icons.security, "Privacy Policies"),
                // _buildTile(Icons.info_outline, "About Us"),
                const SizedBox(height: 40),
        
                /// 🔹 Logout Button
                Center(
                  child: SizedBox(
                    width: isDesktop ? 250 : 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5AA8),
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

  Widget _buildLogoutButton(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 54 : (isTablet ? 50 : 48),
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  const Text('Logout'),
                ],
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // close dialog

                    final success = await LogoutService.logout();

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );

                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logged out locally")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
        icon: Icon(
          Icons.logout_rounded,
          size: isDesktop ? 22 : (isTablet ? 20 : 18),
        ),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: isDesktop ? 17 : (isTablet ? 16 : 15),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade500),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
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
              await LogoutService.logout();
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
