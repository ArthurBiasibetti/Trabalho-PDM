import 'package:postgres/postgres.dart';

class PostgresService {
  Future<Connection> openConnection() async {
    final conn = await Connection.open(
      Endpoint(
        host: '10.0.2.2',
        database: 'olho_do_pai',
        username: 'postgres',
        password: '852147',
        port: 5433,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print('Conexão feita!');

    return conn;
  }
}
