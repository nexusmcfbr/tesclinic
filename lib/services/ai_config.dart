/// Configuração da API de IA.
///
/// Nunca commite a chave no repositório.
/// Defina em tempo de execução via [AiConfig.setApiKey] ou
/// variável de ambiente TESCLINIC_AI_API_KEY (build/CI).
class AiConfig {
  /// Endpoint OpenAI-compatible (OpenAI, Groq, Together, Azure, local LM Studio, etc.)
  static String baseUrl = 'https://api.openai.com/v1';

  /// Modelo padrão
  static String model = 'gpt-4o-mini';

  static String? _apiKey;

  static String? get apiKey => _apiKey;

  static bool get isConfigured =>
      _apiKey != null && _apiKey!.trim().isNotEmpty;

  static void setApiKey(String? key) {
    _apiKey = key?.trim().isEmpty == true ? null : key?.trim();
  }

  /// Timeout da chamada em segundos
  static const int timeoutSeconds = 45;
}
