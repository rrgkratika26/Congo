

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
//
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedUnit ;
//     _loadSavedLogin();
//   }
//
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//   UserRole getUserRole(String username, String password) {
//     if (username == 'PADMIN' && password == 'PAdmin') {
//       return UserRole.padmin;
//     }
//     if (username == 'RMD' && password == 'RMD') {
//       return UserRole.rmd;
//     }
//     if (username == 'LAMINATION' && password == 'LAMINATION') {
//       return UserRole.lamination;
//     }
//     return UserRole.unknown;
//   }
//   Future<void> _loadSavedLogin() async {
//     // final prefs = await SharedPreferences.getInstance();
//
//     // final savedUsername = prefs.getString('username');
//     // final savedPassword = prefs.getString('password');
//     // final savedUnit = prefs.getString('unit');
//     // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     // if (savedUsername != null &&
//     //     savedPassword != null &&
//     //     savedUnit != null &&
//     //     isLoggedIn) {
//     //
//     //   // Auto-fill UI (optional)
//     //   _usernameController.text = savedUsername;
//     //   _passwordController.text = savedPassword;
//     //   _selectedUnit = savedUnit;
//     //
//     //   // 🔥 AUTO LOGIN API CALL
//     //   try {
//     //     final response = await _loginService.adminLogin(
//     //       username: savedUsername,
//     //       password: savedPassword,
//     //       unit: savedUnit,
//     //     );
//     //
//     //     if (response['status'] == 'ok' || response['success'] == true) {
//     //       final role = getUserRole(savedUsername, savedPassword);
//     //       await AppSession.setUserRole(role);
//     //
//     //       if (!mounted) return;
//     //
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(builder: (_) => const AdminDashboard()),
//     //       );
//     //     }
//     //   } catch (e) {
//     //     debugPrint('Auto login failed: $e');
//     //   }
//     // }
//   }
//
//
//   Future<void> _handleLogin() async {
//     if (_isLoading) return;
//
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();
//     if (_selectedUnit == null) {
//       _showSnackBar('Please select a unit', isError: true);
//       return;
//     }
//
//     if (username.isEmpty || password.isEmpty) {
//       _showSnackBar('Enter Username and Password', isError: true);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await _loginService.adminLogin(
//         username: username,
//         password: password,
//         unit:_selectedUnit!,
//         // unit: ,
//       );
//
//       debugPrint('LOGIN RESPONSE: $response');
//
//       /// ✅ BACKEND SUCCESS (adjust keys if backend differs)
//       if (response['status'] == 'ok' || response['success'] == true) {
//
//         final role = getUserRole(username, password);
//
//         if (role == UserRole.unknown) {
//           _showSnackBar('Unauthorized user', isError: true);
//           return;
//         }
//
//         final prefs = await SharedPreferences.getInstance();
//
//         await prefs.setString('username', username);
//         await prefs.setString('password', password);
//         await prefs.setString('unit', _selectedUnit!);
//         await prefs.setBool('isLoggedIn', true);
//
//         // 🔥 SAVE ROLE
//         await AppSession.setUserRole(role);
//
//         if (!mounted) return;
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const AdminDashboard()),
//         );
//       }
//
//
//       /// ❌ BACKEND VALID ERROR
//       else {
//         _showSnackBar(
//           response['message'] ?? 'Invalid credentials',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('LOGIN ERROR: $e');
//
//       if (!mounted) return;
//
//       _showSnackBar('Server error or invalid credentials', isError: true);
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
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
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF0D47A1), // Deep Blue
//               Color(0xFF64B5F6), // Blue 300
//               // Medium Blue
//               Color(0xFFBBDEFB), // Blue 100
//               // Blue 200
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 38.0),
//               child: Column(
//                 children: [
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
//                   // RRG Logo
//                   _buildRRGLogo(),
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
//             fontSize: 13,
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
//             icon: Icon(
//               _obscurePassword
//                   ? Icons.visibility_off_outlined
//                   : Icons.visibility_outlined,
//               color: Colors.grey[600],
//               size: 20,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscurePassword = !_obscurePassword;
//               });
//             },
//           )
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
//         items: ['INNOWEAVE'].map((String value) {
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
//           height: 24,
//           width: 24,
//           child: CircularProgressIndicator(
//             strokeWidth: 2.5,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : const Text(
//           'LOGIN',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.2,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRRGLogo() {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//
//     return Center(
//       child: Image.asset(
//         'assets/images/RRG_logo.png',
//         height: isTablet ? 50 : 45,
//         fit: BoxFit.contain,
//         errorBuilder: (context, error, stackTrace) {
//           return Text(
//             'RRG',
//             style: TextStyle(
//               fontSize: isTablet ? 18 : 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           );
//         },
//       ),
//     );
//   }
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
//
//





import 'dart:math' show cos, sin, pi;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AdminDashBoard/DashBoard.dart';
import '../AdminDashBoard/AsiaDashBoard/dashBoard_screen.dart';
import '../Color/Colorclass.dart';
import '../routes/redirectRoutes.dart';
import '../services/getSupervisors/getSupervisors.dart';
import '../util/sharedpreference/shared_preference.dart';
import '../util/userRole.dart';
import 'LoginModel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final InStockService _loginService = InStockService();

  String? _selectedUnit;
  bool _checkingLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _usernameFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Auth ────────────────────────────────────────────────────────────────

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    final unit = prefs.getString('unit');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && username != null && password != null && unit != null) {
      try {
        final response = await _loginService.adminLogin(
          username: username,
          password: password,
          unit: unit,
        );
        if (response.status == 'ok') {
          if (!mounted) return;
          navigateByRedirect(context, response.redirect, response.department);
          return;
        }
      } catch (e) {
        debugPrint('Auto login failed: $e');
      }
    }

    if (!mounted) return;
    setState(() => _checkingLogin = false);
    _animController.forward();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      _showSnackBar('Username and Password are required', isError: true);
      return;
    } else if (username.isEmpty) {
      _showSnackBar('Username is required', isError: true);
      return;
    } else if (password.isEmpty) {
      _showSnackBar('Password is required', isError: true);
      return;
    } else if (_selectedUnit == null) {
      _showSnackBar('Please select a unit', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _loginService.adminLogin(
        username: username,
        password: password,
        unit: _selectedUnit!,
      );

      if (!mounted) return;

      if (response.status == 'ok') {
        _showSnackBar(response.message ?? 'Login successful', isError: false);

        if (response.unit == null || response.unit!.isEmpty) {
          _showSnackBar('Unit not assigned to this user', isError: true);
          return;
        }

        final backendUnits = response.unit!
            .split(',')
            .map((e) => e.trim().toUpperCase())
            .toList();

        if (!backendUnits.contains(_selectedUnit!.toUpperCase())) {
          _showSnackBar(
            'Selected unit does not match your account unit',
            isError: true,
          );
          return;
        }

        await AppSession.saveLogin(
          user: response.user,
          department: response.department,
          userType: response.userType,
          unit: _selectedUnit!,
          token: response.token,
          redirect: response.redirect,
          password: password,
        );

        navigateByRedirect(context, response.redirect, response.department);
      } else {
        _showSnackBar(response.message ?? 'Login failed', isError: true);
      }
    } catch (e) {
      _showSnackBar('Server error or invalid credentials', isError: true);
      debugPrint('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
        isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1A3E),
        body: Center(
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2.5),
        ),
      );
    }

    // Clamp horizontal padding so it looks good on tablets too
    final double hPad =
    MediaQuery.of(context).size.width > 600 ? 80 : 28;

    return Scaffold(
      // resizeToAvoidBottomInset keeps content above the keyboard
      resizeToAvoidBottomInset: true,
      body: Container(
        // SizedBox.expand equivalent — fills whole screen including under
        // status bar / nav bar before SafeArea clips.
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Kept dark throughout so text stays readable at any screen size
            colors: [
              // Color(0xFFFFFFFF),
              // // Color(0xFF0B1A3F),
              // Color(0xFF0E2458),
              // Color(0xFF1A4A8A),
              // Color(0xFFFFFFFF),
              C.bg,
              C.primaryLight,
              C.appBar2,
              C.appBar4
            ],
            stops: [0.0, 0.30, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative orbs (clipped so they never overflow) ──────────
            _buildOrb(top: -80,   right: -60,  size: 280,
          color: const Color(0x55FDD835), ),
            _buildOrb(bottom: 80, left: -50,   size: 200,
                color: const Color(0x45FBC02D),),
            _buildOrb(top: 220,   left: -30,   size: 140,
                color: const Color(0x30FFF176)),

            // ── Main scrollable content ───────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          // Ensure content fills at least the visible height
                          // so the logo+form sit nicely even on tall screens
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),
                                _buildLogoSection(),
                                const SizedBox(height: 36),
                                _buildUsernameField(),
                                const SizedBox(height: 14),
                                _buildPasswordField(),
                                const SizedBox(height: 14),
                                _buildUnitDropdown(),
                                const SizedBox(height: 10),
                                _buildDivider(),
                                const SizedBox(height: 10),
                                _buildLoginButton(),
                                // Push footer to bottom on tall screens
                                const SizedBox(height: 8),


                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _buildOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration:
          BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Outer ring
        Container(
          width: 150,
          height: 150,
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   color: Colors.transparent,
          //   border: Border.all(
          //     color: Colors.white.withOpacity(0.15),
          //     width: 1.5,
          //   ),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.25),
          //       blurRadius: 20,
          //       spreadRadius: 2,
          //     ),
          //   ],
          // ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/CongoLogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MULTI PACKAGING CONGO',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: C.actionOrange,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: 13,
            color: C.primaryColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    final bool isFocused = _usernameFocus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Username'),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isFocused
                ? C.textHigh
                : Colors.white.withOpacity(0.07),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF93C5FD).withOpacity(0.6)
                  : Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.person_outline_rounded,
                size: 19,
                color: isFocused
                    ? C.primaryLight
                    : Colors.white.withOpacity(0.35),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  style: const TextStyle(
                      fontSize: 15,
                      color: C.primaryblue,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: 'Enter username',
                    hintStyle: TextStyle(
                        color: C.textHigh,
                        fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final bool isFocused = _passwordFocus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Password'),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isFocused
                ? Colors.blue.withOpacity(0.12)
                : Colors.white.withOpacity(0.07),
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF93C5FD).withOpacity(0.6)
                  : Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.lock_outline_rounded,
                size: 19,
                color: isFocused
                    ? C.textHigh
                    : Colors.white.withOpacity(0.35),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                      fontSize: 15,
                      color: C.textHigh,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(
                        color: C.primaryblue,
                        fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 19,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Unit'),
        const SizedBox(height: 7),
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(
                color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              dropdownColor: const Color(0xFF0D2152),
              borderRadius: BorderRadius.circular(12),
              icon: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: C.bg, size: 22),
              ),
              hint: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    Icon(Icons.business_outlined,
                        size: 19,
                        color: C.primaryblue),
                    const SizedBox(width: 10),
                    Text('Select unit',
                        style: TextStyle(
                            color: C.primaryblue,
                            fontSize: 15)),
                  ],
                ),
              ),
                  // items: ['UNIT-CONGO'].map((String value) {

              items: ['UNIT-NARDANA'].map((String value) {
              // items: ['UNIT-SILVASSA'].map((String value) {
                // items: ['FIBC'].map((String value) {
              //   items: ['DINESH-POLYFAB', 'JBL'].map((String value) {

              // items: ['UNIT-1'].map((String value) {
              //   items: ['INNOWEAVE'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        Icon(Icons.business_outlined,
                            size: 19,
                            color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 10),
                        Text(value,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFF93C5FD)
                                    .withOpacity(0.4)),
                          ),
                          child: const Text('Active',
                              style: TextStyle(
                                  color: Color(0xFF93C5FD),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) =>
                  setState(() => _selectedUnit = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: C.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider() => Divider(
      color: Colors.white.withOpacity(0.08), thickness: 1, height: 1);

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          // Uses your C.bg colour; falls back gracefully if null
          backgroundColor: C.appBar4,
          disabledBackgroundColor: C.bg.withOpacity(0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Sign In',
              style: TextStyle(
                color: C.actionOrange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded,
                size: 18, color: C.actionOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Developed By Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Developed by ',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),

            SizedBox(
              height: 35,
              child: Image.asset(
                'assets/images/RRG_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    'RRG SOFTWARE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // const SizedBox(height: 8),
        //
        // // Existing Footer Row
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Icon(Icons.lock_outline, size: 12, color: C.warning),
        //
        //     const SizedBox(width: 6),
        //
        //     Text(
        //       'SECURE LOGIN',
        //       style: TextStyle(
        //         fontSize: 10,
        //         color: C.warning,
        //         letterSpacing: 2,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //
        //     Container(
        //       width: 3,
        //       height: 3,
        //       margin: const EdgeInsets.symmetric(horizontal: 8),
        //       decoration: BoxDecoration(
        //         color: C.warning,
        //         shape: BoxShape.circle,
        //       ),
        //     ),
        //
        //     Text(
        //       'v2.4.1',
        //       style: TextStyle(
        //         fontSize: 10,
        //         color: C.warning,
        //         letterSpacing: 1.5,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

