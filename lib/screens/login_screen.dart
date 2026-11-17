import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'register_screen.dart';
import '../services/earthquake_service.dart';

const _loginOrange = Color(0xFFFB6C00);
const _loginRed = Color(0xFFE73F1E);
const _loginInk = Color(0xFF28231F);
const _loginMuted = Color(0xFF817970);

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.earthquakeService = const EarthquakeService(),
  });

  final EarthquakeService earthquakeService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loginError = null);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() => _loginError = error.message);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loginError = 'Terjadi kesalahan. Silakan coba lagi.';
      });
    }
  }

  Future<void> _openRegistration() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Masukkan email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Format email belum benar';
    }
    return null;
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA7A19B), fontSize: 14),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE9E6E3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFFE9E6E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _loginOrange, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _loginRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _loginRed, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBrand(),
                          Container(height: 28),
                          _buildLoginCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Image.asset(
          'assets/siaga_icon.png',
          width: 112,
          height: 112,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Masuk ke SIAGA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _loginInk,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.35,
              ),
            ),
          ),
          Container(height: 7),
          const Center(
            child: Text(
              'Pantau informasi gempa dan kesiapsiagaan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _loginMuted, fontSize: 13, height: 1.4),
            ),
          ),
          Container(height: 26),
          _buildFieldLabel('Email'),
          Container(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => setState(() => _loginError = null),
            validator: _validateEmail,
            decoration: _inputDecoration(hint: 'nama@email.com'),
          ),
          Container(height: 18),
          _buildFieldLabel('Kata sandi'),
          Container(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: (_) => setState(() => _loginError = null),
            onFieldSubmitted: (_) => _signIn(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan kata sandi';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Masukkan kata sandi',
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _loginMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          Container(height: 22),
          if (_loginError != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: _loginRed,
                    size: 17,
                  ),
                  Container(width: 8),
                  Expanded(
                    child: Text(
                      _loginError!,
                      style: const TextStyle(
                        color: _loginRed,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 12),
          ],
          Container(
            width: double.infinity,
            child: FilledButton(
              onPressed: _signIn,
              style: FilledButton.styleFrom(
                backgroundColor: _loginOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text('Masuk'),
            ),
          ),
          Container(height: 17),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Belum punya akun?',
                  style: TextStyle(color: _loginMuted, fontSize: 13),
                ),
                TextButton(
                  onPressed: _openRegistration,
                  style: TextButton.styleFrom(
                    foregroundColor: _loginOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _loginInk,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
