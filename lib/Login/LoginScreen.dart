// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../AdminDashBoard/DashBoard.dart';
// import '../AdminDashBoard/AsiaDashBoard/dashBoard_screen.dart';
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
//   String? _selectedUnit;
//   bool _checkingLogin = true;
//
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // _selectedUnit;
//
//     _checkLoginStatus();
//   }
//
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final token = prefs.getString('token');
//     final username = prefs.getString('username');
//     final password = prefs.getString('password'); // 🔥 important
//     final unit = prefs.getString('unit');
//     final redirect = prefs.getString('redirect');
//     final department = prefs.getString('department');
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
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
//
//           navigateByRedirect(context, response.redirect, response.department);
//           return;
//         }
//       } catch (e) {
//         debugPrint("Auto login failed: $e");
//       }
//     }
//
//     // ❌ If auto login fails → show login screen
//     setState(() {
//       _checkingLogin = false;
//     });
//   }
//   Future<void> _handleLogin() async {
//     if (_isLoading) return;
//
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();
//
//
//     if (username.isEmpty && password.isEmpty) {
//       _showSnackBar('Username and Password are required', isError: true);
//       return;
//     } else if (username.isEmpty) {
//       _showSnackBar('Username is required', isError: true);
//       return;
//     } else if (password.isEmpty) {
//       _showSnackBar('Password is required', isError: true);
//       return;
//     } else if (_selectedUnit == null) {
//       _showSnackBar('Please select a unit', isError: true);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await _loginService.adminLogin(
//         username: username,
//         password: password,
//         unit: _selectedUnit!
//       );
//       print("LOGIN RESPONSE STATUS: ${response.status}");
//       print("LOGIN USER: ${response.user}");
//       print("LOGIN DEPARTMENT: ${response.department}");
//       print("LOGIN REDIRECT: ${response.redirect}");
//       print("LOGIN UNIT: ${response.unit}");
//       if (!mounted) return;
//
//       if (response.status == 'ok') {
//         _showSnackBar(response.message ?? 'Login successful', isError: false);
//
//         if (response.unit == null || response.unit!.isEmpty) {
//           _showSnackBar('Unit not assigned to this user', isError: true);
//           return;
//         }
//
//         final backendUnits = response.unit!
//             .split(',')
//             .map((e) => e.trim().toUpperCase())
//             .toList();
//
//         if (!backendUnits.contains(_selectedUnit!.toUpperCase())) {
//           _showSnackBar(
//             'Selected unit does not match your account unit',
//             isError: true,
//           );
//           return;
//         }
//
//         await AppSession.saveLogin(
//           user: response.user,
//           department: response.department,
//           userType: response.userType,
//           unit: _selectedUnit!,
//           token: response.token,
//           redirect: response.redirect,
//           password: password,
//         );
//
//         navigateByRedirect(context, response.redirect, response.department);
//
//       } else {
//         _showSnackBar(response.message ?? 'Login failed', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Server error or invalid credentials', isError: true);
//       debugPrint('Login failed: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red[700] : Colors.green[700],
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     if (_checkingLogin) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color(0xFF0D47A1), // Deep Blue
//                 Color(0xFF64B5F6), // Blue 300
//                 // Medium Blue
//                 Color(0xFFBBDEFB), // Blue 100
//                 // Blue 200
//               ],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 38.0),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: size.height * 0.04),
//                   // Logo Section
//                   _buildLogoSection(),
//
//                   SizedBox(height: size.height * 0.04),
//
//                   // Input Fields
//                   _buildInputField(
//                     controller: _usernameController,
//                     hint: 'Enter Username',
//                     isPassword: false,
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   _buildInputField(
//                     controller: _passwordController,
//                     hint: 'Enter Password',
//                     isPassword: true,
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // Unit Dropdown (styled as input)
//                   _buildUnitDropdown(),
//
//                   const SizedBox(height: 32),
//
//                   // Login Button
//                   _buildLoginButton(),
//
//                   const SizedBox(height: 16),
//
//                   SizedBox(height: size.height * 0.08),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoSection() {
//     return Column(
//       children: [
//         // AEGIS Logo Icon
//         Container(
//           width: 120,
//           height: 120,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.15),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: CustomPaint(painter: AegisLogoPainter()),
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 24),
//
//         // // AEGIS Text
//         // const Text(
//         //   'RRG Software',
//         //   style: TextStyle(
//         //     fontSize: 32,
//         //     fontWeight: FontWeight.bold,
//         //     color: Colors.white,
//         //     letterSpacing: 2,
//         //   ),
//         // ),
//
//         // const SizedBox(height: 8),
//
//         // Subtitle
//         const Text(
//           'INVENTORY MANAGEMENT SYSTEM',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//             color: Colors.white,
//             letterSpacing: 1.5,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hint,
//     required bool isPassword,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         obscureText: isPassword ? _obscurePassword : false,
//         style: const TextStyle(fontSize: 16, color: Colors.black87),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
//           suffixIcon: isPassword
//               ? IconButton(
//                   icon: Icon(
//                     _obscurePassword
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: Colors.grey[600],
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _obscurePassword = !_obscurePassword;
//                     });
//                   },
//                 )
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 15,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUnitDropdown() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<String>(
//         value: _selectedUnit,
//         decoration: InputDecoration(
//           hintText: 'Select Unit',
//           hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 12,
//           ),
//         ),
//         style: const TextStyle(color: Colors.black87, fontSize: 16),
//         dropdownColor: Colors.white,
//         icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
//         // items: ['FIBC'].map((String value) {
//         //   items: ['DINESH-POLYFAB', 'JBL'].map((String value) {
//
//           items: ['UNIT-1'].map((String value) {
//           //   items: ['INNOWEAVE'].map((String value) {
//           // items: ['RRG SOFTWARE'].map((String value) {
//
//           // items: ['UNIT-NARDANA'].map((String value) {
//           return DropdownMenuItem<String>(value: value, child: Text(value));
//         }).toList(),
//         onChanged: (String? newValue) {
//           setState(() {
//             _selectedUnit = newValue!;
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _handleLogin,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF0D47A1), // Dark Navy Blue
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           elevation: 4,
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 height: 24,
//                 width: 24,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : const Text(
//                 'LOGIN',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//       ),
//     );
//   }
//
//   //
//   // Widget _buildRRGLogo() {
//   //   final size = MediaQuery.of(context).size;
//   //   final isTablet = size.width > 600;
//   //
//   //   return Center(
//   //     child: Image.asset(
//   //       'assets/images/RRG_logo.png',
//   //       height: isTablet ? 50 : 45,
//   //       fit: BoxFit.contain,
//   //
//   //     ),
//   //   );
//   // }
// }
//
// // Custom Painter for AEGIS Logo
// class AegisLogoPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.6)
//       ..style = PaintingStyle.fill;
//
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//
//     // Draw the circular segments (like the AEGIS shield logo)
//     const segmentCount = 12;
//     const segmentAngle = (2 * 3.14159) / segmentCount;
//     const gapAngle = segmentAngle * 0.3;
//
//     for (int i = 0; i < segmentCount; i++) {
//       final startAngle = (i * segmentAngle) - (3.14159 / 2);
//       final sweepAngle = segmentAngle - gapAngle;
//
//       final path = Path();
//       path.moveTo(center.dx, center.dy);
//       path.arcTo(
//         Rect.fromCircle(center: center, radius: radius * 0.8),
//         startAngle,
//         sweepAngle,
//         false,
//       );
//       path.close();
//
//       canvas.drawPath(path, paint);
//     }
//
//     // Draw inner circle
//     final innerPaint = Paint()
//       ..color = Colors.white.withOpacity(0.2)
//       ..style = PaintingStyle.fill;
//
//     canvas.drawCircle(center, radius * 0.35, innerPaint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
