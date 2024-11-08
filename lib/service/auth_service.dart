import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:trabalho_pdm/models/user_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:trabalho_pdm/service/mongo_service.dart';
import 'package:trabalho_pdm/service/notification_service.dart';
import 'package:trabalho_pdm/service/postgres_service.dart';

class AuthService {
  pg.Connection? conn;

  Future<void> _registerUserInPostgres(
      pg.Connection conn, UserModel user) async {
    pg.Result result = await conn.execute(
      pg.Sql.named(
          "INSERT INTO tb_user (name, email, password, firebase_id) VALUES (@name, @email, @password , @firebase_id)"),
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
        pg.Result? query = await conn?.execute(
          pg.Sql.named(
              "SELECT * FROM tb_user u WHERE u.firebase_id = @firebase_id"),
          parameters: {"firebase_id": currentUser.uid},
        );

        if (query != null) {
          Map<String, dynamic> userData = query.first.toColumnMap();

          user = UserModel(
            name: userData['name'],
            email: userData['email'],
            password: userData['password'],
            id: userData['id'],
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
      conn ??= await PostgresService().openConnection();

      UserCredential userCredentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print('uid ${userCredentials.user!.uid}');

      pg.Result? userQuery = await conn?.execute(
        pg.Sql.named(
            "SELECT * FROM tb_user u WHERE u.firebase_id = @firebase_id"),
        parameters: {"firebase_id": userCredentials.user!.uid},
      );

      print('query $userQuery');

      if (userQuery != null) {
        Map<String, dynamic> userData = userQuery.first.toColumnMap();

        UserModel user = UserModel(
          name: userData['name'],
          email: userData['email'],
          password: userData['password'],
          id: userData['id'],
          firebase_id: userData['firebase_id'],
        );

        print(user);

        String? notificationToken =
            await NotificationService().getNotificationAPI().getToken();

        print(notificationToken);

        if (notificationToken != null) {
          Db mongoDB = await MongoService.connect();

          DbCollection collection = mongoDB.collection('users_notifications');

          await collection.insert({
            "id": user.id,
            "notification_token": notificationToken,
          });

          mongoDB.close();
        }
      }

      return userCredentials;
    } on FirebaseAuthException catch (e) {
      String message =
          'Ocorreu um problema! por favor tenta novamente mais tarde.';

      if (e.code == 'user-not-found' || e.code == 'wrong password') {
        message = "Conta não encontrada! Verifique o Email e a Senha.";
      }

      throw ErrorDescription(message);
    } finally {
      conn?.close();
    }
  }

  Future<bool> logout() async {
    UserModel? currentUser = await getUser();

    if (currentUser != null) {
      await FirebaseAuth.instance.signOut();
      Db mongoDB = await MongoService.connect();

      DbCollection collection = mongoDB.collection('users_notifications');

      await collection.update(
          where.eq('id', currentUser.id),
          modify.set(
            'notification_token',
            null,
          ));

      mongoDB.close();

      return true;
    }

    return false;
  }
}
