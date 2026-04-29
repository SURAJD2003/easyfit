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
      
      final authProvider = context.read<AuthProvider>();
      
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (authProvider.status == AuthStatus.success) {
        _showSnackBar('Login successful!');
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          context.go(RouteNames.dashboard);
        }
      } else if (authProvider.status == AuthStatus.error) {
        _showSnackBar(authProvider.errorMessage ?? 'Login failed');
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
        content: Text(message),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ────────────────────────────────────────────────────────────────
  // WIDGET BUILDERS
  // ────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection(Size size) {
    return Stack(
      children: [
        // Background image
        Image.asset(
          'images/runner.png',
          height: size.height * 0.28,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: size.height * 0.28,
              color: const Color(0xFF1A1A1A),
            );
          },
        ),

        // Dark overlay
        Container(
          height: size.height * 0.28,
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

        // Title and subtitle
        Positioned(
          bottom: 20,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your fitness journey',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildToggleTab(
            label: 'Email & Password',
            index: 0,
            isSelected: _authMode == 0,
            onTap: () => setState(() => _authMode = 0),
          ),
          _buildToggleTab(
            label: 'OTP',
            index: 1,
            isSelected: _authMode == 1,
            onTap: () => setState(() => _authMode = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2A2A2A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFFFF7A00) : Colors.white54,
            ),
          ),
        ),
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
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: 'Password',
          controller: _passwordController,
          hint: 'Your password',
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
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
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.go(RouteNames.forgotPass),
            child: Text(
              'Forgot password?',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF7A00),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        _buildInputField(
          label: 'Email Address',
          controller: _emailController,
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(value!)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        if (_otpSent) ...[
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Enter OTP',
            controller: _otpController,
            hint: '000000',
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'OTP is required';
              if (value!.length != 6) return 'OTP must be 6 digits';
              return null;
            },
          ),
        ] else ...[
          const SizedBox(height: 16),
          _buildSendOtpButton(),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
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
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFFF7A00),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE74C3C),
                width: 1,
              ),
            ),
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
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
                    _authMode == 0 ? 'Sign In' : 'Verify OTP',
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

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleSendOtp,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFFFF7A00).withOpacity(0.7),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFF7A00)),
                ),
              )
            : Text(
                'Send OTP',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF7A00),
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => _showSnackBar('Coming soon!'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'icons/google.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_circle_outlined,
                  size: 20,
                  color: Colors.white70,
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
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
}