import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  int _authMode = 0; // 0 = Email/Password, 1 = Email OTP
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_authMode == 0) {
      // Email/Password login
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(RouteNames.dashboard);
      }
    } else {
      // OTP login
      if (_otpController.text.isEmpty) {
        _showSnackBar('Please enter OTP');
        return;
      }
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(RouteNames.dashboard);
      }
    }
  }

  void _handleSendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
      _showSnackBar('OTP sent to your email');
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
    final padding = MediaQuery.of(context).padding;

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

                    // ── AUTH MODE TOGGLE ──
                    _buildAuthToggle(),

                    const SizedBox(height: 32),

                    // ── FORM ──
                    Form(
                      key: _formKey,
                      child: _authMode == 0
                          ? _buildPasswordForm()
                          : _buildOtpForm(),
                    ),

                    const SizedBox(height: 24),

                    // ── PRIMARY BUTTON ──
                    _buildSignInButton(),

                    const SizedBox(height: 28),

                    // ── DIVIDER ──
                    _buildDivider(),

                    const SizedBox(height: 20),

                    // ── SOCIAL LOGIN ──
                    _buildSocialButton(),

                    const SizedBox(height: 32),

                    // ── FOOTER ──
                    _buildFooter(),

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

  // ── HEADER SECTION ──
  Widget _buildHeaderSection(Size size) {
    return Stack(
      children: [
        // Background image
        Container(
          width: size.width,
          height: 220,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/runner.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),

        // Gradient overlay
        Container(
          width: size.width,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0D0D0D).withOpacity(0.3),
                const Color(0xFF0D0D0D).withOpacity(0.8),
              ],
            ),
          ),
        ),

        // Text content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your fitness journey',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── AUTH MODE TOGGLE ──
  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildToggleTab(
            label: 'Email & Password',
            index: 0,
            isActive: _authMode == 0,
            onTap: () => setState(() {
              _authMode = 0;
              _otpSent = false;
            }),
          ),
          _buildToggleTab(
            label: 'Email OTP',
            index: 1,
            isActive: _authMode == 1,
            onTap: () => setState(() => _authMode = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive ? const Color(0xFFFF7A00) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.white60,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── PASSWORD FORM ──
  Widget _buildPasswordForm() {
    return Column(
      children: [
        // Email field
        _buildInputField(
          controller: _emailController,
          hint: 'Email Address',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password field
        _buildInputField(
          controller: _passwordController,
          hint: 'Password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white54,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Password is required';
            if ((value?.length ?? 0) < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              // Handle forgot password
            },
            child: Text(
              'Forgot Password?',
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

  // ── OTP FORM ──
  Widget _buildOtpForm() {
    return Column(
      children: [
        // Email field
        _buildInputField(
          controller: _emailController,
          hint: 'Email Address',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          enabled: !_otpSent,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),

        if (_otpSent) ...[
          const SizedBox(height: 16),

          // OTP field
          _buildInputField(
            controller: _otpController,
            hint: 'Enter OTP (6 digits)',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'OTP is required';
              if (value!.length != 6) return 'OTP must be 6 digits';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Resend OTP
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() => _otpSent = false);
                _otpController.clear();
              },
              child: Text(
                'Change Email',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFF7A00),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── INPUT FIELD WIDGET ──
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool enabled = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLength: maxLength,
      validator: validator,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white54,
          size: 20,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFFF7A00),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        counterText: '',
      ),
    );
  }

  // ── SIGN IN BUTTON ──
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: const Color(0xFFFF7A00),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7A00).withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    )
                  : Text(
                      _authMode == 0
                          ? 'Sign In'
                          : _otpSent
                              ? 'Verify OTP'
                              : 'Send OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── DIVIDER ──
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
        ),
      ],
    );
  }

  // ── SOCIAL LOGIN BUTTON ──
  Widget _buildSocialButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle Google login
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
              color: const Color(0xFF1A1A1A),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/google.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.mail_outline_rounded,
                      color: Colors.white70,
                      size: 20,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── FOOTER ──
  Widget _buildFooter() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Don't have an account? ",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 0.3,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF7A00),
                letterSpacing: 0.3,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Navigate to signup
                },
            ),
          ],
        ),
      ),
    );
  }
}
