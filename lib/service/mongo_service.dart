import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static connect() async {
    Db db = await Db.create(
      "mongodb+srv://arthurbiasibettifarias:M%40nolola@cluster0.e8bbg.mongodb.net/olho-do-pai?retryWrites=true&w=majority&appName=Cluster0",
    );
    await db.open();
    inspect(db);
    print(await db.serverStatus());

    return db;
  }
}
