import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Viewer',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: AppDrawer(), // <--- updated to use shared drawer
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtScreen())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/art.png', height: 150, width: double.infinity, fit: BoxFit.cover),
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: Text('Art', style: TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamesScreen())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/games.png', height: 150, width: double.infinity, fit: BoxFit.cover),
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.black45,
                    alignment: Alignment.center,
                    child: Text('Games', style: TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Login")),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
              child: Text("Don't have an account? Sign up"),
            )
          ],
        ),
      ),
    );
  }
}

// Signup Screen
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  String? error;

  Future<void> _signup() async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('profiles').doc(result.user!.uid).set({
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
        'user_id': result.user!.uid,
        'user_role': 'user',
        'created_at': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null) Text(error!, style: TextStyle(color: Colors.red)),
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _updateField(String field, String value) async {
    if (field == 'email') {
      await user!.updateEmail(value);
    } else if (field == 'password') {
      await user!.updatePassword(value);
    } else {
      await FirebaseFirestore.instance.collection('profiles').doc(user!.uid).update({field: value});
    }
    setState(() {});
  }

  void _editField(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: field)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _updateField(field, controller.text.trim());
              Navigator.pop(context);
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Scaffold(body: Center(child: Text("Not logged in")));

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('profiles').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return Center(child: Text("Profile not found."));

          final fields = [
            {'label': 'Email:', 'value': user!.email ?? '', 'field': 'email'},
            {'label': 'Password:', 'value': '••••••••', 'field': 'password'},
            {'label': 'First Name:', 'value': data['first_name'] ?? '', 'field': 'first_name'},
            {'label': 'Last Name:', 'value': data['last_name'] ?? '', 'field': 'last_name'},
            {'label': 'User Role:', 'value': data['user_role'] ?? '', 'field': ''},
            {'label': 'Join Date:', 'value': (data['created_at'] as Timestamp).toDate().toString(), 'field': ''},
          ];

          return ListView(
            padding: EdgeInsets.all(16),
            children: fields.map((item) {
              return ListTile(
                title: Text(item['label']!),
                subtitle: Text(item['value']!),
                trailing: item['field']!.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editField(item['field']!, item['value']!),
                      )
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// Art Screen with Drawer
class ArtScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Art Message Board')),
      drawer: AppDrawer(), // <--- use shared drawer here
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('msg-art')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No art messages found.'));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final data = messages[index].data() as Map<String, dynamic>;

              final title = data['title'] ?? '';
              final firstName = data['first_name'] ?? '';
              final lastName = data['last_name'] ?? '';
              final userId = data['user_id'] ?? '';
              final content = data['message_content'] ?? '';
              final timestamp = data['created_at'] as Timestamp?;
              final date = timestamp?.toDate().toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 4),
                    Text('$firstName $lastName', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(userId, style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Divider(),
                    Text(content, style: TextStyle(fontSize: 16)),
                    Divider(),
                    Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Shared Drawer Widget
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text('Navigation', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
            child: Align(alignment: Alignment.centerLeft, child: Text('Profile')),
          ),
          Divider(),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtScreen())),
            child: Align(alignment: Alignment.centerLeft, child: Text('Art')),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamesScreen())),
            child: Align(alignment: Alignment.centerLeft, child: Text('Games')),
          ),
          Divider(),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Align(alignment: Alignment.centerLeft, child: Text('Log Out')),
          ),
        ],
      ),
    );
  }
}


// Games Screen with Drawer
class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games Message Board')),
      drawer: AppDrawer(), // <--- use shared drawer here
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('msg-games')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No games messages found.'));
          }

          final messages = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final data = messages[index].data() as Map<String, dynamic>;

              final title = data['title'] ?? '';
              final firstName = data['first_name'] ?? '';
              final lastName = data['last_name'] ?? '';
              final userId = data['user_id'] ?? '';
              final content = data['message_content'] ?? '';
              final timestamp = data['created_at'] as Timestamp?;
              final date = timestamp?.toDate().toString() ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 4),
                    Text('$firstName $lastName', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(userId, style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Divider(),
                    Text(content, style: TextStyle(fontSize: 16)),
                    Divider(),
                    Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}