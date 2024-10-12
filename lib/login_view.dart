import 'package:firebasedemo/custom_textfield.dart';
import 'package:firebasedemo/funtions.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            CustomTextfield(
              hintText: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextfield(
              hintText: "******",
              controller: passwordController,
              obscurText: true,
            ),
            ElevatedButton(
                onPressed: () {
                  loginWithEmail(
                    emailController.text.trim(),
                    passwordController.text,
                  );
                },
                child: const Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Register Here"),
            ),
          ],
        ),
      ),
    );
  }
}
