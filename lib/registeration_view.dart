import 'package:firebasedemo/custom_textfield.dart';
import 'package:firebasedemo/funtions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RegisterationView extends StatelessWidget {
  const RegisterationView({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController rollNumberController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            CustomTextfield(
              hintText: "Name",
              controller: nameController,
              keyboardType: TextInputType.name,
            ),
            CustomTextfield(
              hintText: "Roll number",
              controller: rollNumberController,
              keyboardType: const TextInputType.numberWithOptions(),
            ),
            CustomTextfield(
              hintText: "email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextfield(
              obscurText: true,
              hintText: "********",
              controller: passwordController,
              keyboardType: TextInputType.text,
            ),
            ElevatedButton(
                onPressed: () async {
                  await registerUser(
                    nameController.text,
                    emailController.text.trim(),
                    passwordController.text,
                    rollNumberController.text,
                    context,
                  );
                },
                child: const Text("Register Now")),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text("Login Here."))
          ],
        ),
      ),
    );
  }
}
