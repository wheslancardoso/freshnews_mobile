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


devolver em formato de prompt pra outra IA apenas executar