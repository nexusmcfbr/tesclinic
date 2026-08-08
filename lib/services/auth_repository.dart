import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';

/// Repositório de autenticação local.
/// Arquitetura preparada para futuramente trocar por API/backend.
class AuthRepository {
  static const _usersKey = 'tesclinic_users';
  static const _sessionKey = 'tesclinic_session_user_id';
  static const _sessionAtKey = 'tesclinic_session_at';

  final _uuid = const Uuid();

  /// Hash simples + salt fixo do app (não é bcrypt, mas evita texto puro).
  String _hashPassword(String password) {
    final bytes = utf8.encode('tesclinic_salt_v1::$password');
    return sha256.convert(bytes).toString();
  }

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<List<User>> _loadUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_usersKey) ?? [];
    return raw.map((e) => User.fromJsonString(e)).toList();
  }

  Future<void> _saveUsers(List<User> users) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      _usersKey,
      users.map((u) => u.toJsonString()).toList(),
    );
  }

  /// Retorna o usuário da sessão atual ou null.
  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final id = prefs.getString(_sessionKey);
    if (id == null) return null;
    final users = await _loadUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasValidSession() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> _createSession(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionKey, userId);
    await prefs.setString(_sessionAtKey, DateTime.now().toIso8601String());
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
    await prefs.remove(_sessionAtKey);
  }

  /// Cadastro. Lança Exception com mensagem amigável em caso de erro.
  Future<User> register({
    required String name,
    required String email,
    required String password,
    DateTime? birthDate,
    String? sex,
    double? weight,
    double? height,
    String? goal,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (name.trim().isEmpty) throw Exception('Informe o nome.');
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('E-mail inválido.');
    }
    if (password.length < 6) {
      throw Exception('A senha deve ter pelo menos 6 caracteres.');
    }

    final users = await _loadUsers();
    if (users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    final now = DateTime.now();
    final user = User(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      birthDate: birthDate,
      sex: sex,
      weight: weight,
      height: height,
      goal: goal,
      createdAt: now,
      updatedAt: now,
    );

    users.add(user);
    await _saveUsers(users);
    await _createSession(user.id);
    return user;
  }

  /// Login. Lança Exception com mensagem amigável.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw Exception('Preencha e-mail e senha.');
    }

    final users = await _loadUsers();
    User? found;
    try {
      found = users.firstWhere((u) => u.email.toLowerCase() == normalizedEmail);
    } catch (_) {
      throw Exception('Usuário não encontrado.');
    }

    if (found.passwordHash != _hashPassword(password)) {
      throw Exception('Senha incorreta.');
    }

    await _createSession(found.id);
    return found;
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<void> updateUser(User user) async {
    final users = await _loadUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index < 0) return;
    users[index] = user.copyWith(updatedAt: DateTime.now());
    await _saveUsers(users);
  }
}
