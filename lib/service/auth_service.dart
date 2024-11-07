import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:postgres/postgres.dart';
import 'package:trabalho_pdm/models/user_model.dart';
import 'package:trabalho_pdm/service/postgres_service.dart';
import 'package:trabalho_pdm/utils/toastMessages.dart';

class AuthService {
  Connection? conn;

  Future<void> _registerUserInPostgres(Connection conn, UserModel user) async {
    await conn.execute(
      Sql.named(
          "INSERT INTO tb_user (name, email, password, firebase_id) VALUES (@name, @password,  @email, @firebase_id)"),
      parameters: {
        "name": user.name,
        "email": user.email,
        "firebase_id": user.firebase_id,
        "password": user.password
      },
    );
  }

  Future<UserModel?> getUser() async {
    try {
      conn ??= await PostgresService().openConnection();
      UserModel? user;

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        Result? query = await conn?.execute(
          Sql.named(
              "SELECT * FROM tb_user u WHERE u.firebase_id = @firebase_id"),
          parameters: {"firebase_id": currentUser.uid},
        );

        if (query != null) {
          user = UserModel(
            name: query.first.toColumnMap()['name'],
            email: query.first.toColumnMap()['email'],
            password: query.first.toColumnMap()['password'],
            id: query.first.toColumnMap()['id'],
          );
        }
      }

      return user;
    } finally {
      conn?.close();
    }
  }

  Future<void> signUp(UserModel user) async {
    try {
      conn ??= await PostgresService().openConnection();

      if (user.email.trim().isEmpty ||
          user.name.trim().isEmpty ||
          user.password.trim().isEmpty ||
          (user.rePassword != null && user.rePassword!.isEmpty)) {
        throw ErrorDescription('Campos obrigatórios não preenchidos!');
      }

      if (user.password != user.rePassword) {
        throw ErrorDescription('As senhas devem ser iguais!');
      }

      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (userCredential.user?.uid != null) {
        user.firebase_id = userCredential.user!.uid;

        await _registerUserInPostgres(conn!, user);
      }
    } on FirebaseAuthException catch (e) {
      String message =
          'Ocorreu um problema! por favor tenta novamente mais tarde.';
      if (e.code == 'weak-password') {
        message = "A senha é fraca de mais. tente outra por favor!";
      } else if (e.code == 'email-already-in-use') {
        message = "Já existe uma conta com esse email";
      }
      throw ErrorDescription(message);
    } catch (e) {
      throw ErrorDescription(e.toString());
    } finally {
      await conn?.close();
    }
  }

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredentials;
    } on FirebaseAuthException catch (e) {
      String message =
          'Ocorreu um problema! por favor tenta novamente mais tarde.';

      if (e.code == 'user-not-found' || e.code == 'wrong password') {
        message = "Conta não encontrada! Verifique o Email e a Senha.";
      }

      throw ErrorDescription(message);
    }
  }
}
