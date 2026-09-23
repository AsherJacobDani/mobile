import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../home/home_screen.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> login() async {

    setState(() {
      isLoading = true;
    });

    try {

      print("LOGIN BUTTON CLICKED");

      final response =
          await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      print(
          "RESPONSE = $response");

      if (response["success"] ==
          true) {

        await StorageService
            .saveToken(
          response["access_token"],
        );

        final token =
            await StorageService
                .getToken();

        print(
            "TOKEN = $token");

        if (mounted) {

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Login Success",
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const HomeScreen(),
            ),
          );
        }

      } else {

        if (mounted) {
          ScaffoldMessenger.of(
                  context)
              .showSnackBar(
            SnackBar(
              content: Text(
                response["message"] ??
                    "Login Failed",
              ),
            ),
          );
        }
      }

    } catch (e) {

      print("ERROR = $e");

      if (mounted) {
        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "ERROR = $e",
            ),
          ),
        );
      }

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("InstaAI Login"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            TextField(
              controller:
                  emailController,

              keyboardType:
                  TextInputType
                      .emailAddress,

              decoration:
                  const InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText: "Password",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : login,

                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Login",
                      ),
              ),
            ),
            const SizedBox(height: 20),

            TextButton(

             onPressed: () {

             Navigator.push(
              context,
              MaterialPageRoute(
               builder: (context) =>
               const RegisterScreen(),
              ),
             );

            },

            child: const Text(
             "Create New Account",
            ),
            ),
          ],
        ),
      ),
    );
  }
}