import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (authProvider.status == AuthStatus.success) {
      _showSnackBar('Login successful!');
      await authProvider.fetchSubscriptionStatus();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        if (authProvider.isApproved) {
          context.go(RouteNames.dashboard);
        } else if (authProvider.needsSubscriptionPlan) {
          context.go(RouteNames.subscription);
        } else {
          context.go(RouteNames.approvalPending);
        }
      }
    } else if (authProvider.status == AuthStatus.error) {
      _showSnackBar(authProvider.errorMessage ?? 'Login failed');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── TOP SECTION: Background Image with Overlay ──
              _buildHeaderSection(size),

              // ── MAIN CONTENT ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    Form(
                      key: _formKey,
                      child: _buildPasswordForm(),
                    ),

                    const SizedBox(height: 24),

                    // ── PRIMARY BUTTON ──
                    _buildSignInButton(),

                    const SizedBox(height: 32),

                    // ── FOOTER ──
                    _buildFooter(),

                    const SizedBox(height: 16),

                    _buildAdminLoginLink(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // WIDGET BUILDERS
  // ────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Ambient Glow Top Right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF7A00).withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Ambient Glow Top Left
          Positioned(
            top: -50,
            left: -150,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF7A00).withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          
          Column(
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF7A00), width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/easyfit_logo.jpg',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title and subtitle
              Text(
                'Welcome Back',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your fitness journey',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        _buildInputField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF7A00)),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(
              r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildInputField(
          label: 'Password',
          controller: _passwordController,
          hint: 'Your password',
          obscureText: _obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF7A00)),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFFFF7A00),
              size: 20,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Password is required';
            if ((value?.length ?? 0) < 6)
              return 'Password must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.go(RouteNames.forgotPass),
            child: Text(
              'Forgot password?',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF7A00),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          validator: validator,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white38,
            ),
            filled: true,
            fillColor: const Color(0xFF161616), // Darker grey fill
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222222), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF222222), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF7A00), width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              disabledBackgroundColor: const Color(0xFFFF7A00).withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: authProvider.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF7A00),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.go(RouteNames.register),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLoginLink() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.go(RouteNames.adminLogin),
            icon: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFFFF7A00),
              size: 20,
            ),
            label: Text(
              'Admin Login',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF7A00),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF7A00), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
