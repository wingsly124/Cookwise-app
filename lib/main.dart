import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

void main() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  runApp(const CookwiseApp());
}

class CookwiseApp extends StatelessWidget {
  const CookwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookwise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoginMode = true;
  bool _isPhoneMode = false;
  
  bool get _isPasswordStrong {
    final password = _passwordController.text;
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$').hasMatch(password);
  }
  
  bool get _isEmailValid {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim());
  }
  
  bool get _isPhoneValid {
    return RegExp(r'^[0-9]{11}$').hasMatch(_phoneController.text.trim());
  }
  
  String _generateRandomNickname() {
    const adjectives = ['Happy', 'Brave', 'Calm', 'Gentle', 'Mighty', 'Proud', 'Quiet'];
    const nouns = ['Lion', 'Eagle', 'Tiger', 'Bear', 'Wolf', 'Falcon', 'Panther'];
    final random = Random();
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final noun = nouns[random.nextInt(nouns.length)];
    final number = random.nextInt(999) + 1;
    return '${adjective}_$noun$number';
  }
  
  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        // Temporarily hide phone login, keep email/password login only
        // if (_isPhoneMode) {
        //   await Supabase.instance.client.auth.signInWithPhone(
        //     phone: _phoneController.text.trim(),
        //     token: _codeController.text.trim(),
        //   );
        // } else {
          await Supabase.instance.client.auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        // }
      } else {
        String nickname = _nicknameController.text.trim();
        if (nickname.isEmpty) {
          nickname = _generateRandomNickname();
        }
        // Temporarily hide phone registration, keep email registration only
        // if (_isPhoneMode) {
        //   await Supabase.instance.client.auth.signInWithPhone(
        //     phone: _phoneController.text.trim(),
        //     token: _codeController.text.trim(),
        //   );
        // } else {
          await Supabase.instance.client.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            data: {'nickname': nickname},
          );
        // }
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _emailController.clear();
      _passwordController.clear();
      _nicknameController.clear();
      _phoneController.clear();
      _codeController.clear();
    });
  }
  
  void _toggleAuthType() {
    setState(() {
      _isPhoneMode = !_isPhoneMode;
      _emailController.clear();
      _phoneController.clear();
      _codeController.clear();
      _passwordController.clear();
      _nicknameController.clear();
    });
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Login' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isLoginMode && !_isPhoneMode)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(labelText: 'Nickname (Optional)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          _nicknameController.text = _generateRandomNickname();
                        });
                      },
                      icon: const Icon(Icons.casino),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: _toggleAuthType, child: const Text('Email'))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton(onPressed: _toggleAuthType, child: const Text('Phone'))),
                ],
              ),
              const SizedBox(height: 24),
              if (_isPhoneMode) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Verification Code'),
                ),
              ] else ...[
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: _isPasswordStrong
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _passwordController.text.isEmpty
                        ? 'Minimum 8 chars, upper/lower case & numbers required.'
                        : _isPasswordStrong
                            ? 'Password is strong.'
                            : 'Weak password. Follow the rules above.',
                    style: TextStyle(color: _isPasswordStrong ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ],
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (!_isLoginMode && !_isPhoneMode) {
                    if (!_isEmailValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid email format')),
                      );
                      return;
                    }
                    if (!_isPasswordStrong) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password is too weak')),
                      );
                      return;
                    }
                  } else if (!_isLoginMode && _isPhoneMode) {
                    if (!_isPhoneValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid phone number (11 digits)')),
                      );
                      return;
                    }
                  }
                  _handleAuth();
                },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isLoginMode ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLoginMode
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookwise Home'),
        actions: [
          IconButton(onPressed: () => _signOut(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Cookwise!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
