import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseConnection {
  static final DatabaseConnection _instance = DatabaseConnection._internal();
  factory DatabaseConnection() => _instance;
  DatabaseConnection._internal();

  PostgreSQLConnection? _connection;

  Future<bool> connect() async {
    if (_connection != null && _connection!.isClosed == false) {
      return true; // Already connected
    }

    String host = dotenv.env['DB_HOST'] ?? '';
    int port = int.parse(dotenv.env['DB_PORT'] ?? '');
    String dbName = dotenv.env['DB_NAME'] ?? '';
    String username = dotenv.env['DB_USER'] ?? '';
    String password = dotenv.env['DB_PASSWORD'] ?? '';

    _connection = PostgreSQLConnection(
      host,
      port,
      dbName,
      username: username,
      password: password,
      useSSL: true,
    );

    try {
      await _connection!.open();
      return true;
    } catch (e) {
      print("Database connection failed: $e");
      return false;
    }
  }

  PostgreSQLConnection? get connection => _connection;

  void close() {
    _connection?.close();
  }

  bool get isConnected => _connection != null && !_connection!.isClosed;
}

// How to use:
// final db = DatabaseConnection();
// if (db.isConnected) {
// final results = await db.connection!.query('SELECT * FROM users');
// // Process results
// } else {
// // Handle disconnected state
// }
