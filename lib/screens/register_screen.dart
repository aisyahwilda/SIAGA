import 'package:flutter/material.dart';

const _registerOrange = Color(0xFFFB6C00);
const _registerRed = Color(0xFFE73F1E);
const _registerInk = Color(0xFF28231F);
const _registerMuted = Color(0xFF817970);

class RegisteredAccount {
  const RegisteredAccount({required this.email, required this.password});

  final String email;
  final String password;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Masukkan email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Format email belum benar';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Buat kata sandi';
    if (value.length < 8) return 'Gunakan minimal 8 karakter';
    return null;
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      RegisteredAccount(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      ),
    );
  }

  InputDecoration _decoration({required String hint, Widget? suffixIcon}) {
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
        borderSide: const BorderSide(color: _registerOrange, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _registerRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: _registerRed, width: 1.4),
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
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBrand(),
                          Container(height: 22),
                          _buildFormCard(),
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

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Buat akun',
              style: TextStyle(
                color: _registerInk,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(height: 6),
          const Center(
            child: Text(
              'Daftar untuk mulai menggunakan SIAGA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _registerMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          Container(height: 22),
          _fieldLabel('Email'),
          Container(height: 7),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newUsername],
            validator: _validateEmail,
            decoration: _decoration(hint: 'nama@email.com'),
          ),
          Container(height: 15),
          _fieldLabel('Kata sandi'),
          Container(height: 7),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            validator: _validatePassword,
            decoration: _decoration(
              hint: 'Minimal 8 karakter',
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
                  color: _registerMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          Container(height: 15),
          _fieldLabel('Konfirmasi kata sandi'),
          Container(height: 7),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmation,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _register(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ulangi kata sandi';
              }
              if (value != _passwordController.text) {
                return 'Kata sandi belum sama';
              }
              return null;
            },
            decoration: _decoration(
              hint: 'Masukkan ulang kata sandi',
              suffixIcon: IconButton(
                tooltip: _obscureConfirmation
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                onPressed: () => setState(
                  () => _obscureConfirmation = !_obscureConfirmation,
                ),
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _registerMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          Container(height: 21),
          Container(
            width: double.infinity,
            child: FilledButton(
              onPressed: _register,
              style: FilledButton.styleFrom(
                backgroundColor: _registerOrange,
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
              child: const Text('Daftar'),
            ),
          ),
          Container(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun?',
                  style: TextStyle(color: _registerMuted, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: _registerOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text(
                    'Masuk',
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

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _registerInk,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
