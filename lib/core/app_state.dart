import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/biometric_snapshot.dart';
import '../models/demo_data.dart';
import '../models/user.dart';
import '../services/ai_analysis_service.dart';
import '../services/ai_config.dart';
import '../services/ai_models.dart';
import '../services/auth_repository.dart';
import '../services/health_repository.dart';

enum AppScreen {
  splash,
  login,
  healthConnect,
  aiAnalysis,
  main,
}

enum AppMode {
  /// Fluxo de demonstração — dados estimados, claramente identificados.
  demo,
  /// Modo real — conta do usuário + Health Connect / HealthKit.
  live,
}

class AppState extends ChangeNotifier {
  AppScreen screen = AppScreen.splash;
  AppMode mode = AppMode.live; // Padrão agora é REAL
  int tabIndex = 0;

  User? currentUser;
  bool isAuthenticated = false;
  bool isInitializing = true;

  BiometricSnapshot biometrics = BiometricSnapshot.demoFallback();
  bool formulaOptimized = false;
  LabPartner? selectedLab;
  int orderStep = 0;
  bool showLabSheet = false;
  bool showOrderTracking = false;

  final AiAnalysisService aiService = AiAnalysisService();
  final HealthRepository healthRepository = HealthRepository();
  final AuthRepository authRepository = AuthRepository();

  AiAnalysisResult? lastAnalysis;
  bool aiLoading = false;
  String? aiError;

  bool healthSyncing = false;
  HealthConnectionStatus healthStatus = HealthConnectionStatus.notDetermined;
  String? healthMessage;

  bool get hasLiveAi => AiConfig.isConfigured;
  bool get isLiveMode => mode == AppMode.live;
  bool get hasRealHealthData => biometrics.isRealData;
  bool get isDemoMode => mode == AppMode.demo;

  // ---------- Navegação ----------

  void goTo(AppScreen s) {
    screen = s;
    notifyListeners();
  }

  void setTab(int i) {
    tabIndex = i;
    notifyListeners();
  }

  // ---------- Inicialização (chamada pela Splash) ----------

  Future<void> initialize() async {
    isInitializing = true;
    notifyListeners();

    try {
      // Carrega modo salvo
      final prefs = await SharedPreferences.getInstance();
      final m = prefs.getString('app_mode');
      if (m == 'demo') {
        mode = AppMode.demo;
      } else {
        mode = AppMode.live;
      }

      // Verifica sessão
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        currentUser = user;
        isAuthenticated = true;
        // Se já tem sessão e está em modo live, vai direto ao Dashboard
        if (mode == AppMode.live) {
          screen = AppScreen.main;
        } else {
          // Sessão + demo → ainda pode ir ao main com dados demo
          biometrics = BiometricSnapshot.demoFallback().copyWith(
            lastSyncLabel: 'Demo · dados estimados',
            sourceLabel: 'Modo demonstração',
            connected: true,
            isRealData: false,
          );
          screen = AppScreen.main;
        }
      } else {
        isAuthenticated = false;
        currentUser = null;
        screen = AppScreen.login;
      }
    } catch (e) {
      debugPrint('Init error: $e');
      screen = AppScreen.login;
    }

    isInitializing = false;
    notifyListeners();
  }

  // ---------- Autenticação ----------

  Future<void> register({
    required String name,
    required String email,
    required String password,
    DateTime? birthDate,
    String? sex,
    double? weight,
    double? height,
    String? goal,
  }) async {
    final user = await authRepository.register(
      name: name,
      email: email,
      password: password,
      birthDate: birthDate,
      sex: sex,
      weight: weight,
      height: height,
      goal: goal,
    );
    currentUser = user;
    isAuthenticated = true;
    mode = AppMode.live;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', 'live');
    // Não navega aqui — a RegisterScreen faz o pop e chama goTo
  }

  void goToHealthAfterRegister() {
    goTo(AppScreen.healthConnect);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final user = await authRepository.login(email: email, password: password);
    currentUser = user;
    isAuthenticated = true;
    mode = AppMode.live;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', 'live');
    goTo(AppScreen.main);
  }

  Future<void> logout() async {
    await authRepository.logout();
    currentUser = null;
    isAuthenticated = false;
    biometrics = BiometricSnapshot.demoFallback();
    lastAnalysis = null;
    formulaOptimized = false;
    tabIndex = 0;
    goTo(AppScreen.login);
  }

  // ---------- Modos ----------

  Future<void> enterDemoMode() async {
    mode = AppMode.demo;
    biometrics = BiometricSnapshot.demoFallback().copyWith(
      lastSyncLabel: 'Demo · dados estimados',
      sourceLabel: 'Modo demonstração',
      connected: true,
      isRealData: false,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', 'demo');
    // Demo não exige autenticação
    goTo(AppScreen.aiAnalysis);
  }

  Future<void> enterLiveMode() async {
    mode = AppMode.live;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', 'live');

    if (isAuthenticated) {
      goTo(AppScreen.healthConnect);
    } else {
      // Precisa de conta real
      goTo(AppScreen.login);
    }
  }

  // ---------- Saúde ----------

  Future<void> requestHealthAndSync() async {
    healthSyncing = true;
    healthMessage = null;
    notifyListeners();

    healthStatus = await healthRepository.requestAuthorization();
    if (healthStatus == HealthConnectionStatus.denied ||
        healthStatus == HealthConnectionStatus.error ||
        healthStatus == HealthConnectionStatus.unsupported) {
      healthMessage = healthStatus == HealthConnectionStatus.unsupported
          ? 'Esta plataforma não tem HealthKit/Health Connect. Você pode continuar com dados estimados (marcados como tal).'
          : 'Permissão negada ou indisponível. O app continua funcionando; dados de saúde ficam indisponíveis.';
      biometrics = BiometricSnapshot.demoFallback().copyWith(
        sourceLabel: healthRepository.platformSourceLabel,
        lastSyncLabel: 'Permissão pendente',
        isRealData: false,
        connected: false,
      );
      healthSyncing = false;
      notifyListeners();
      return;
    }

    await syncHealth();
  }

  Future<void> syncHealth() async {
    healthSyncing = true;
    notifyListeners();
    try {
      final snap = await healthRepository.sync(preferReal: mode == AppMode.live);
      biometrics = snap;
      healthStatus = snap.isRealData
          ? HealthConnectionStatus.authorized
          : HealthConnectionStatus.partial;
      healthMessage = snap.isRealData
          ? 'Sincronizado: ${snap.sourceLabel}'
          : 'Poucos dados no dispositivo — alguns valores estimados (marcados).';
    } catch (e) {
      healthMessage = 'Falha ao sincronizar: $e';
    }
    healthSyncing = false;
    notifyListeners();
  }

  // ---------- Análise / Fórmula ----------

  Future<AiAnalysisResult> runAnalysis({bool optimize = false}) async {
    aiLoading = true;
    aiError = null;
    notifyListeners();
    try {
      final bio = DemoBiometrics()
        ..restingHr = biometrics.restingHr
        ..sleepHours = biometrics.sleepHours
        ..recovery = biometrics.recovery
        ..energy = biometrics.energy
        ..sleepQuality = biometrics.sleepQuality
        ..stress = biometrics.stress
        ..readiness = biometrics.readiness
        ..weeklyTrainings = biometrics.weeklyTrainings
        ..lastSync = biometrics.lastSyncLabel
        ..connected = biometrics.connected;

      final result = await aiService.analyze(
        bio: bio,
        optimizeExisting: optimize,
      );
      lastAnalysis = result;
      biometrics = biometrics.copyWith(readiness: result.readiness);
      if (optimize) formulaOptimized = true;
      aiLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      aiError = e.toString();
      aiLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ---------- Lab / Pedidos (mantido) ----------

  void markOptimized() {
    formulaOptimized = true;
    notifyListeners();
  }

  void selectLab(LabPartner lab) {
    selectedLab = lab;
    notifyListeners();
  }

  void startOrder() {
    orderStep = 1;
    showOrderTracking = true;
    showLabSheet = false;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      orderStep = 2;
      notifyListeners();
    });
  }

  void openLabSheet() {
    showLabSheet = true;
    notifyListeners();
  }

  void closeSheets() {
    showLabSheet = false;
    showOrderTracking = false;
    notifyListeners();
  }

  void updateBio({
    double? hr,
    double? sleep,
    double? recovery,
    double? energy,
    String? sleepQ,
    String? stress,
  }) {
    biometrics = biometrics.copyWith(
      restingHr: hr,
      sleepHours: sleep,
      recovery: recovery,
      energy: energy,
      sleepQuality: sleepQ,
      stress: stress,
    );
    notifyListeners();
  }

  void setApiKey(String? key) {
    AiConfig.setApiKey(key);
    notifyListeners();
  }

  @override
  void dispose() {
    aiService.dispose();
    super.dispose();
  }
}
