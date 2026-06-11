# Prompts de Desenvolvimento — Fase 2: Autenticação, Home e Inscrição

Este arquivo contém dois prompts estruturados de desenvolvimento para você copiar ou enviar ao Claude externo, avançando no desenvolvimento do app móvel do Fresh News.

---

## 🔐 PROMPT 3: Autenticação de Administrador e Guards de Rota

```markdown
Você é um Engenheiro Flutter Sênior. Nosso objetivo é implementar o fluxo completo de autenticação de administrador com persistência de sessão e guards de rotas baseados no GoRouter e Riverpod.

Use a especificação técnica abaixo como guia absoluto:

=========================================
ESPECIFICAÇÃO DE AUTENTICAÇÃO (02_AUTH_AND_MIDDLEWARE.md)
=========================================
# 02 — Auth & Middleware // Fresh News Mobile

> **Destinatário**: Membro 1 (Líder / Fundação)
> **Objetivo**: Implementar o fluxo de autenticação admin e route guards no Flutter.
> **Pré-requisito**: Módulos 00 e 01 executados.

---

## Como Funciona a Auth no Projeto Web
O Fresh News não usa Supabase Auth para o admin. O login é simplificado:
1. Usuário acessa `/login` e digita uma senha fixa definida via env `ADMIN_PASSWORD`.
2. Se a senha bater, um cookie `admin_session` é criado com valor "true" e validade de 7 dias.
3. O middleware Next.js verifica esse cookie em todas as rotas `/admin/*`.

## Implementação Mobile (Flutter)
No mobile, usaremos SharedPreferences para persistir a sessão admin localmente. A senha admin é verificada via a API Route customizada:
```
POST /api/login
Body: { "password": "..." }
Response: { "success": true } ou { "success": false, "error": "invalid_password" }
```

### Auth State
```dart
enum AuthStatus { unauthenticated, authenticated, loading }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.errorMessage,
  });

  bool get isAdmin => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
```

### Auth Notifier (Riverpod)
```dart
class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthNotifier(this._prefs, this._dio) : super(const AuthState()) {
    _loadSession();
  }

  static const _sessionKey = 'admin_session';
  static const _sessionExpiryKey = 'admin_session_expiry';

  void _loadSession() {
    final session = _prefs.getBool(_sessionKey) ?? false;
    final expiryStr = _prefs.getString(_sessionExpiryKey);

    if (session && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isBefore(expiry)) {
        state = const AuthState(status: AuthStatus.authenticated);
        return;
      }
    }

    _prefs.remove(_sessionKey);
    _prefs.remove(_sessionExpiryKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> login(String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _dio.post(
        '/api/login',
        data: {'password': password},
      );

      if (response.data['success'] == true) {
        final expiry = DateTime.now().add(const Duration(days: 7));
        await _prefs.setBool(_sessionKey, true);
        await _prefs.setString(_sessionExpiryKey, expiry.toIso8601String());

        state = const AuthState(status: AuthStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Senha incorreta',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erro de conexão. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_sessionExpiryKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
```

### Route Guard no GoRouter
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/archive', builder: (_, __) => const ArchiveScreen()),
      GoRoute(path: '/archive/:id', builder: (_, state) => NewsletterDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/post/:id', builder: (_, state) => PostDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(path: '/subscribe', builder: (_, __) => const SubscribeScreen()),
      GoRoute(path: '/unsubscribe', builder: (_, state) => UnsubscribeScreen(token: state.uri.queryParameters['token'])),
      GoRoute(path: '/preferences/:id', builder: (_, state) => PreferencesScreen(subscriberId: state.pathParameters['id']!)),

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
        redirect: (_, __) {
          if (auth.isAdmin) return '/admin/posts';
          return null;
        },
      ),

      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/posts', builder: (_, __) => const AdminPostsScreen()),
          GoRoute(path: '/admin/newsletters', builder: (_, __) => const AdminNewslettersScreen()),
        ],
        redirect: (_, __) {
          if (!auth.isAdmin) return '/login';
          return null;
        },
      ),
    ],
  );
});
```

### Tela de Login
Minimalista e centralizada:
- Container glassmorphism (`borderRadius: 56px`).
- Ícone Lock centralizado.
- Título "ÁREA RESTRITA" em bold italic uppercase.
- Subtítulo "APENAS PARA EDITORES AUTORIZADOS." em label minúsculo.
- Campo de senha `FNInput` com hint.
- Mensagem de erro vermelha se necessário.
- Botão "ACESSAR_PAINEL".
- Footer "Binary BroadSheet // Security Layer".

=========================================

---
REGRAS RÍGIDAS DE RETORNO (Siga à risca para integração automática):
1. Retorne APENAS os caminhos dos arquivos e seus respectivos blocos de código completos.
2. NÃO adicione introduções, explicações teóricas, ou textos conversacionais antes ou depois do código.
3. Formate cada arquivo exatamente usando este padrão markdown:

### ARQUIVO: `mobile/caminho/do/arquivo.dart`
```dart
// Código completo sem truncamento ou placeholders
```

Arquivos esperados:
- O estado de autenticação em `mobile/lib/features/auth/domain/auth_state.dart`.
- O notifier com persistência local em `mobile/lib/features/auth/application/auth_notifier.dart`.
- A tela de login completa em `mobile/lib/features/auth/presentation/login_screen.dart` usando GlassCard, FNInput e FNButton.
- O arquivo do roteador atualizado em `mobile/lib/app/router.dart` integrando os guards com GoRouter.
```

---

## 📱 PROMPT 4: Tela Inicial (Home) e Fluxo de Inscrição (Subscribe)

```markdown
Você é um Engenheiro de UI/UX em Flutter. Nosso objetivo é construir a tela principal (HomeScreen) com grid de edições de newsletters, tabs de categoria reativas e o fluxo completo de cadastro de assinantes (SubscribeFlow).

Use a especificação técnica abaixo como guia absoluto:

=========================================
ESPECIFICAÇÕES DE HOME E INSCRIÇÃO (03_HOME_SCREEN.md + 07_SUBSCRIBE_FLOW.md)
=========================================
# 03 — Home Screen & Inscrição // Fresh News Mobile

A Home do app é mobile-first composta de:
1. **SliverAppBar Glass**: Com logo "FN", título "FRESH NEWS" em italic bold, e o widget WorldSelector no canto.
2. **Hero Section**: Com o badge "STATUS // ONLINE // TRANSMITINDO", o título principal "INFORMAÇÃO DESTILADA. SEM RUÍDO.", uma frase editorial e um botão para ver edições anteriores (/archive).
3. **World Chips**: Seletor horizontal com micro-animações do mundo ativo (TECH | MUSIC | GEAR | GAME).
4. **Category Tabs**: Chips horizontais reativos do mundo selecionado (ex: DEV, IA, Segurança).
5. **Newsletter Grid**: Mostrando os cards de edições de newsletters publicadas usando o widget `NewsCard`.
6. **Subscribe Section**: O formulário de inscrição completo.

### Lógica de Inscrição (Subscribe Flow)
O formulário de inscrição precisa de:
- Validação client-side do email e do telefone.
- Escolha múltipla de chips de categorias de preferência de acordo com o mundo ativo.
- Chamada via repositório de assinantes para o Supabase.
- Animação de sucesso/feedback.

### Providers e State Management (Riverpod)
```dart
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredNewslettersProvider = Provider.autoDispose<AsyncValue<List<Newsletter>>>((ref) {
  final newsletters = ref.watch(publishedNewslettersProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return newsletters.whenData((list) {
    if (selectedCategory == null) return list;
    return list.where((n) => n.category == selectedCategory).toList();
  });
});
```

=========================================

---
REGRAS RÍGIDAS DE RETORNO (Siga à risca para integração automática):
1. Retorne APENAS os caminhos dos arquivos e seus respectivos blocos de código completos.
2. NÃO adicione introduções, explicações teóricas, ou textos conversacionais antes ou depois do código.
3. Formate cada arquivo exatamente usando este padrão markdown:

### ARQUIVO: `mobile/caminho/do/arquivo.dart`
```dart
// Código completo sem truncamento ou placeholders
```

Arquivos esperados:
- O controller de inscrição em `mobile/lib/features/subscribe/application/subscribe_controller.dart`.
- A seção/formulário de inscrição em `mobile/lib/features/subscribe/presentation/subscribe_section.dart`.
- A tela Home principal em `mobile/lib/features/home/presentation/home_screen.dart` que integra todos os slivers, grids e widgets de cabeçalho.
- O arquivo `mobile/lib/features/home/application/home_providers.dart` com as queries reativas e filtros por mundos e categorias.
```
devolver em formato de prompt pra outra IA apenas executar