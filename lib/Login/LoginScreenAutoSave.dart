//
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../routes/redirectRoutes.dart';
// import '../services/getSupervisors/getSupervisors.dart';
// import '../util/sharedpreference/shared_preference.dart';
// import 'LoginModel.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final InStockService _loginService = InStockService();
//
//   String? _selectedUnit;
//   bool _checkingLogin = true;
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   // ✅ AUTO LOGIN
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final username = prefs.getString('username');
//     final password = prefs.getString('password');
//     final unit = prefs.getString('unit');
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     // Restore UI
//     if (username != null || unit != null) {
//       setState(() {
//         _usernameController.text = username ?? '';
//         _passwordController.text = password ?? '';
//         _selectedUnit = unit;
//       });
//     }
//
//     if (isLoggedIn && username != null && password != null && unit != null) {
//       try {
//         final response = await _loginService.adminLogin(
//           username: username,
//           password: password,
//           unit: unit,
//         );
//
//         if (response.status == 'ok') {
//           if (!mounted) return;
//           navigateByRedirect(context, response.redirect, response.department);
//           return;
//         }
//       } catch (e) {
//         debugPrint("Auto login failed: $e");
//       }
//     }
//
//     setState(() {
//       _checkingLogin = false;
//     });
//   }
//
//   // ✅ LOGIN BUTTON
//   Future<void> _handleLogin() async {
//     if (_isLoading) return;
//
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();
//
//     if (username.isEmpty || password.isEmpty || _selectedUnit == null) {
//       _showSnackBar('All fields are required', isError: true);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await _loginService.adminLogin(
//         username: username,
//         password: password,
//         unit: _selectedUnit!,
//       );
//
//       if (!mounted) return;
//
//       if (response.status == 'ok') {
//         await AppSession.saveLogin(
//           user: username,
//           password: password,
//           department: response.department,
//           userType: response.userType,
//           unit: _selectedUnit!,
//           token: response.token,
//           redirect: response.redirect,
//         );
//
//         navigateByRedirect(context, response.redirect, response.department);
//       } else {
//         _showSnackBar('Invalid credentials', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Login failed', isError: true);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   void _showSnackBar(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_checkingLogin) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(hintText: "Username"),
//             ),
//
//             const SizedBox(height: 10),
//
//             TextField(
//               controller: _passwordController,
//               obscureText: _obscurePassword,
//               decoration: InputDecoration(
//                 hintText: "Password",
//                 suffixIcon: IconButton(
//                   icon: Icon(_obscurePassword
//                       ? Icons.visibility_off
//                       : Icons.visibility),
//                   onPressed: () {
//                     setState(() => _obscurePassword = !_obscurePassword);
//                   },
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             DropdownButtonFormField<String>(
//               value: _selectedUnit,
//               hint: const Text("Select Unit"),
//               items: ['UNIT-1'].map((e) {
//                 return DropdownMenuItem(value: e, child: Text(e));
//               }).toList(),
//               onChanged: (val) {
//                 setState(() => _selectedUnit = val);
//               },
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: _isLoading ? null : _handleLogin,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text("LOGIN"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }