import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_pdm/components/customButton.dart';
import 'package:trabalho_pdm/components/customTextfield.dart';
import 'package:trabalho_pdm/components/square_tile.dart';
import 'package:trabalho_pdm/pages/home_page.dart';
import 'package:trabalho_pdm/pages/register_page.dart';
import 'package:trabalho_pdm/service/auth_service.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void singIn() async {
      try {
        await FirebaseAuth.instance.signOut();

        await AuthService().signIn(
            email: emailController.text, password: passwordController.text);

        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            ModalRoute.withName('/home'),
          );
        }
      } catch (error) {
        ToastMessage().success(message: error.toString());
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Bem vindo de volta!',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'Nome de usuário',
                    obscureText: false,
                    required: false,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Senha',
                    obscureText: true,
                    required: false,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: MyButton(
                    onTap: singIn,
                    text: 'Entrar',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPage(),
                      ),
                    ),
                    child: Text(
                      'Entrar como paciente',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não possui conta?"),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.blue.shade400,
                            width: 1,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Text(
                          'Registre-se',
                          style: TextStyle(
                            color: Colors.blue.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
