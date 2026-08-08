# TesClinic

Plataforma adaptativa de performance e formulação inteligente.

## Modos

1. **Demo** — fluxo idêntico ao vídeo (dados estimados).
2. **Real** — Apple Health / Health Connect → prontidão, recuperação e fórmula com biometria do relógio.

## Executar

```bash
flutter pub get
flutter run
```

### iOS (obrigatório no Xcode)

1. Abra `ios/Runner.xcworkspace`
2. Target **Runner** → **Signing & Capabilities** → **+ Capability** → **HealthKit**
3. Confirme que `Runner.entitlements` está ligado ao target
4. Rode em **iPhone real** (HealthKit é limitado no simulador)

### Android

- minSdk 26
- Health Connect instalado no aparelho
- Aceite as permissões na primeira sincronização

## API de IA

**More → API de IA** — endpoint OpenAI-compatible. Sem chave, motor local.

## Arquitetura de saúde

```
HealthKit / Health Connect
        ↓
HealthRepository
        ↓
ReadinessCalculator  (regras auditáveis)
        ↓
BiometricSnapshot
        ↓
AiAnalysisService + UI
```

## Aviso

Não substitui avaliação médica ou farmacêutica. Scores são estimativas de performance.
