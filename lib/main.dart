import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// Main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      debugShowCheckedModeBanner: false,
      home: LoginRegisterScreen(),
    );
  }
}

// Combined Register and Login Screen
class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Signed out successfully'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Auth")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RegisterSection(auth: _auth),
            Divider(),
            LoginSection(auth: _auth),
          ],
        ),
      ),
    );
  }
}

// Registration Widget
class RegisterSection extends StatefulWidget {
  final FirebaseAuth auth;
  RegisterSection({required this.auth});

  @override
  _RegisterSectionState createState() => _RegisterSectionState();
}

class _RegisterSectionState extends State<RegisterSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _status;

  void _register() async {
    try {
      await widget.auth.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      setState(() {
        _status = "Successfully registered: ${_email.text}";
      });
    } catch (e) {
      setState(() {
        _status = "Registration failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Register", style: Theme.of(context).textTheme.headline6),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
            ),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) =>
                  value!.length < 6 ? 'Password must be ≥ 6 characters' : null,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) _register();
              },
              child: Text("Register"),
            ),
            if (_status != null) Text(_status!, style: TextStyle(color: Colors.green)),
          ]),
        ),
      ],
    );
  }
}

// Login Widget
class LoginSection extends StatefulWidget {
  final FirebaseAuth auth;
  LoginSection({required this.auth});

  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _status;

  void _signIn() async {
    try {
      await widget.auth.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    } catch (e) {
      setState(() {
        _status = "Sign in failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Login", style: Theme.of(context).textTheme.headline6),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
            ),
            TextFormField(
              controller: _password,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) =>
                  value!.length < 6 ? 'Password must be ≥ 6 characters' : null,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) _signIn();
              },
              child: Text("Login"),
            ),
            if (_status != null) Text(_status!, style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }
}

// Profile Screen after Login
class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginRegisterScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? Center(child: Text("No user found"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome!", style: Theme.of(context).textTheme.headline5),
                  SizedBox(height: 10),
                  Text("Email: ${user.email}"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
                    },
                    child: Text("Change Password"),
                  ),
                ],
              ),
      ),
    );
  }
}

// Change Password Screen
class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _message;

  void _changePassword() async {
    try {
      await _auth.currentUser!.updatePassword(_password.text);
      setState(() {
        _message = "Password changed successfully!";
      });
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _password,
            decoration: InputDecoration(labelText: "New Password"),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _changePassword,
            child: Text("Update"),
          ),
          if (_message != null) Text(_message!),
        ]),
      ),
    );
  }
}
