Você é um Engenheiro Flutter Sênior. Nosso objetivo é construir as telas de consumo do Fresh News Mobile: a tela do Arquivo Histórico (com motor de afinidade reordenando posts), a tela de Detalhes da Newsletter (com a simulação animada do Terminal Debate entre IAs) e a tela de Detalhes do Post (com tracking de cliques e resumo compartilhável para o WhatsApp).

Use as especificações técnicas abaixo como guia absoluto:

======================================================================
ESPECIFICAÇÃO DO ARQUIVO HISTÓRICO (04_ARCHIVE_SCREEN.md)
======================================================================
# 04 — Archive Screen // Fresh News Mobile

> **Destinatário**: Membro 2 (Telas de Consumo)
> **Objetivo**: Implementar a tela de arquivo com feed de afinidades e edições históricas.
> **Pré-requisito**: Módulos 00, 01, 09 executados.

---

## Comportamento da Tela (Web Original)

A página `/archive` tem 3 grandes blocos:

1. **Hero do Arquivo** — Título "Arquivo Histórico" com contador de edições
2. **Feed de Afinidades** — Posts individuais ordenados por afinidade do assinante
3. **Edições Arquivadas** — Grid de newsletters completas publicadas

### Conceito de "Afinidade"

Se o usuário for um **assinante identificado** (via `subscriberId`):
- Posts são reordenados com base nas preferências do assinante
- Categorias selecionadas vêm primeiro, desempate por score
- Mostra badge "AFINIDADE_ALTA" nos posts de categorias preferidas
- Permite ajustar preferências via link "AJUSTAR_INTERESSES"

Se NÃO for assinante:
- Mostra posts em ordem de score (padrão)
- Exibe CTA para assinar

---

## Mobile Adaptation

### Estrutura da Tela

```
┌──────────────────────────────┐
│ AppBar (Glass)               │  ← "Arquivo" + World Selector
├──────────────────────────────┤
│ Hero Card                    │
│ "ARQUIVO HISTÓRICO"          │
│ [TOTAL_LOGS: 42]             │
├──────────────────────────────┤
│ Affinity Alert Banner        │  ← Status do motor de afinidades
│ ┌────────────────────────┐   │
│ │ 🟢 MOTOR_ATIVO         │   │  ← ou 🔴 MOTOR_INATIVO
│ │ Feed personalizado      │   │
│ │ [AJUSTAR_INTERESSES]    │   │
│ └────────────────────────┘   │
├──────────────────────────────┤
│ Section: "Feed de Afinidades"│
│ ┌──────────────────────────┐ │
│ │ PostCard                 │ │
│ │ [CATEGORIA]  [SCORE: 85] │ │
│ │ [AFINIDADE_ALTA] (opt.)  │ │
│ │ Título do Post           │ │
│ │ Resumo...                │ │
│ │ FONTE: web  LER_POST →   │ │
│ └──────────────────────────┘ │
│ ...                          │
├──────────────────────────────┤
│ Divider                      │
├──────────────────────────────┤
│ Section: "Edições Arquivadas"│
│ NewsCard grid (1 col mobile) │
│ ...                          │
├──────────────────────────────┤
│ Footer                       │
└──────────────────────────────┘
```

---

## Dados Necessários

### Providers

```dart
// features/archive/application/archive_providers.dart

/// ID do assinante (pode vir de SharedPrefs ou deep link)
final subscriberIdProvider = StateProvider<String?>((ref) => null);

/// Subscriber data (se logado)
final subscriberProvider = FutureProvider.autoDispose<Subscriber?>((ref) {
  final id = ref.watch(subscriberIdProvider);
  if (id == null) return null;
  return ref.read(subscriberRepositoryProvider).getById(id);
});

/// Posts aprovados do mundo ativo (com reordenação por afinidade)
final affinityPostsProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final world = ref.watch(activeWorldProvider);
  final subscriber = await ref.watch(subscriberProvider.future);
  
  final posts = await ref.read(postRepositoryProvider).getApproved(
    world: world,
    limit: 10,
  );

  if (subscriber == null || subscriber.preferences.isEmpty) return posts;

  // Reordenar por afinidade
  return posts..sort((a, b) {
    final aPref = subscriber.preferences.contains(a.category) ? 1 : 0;
    final bPref = subscriber.preferences.contains(b.category) ? 1 : 0;
    if (aPref != bPref) return bPref - aPref;
    return b.score.compareTo(a.score);
  });
});

/// Newsletters publicadas do mundo ativo
final archivedNewslettersProvider = FutureProvider.autoDispose<List<Newsletter>>((ref) {
  final world = ref.watch(activeWorldProvider);
  return ref.read(newsletterRepositoryProvider).getPublished(
    world: world,
    pageSize: 100,
  );
});
```

---

## Componentes Detalhados

### 1. Hero Card

- Container: glass card, sem border-radius (brutalista), borda dupla 4px `border-white/10`
- Background: scanlines overlay com opacity 5%
- Layout: Column
  - Badge: ícone pulse + "INTELLIGENCE_LOG"
  - Título: "ARQUIVO HISTÓRICO" em 40sp bold italic
  - A palavra "HISTÓRICO" em cor primária
  - Subtítulo: "Explorando o log de transmissões técnicas"
- Direita: glass card com "TOTAL_LOGS" + contador grande

### 2. Affinity Alert Banner

Dois estados visuais:

**Motor ATIVO (assinante identificado):**
- Borda: `Colors.green[500]` com opacity 0.4
- Fundo: `Colors.green[950]` com opacity 0.1
- Dot verde pulsante + "MOTOR_DE_AFINIDADES_ATIVO"
- Título: "Zine Personalizado // Feed de Afinidades"
- Descrição: mostra email do subscriber
- Tags de filtros (chips das preferências)
- Botão: "AJUSTAR_INTERESSES" → navega para `/preferences/:id`

**Motor INATIVO (visitante):**
- Borda: branca 10%
- Fundo: branco 1%
- Dot neutro + "MOTOR_DE_AFINIDADES_INATIVO"
- CTA: "ASSINAR_PORTAL" → navega para `/subscribe`

### 3. PostCard (Feed de Afinidades)

Componente novo, específico para posts individuais:

```dart
class PostCard extends StatelessWidget {
  final Post post;
  final bool isPreferred; // se a categoria é preferida do subscriber

  // Layout:
  // - Container: borda verde se isPreferred, branca se não
  // - Scanlines overlay
  // - Badge de categoria com cor dinâmica:
  //   - TECH_HACKER / SEGURANÇA → vermelho
  //   - SYNTH_AESTHETICS → roxo  
  //   - GEARHEAD → amarelo
  //   - IA → verde esmeralda
  //   - Default → ciano
  // - Badge "AFINIDADE_ALTA" se isPreferred (verde)
  // - Score: "SCORE: 85"
  // - Título em 20sp bold italic, muda para primary no hover
  // - Resumo truncado em 4 linhas
  // - Footer: "FONTE: web" + "LER_POST →"
  // - Ao clicar: navega para /post/:id
}
```

**Cores de categoria:**

```dart
Color getCategoryColor(String category) {
  switch (category) {
    case 'TECH_HACKER':
    case 'SEGURANÇA':
      return const Color(0xFFF87171); // red-400
    case 'SYNTH_AESTHETICS':
      return const Color(0xFFA78BFA); // purple-400
    case 'GEARHEAD':
      return const Color(0xFFFBBF24); // yellow-400
    case 'IA':
      return const Color(0xFF34D399); // emerald-400
    default:
      return const Color(0xFF22D3EE); // cyan-400
  }
}
```

### 4. Seção "Edições Arquivadas"

- Usa os mesmos `NewsCard` da Home
- Grid de 1 coluna no mobile, 2 no tablet
- Cada card mostra: imagem, edição, título, data, intro
- Clicar navega para `/archive/:id`

---

## Animações

| Elemento | Animação |
|---|---|
| PostCards | FadeInLeft staggered (100ms delay) |
| NewsCards | FadeInUp staggered (100ms delay) |
| Alert banner | SlideInDown (300ms) |
| Badge "AFINIDADE_ALTA" | Glow pulse (2s loop) |


======================================================================
ESPECIFICAÇÃO DE DETALHE DA NEWSLETTER (05_NEWSLETTER_DETAIL.md)
======================================================================
# 05 — Newsletter Detail Screen // Fresh News Mobile

> **Destinatário**: Membro 2 (Telas de Consumo)
> **Objetivo**: Implementar a tela de detalhe de uma newsletter com conteúdo completo e Terminal Debate interativo.
> **Pré-requisito**: Módulos 00, 01, 09 executados.

---

## Comportamento da Tela (Web Original)

A rota `/archive/[id]` mostra o conteúdo completo de uma newsletter:

1. **Header** com navegação e seletor de mundos
2. **Imagem de capa** (se houver)
3. **Título da edição** com número e data
4. **Intro editorial** com destaque
5. **Quick Takes** (⚡ GIRO TECH) — bullets rápidos
6. **Categorias e notícias** — cada categoria com seus itens
7. **Terminal Debate** — debate animado entre IAs com typewriter
8. **Footer**

---

## Mobile Adaptation

### Estrutura da Tela

```
┌──────────────────────────────┐
│ AppBar (Glass)               │
│ ← Back    EDIÇÃO #42         │
├──────────────────────────────┤
│ Cover Image (Full Width)     │
│ [Imagem da capa com overlay] │
├──────────────────────────────┤
│ Edition Metadata             │
│ #42 · MASTER · 01/06/2026    │
├──────────────────────────────┤
│ Title                        │
│ "Título Grande da Edição"    │
├──────────────────────────────┤
│ Intro                        │
│ "Texto editorial..."         │
├──────────────────────────────┤
│ Quick Takes Card             │
│ ⚡ GIRO TECH                 │
│ • Manchete 1                 │
│ • Manchete 2                 │
│ • Manchete 3                 │
├──────────────────────────────┤
│ ── Separator ──              │
├──────────────────────────────┤
│ Category: 🤖 IA              │
│ ┌──────────────────────────┐ │
│ │ [Imagem do item]         │ │
│ │ Headline                 │ │
│ │ Story text...            │ │
│ │ Ler fonte original →     │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ Headline 2               │ │
│ │ Story text...            │ │
│ └──────────────────────────┘ │
│                              │
│ Category: 💻 DEV             │
│ ...                          │
├──────────────────────────────┤
│ ── Terminal Debate ──        │
│ ┌──────────────────────────┐ │
│ │ 🤖 AI_ANALYST: "..."     │ │  ← Typewriter effect
│ │ 🛡️ SEC_OPS: "..."        │ │
│ │ 💻 DEV_LEAD: "..."       │ │
│ │                          │ │
│ │ [▶] [⏸] [⏮] [1x/2x]   │ │  ← Controls
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ Admin Actions (se admin)     │
│ [✓ Aprovar] [✗ Rejeitar]     │
├──────────────────────────────┤
│ Footer                       │
└──────────────────────────────┘
```

---

## Dados Necessários

### Provider

```dart
// features/newsletter_detail/application/newsletter_detail_provider.dart

final newsletterDetailProvider = FutureProvider.autoDispose.family<Newsletter, String>((ref, id) {
  return ref.read(newsletterRepositoryProvider).getById(id);
});
```

### Estrutura do content_json

```json
{
  "title": "O Futuro é Líquido",
  "intro": "Texto editorial de abertura...",
  "quickTakes": [
    "⚡ Apple anuncia novo chip M5",
    "🔥 OpenAI lança GPT-5 em beta",
    "👀 Google compra startup de robótica"
  ],
  "categories": [
    {
      "name": "🤖 IA & MACHINE LEARNING",
      "items": [
        {
          "headline": "GPT-5 promete raciocínio...",
          "story": "A OpenAI revelou hoje...",
          "link": "https://...",
          "imageUrl": "https://..."
        }
      ]
    }
  ],
  "image_prompt": "..."
}
```

### Estrutura do debate_log

```json
[
  {
    "persona": "ARIA",
    "role": "AI",
    "avatar": "🤖",
    "color": "#8B5CF6",
    "message": "A nova arquitetura de atenção..."
  },
  {
    "persona": "SENTINEL",
    "role": "SEC",
    "avatar": "🛡️",
    "color": "#F43F5E",
    "message": "Do ponto de vista de segurança..."
  }
]
```

---

## Componentes Detalhados

### 1. Cover Image

- Full-width, aspect ratio 16:9
- Overlay gradient: preto 60% na base → transparente no topo
- Border-radius: 0 (brutalista)
- Usar `CachedNetworkImage` com placeholder shimmer
- Se não houver imagem: mostrar container com gradiente primário + padrão scanlines

### 2. Edition Metadata

```dart
Row(
  children: [
    FNBadge(label: 'EDIÇÃO #${newsletter.editionNumber}'),
    SizedBox(width: 8),
    FNBadge(label: newsletter.category ?? 'MASTER'),
    Spacer(),
    Text(formatDate(newsletter.createdAt), style: techLabel),
  ],
)
```

### 3. Quick Takes

- Container: glass card, sem border-radius, borda 2px, fundo `#1c1b1b`
- Título: "⚡ GIRO TECH" em bold uppercase
- Lista: bullets com texto médio
- Estilo: monospace, linhas espaçadas

### 4. Category Sections

Para cada categoria em `contentJson.categories`:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Cabeçalho com cor dinâmica
    Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: catColor, width: 2)),
      ),
      child: Text(category.name, style: categoryTitleStyle.copyWith(color: catColor)),
    ),
    SizedBox(height: 16),
    
    // Itens
    ...category.items.map((item) => NewsItemCard(item: item, catColor: catColor)),
  ],
)
```

**Cores de categoria (mesmo do email template):**

```dart
Color getCategoryColor(String name) {
  final upper = name.toUpperCase();
  if (upper.contains('IA') || upper.contains('INTELIGÊNCIA')) return Color(0xFFA78BFA); // Lavender
  if (upper.contains('DEV') || upper.contains('ENGENHARIA')) return Color(0xFF10B981); // Emerald
  if (upper.contains('SEC') || upper.contains('CIBER') || upper.contains('HACKER')) return Color(0xFFF43F5E); // Rose
  if (upper.contains('STARTUP') || upper.contains('BUSINESS') || upper.contains('MERCADO')) return Color(0xFFF59E0B); // Amber
  return Color(0xFF8B5CF6); // Violet default
}
```

### 5. NewsItemCard

```dart
// Cada notícia dentro de uma categoria
Container(
  margin: EdgeInsets.only(bottom: 24),
  padding: EdgeInsets.only(left: 16),
  decoration: BoxDecoration(
    border: Border(left: BorderSide(color: catColor, width: 2)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Imagem (se houver)
      if (item.imageUrl != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(imageUrl: item.imageUrl!, height: 200, fit: BoxFit.cover),
        ),
      SizedBox(height: 12),
      // Headline
      GestureDetector(
        onTap: () => launchUrl(Uri.parse(item.link)),
        child: Text(item.headline, style: headlineStyle),
      ),
      SizedBox(height: 8),
      // Story
      Text(item.story, style: storyStyle),
      SizedBox(height: 12),
      // Link
      GestureDetector(
        onTap: () => launchUrl(Uri.parse(item.link)),
        child: Text('Ler fonte original →', style: linkStyle.copyWith(color: catColor)),
      ),
    ],
  ),
)
```

### 6. Terminal Debate (Componente Complexo)

Este é o componente mais complexo da tela. Simula um terminal de debate entre IAs.

#### Comportamento:

1. **Parado inicialmente** — mostra apenas o primeiro avatar e "▶ PLAY PARA INICIAR"
2. **Ao clicar Play**: mensagens aparecem uma por uma com **typewriter effect**
3. **Velocidade**: 1x (30ms/char), 2x (15ms/char), 3x (5ms/char)
4. **Controles**: Play/Pause, Reset, Speed toggle
5. **Scroll automático** para a mensagem mais recente
6. **Visual**: fundo preto terminal, texto monospace, cada persona com cor própria

#### Implementação:

```dart
class TerminalDebate extends StatefulWidget {
  final List<DebateMessage> messages;
  // ...
}

class _TerminalDebateState extends State<TerminalDebate> {
  int _currentMessageIndex = 0;
  int _currentCharIndex = 0;
  bool _isPlaying = false;
  int _speed = 1; // 1x, 2x, 3x
  Timer? _timer;
  final _scrollController = ScrollController();

  void _play() {
    _isPlaying = true;
    final delays = {1: 30, 2: 15, 3: 5};
    _timer = Timer.periodic(
      Duration(milliseconds: delays[_speed]!),
      (_) => _advanceChar(),
    );
  }

  void _advanceChar() {
    if (_currentMessageIndex >= widget.messages.length) {
      _pause();
      return;
    }
    
    final currentMsg = widget.messages[_currentMessageIndex];
    if (_currentCharIndex < currentMsg.message.length) {
      setState(() => _currentCharIndex++);
    } else {
      // Próxima mensagem
      setState(() {
        _currentMessageIndex++;
        _currentCharIndex = 0;
      });
      _scrollToBottom();
    }
  }

  void _pause() { _timer?.cancel(); _isPlaying = false; setState(() {}); }
  void _reset() { _pause(); setState(() { _currentMessageIndex = 0; _currentCharIndex = 0; }); }
  void _toggleSpeed() { setState(() { _speed = _speed >= 3 ? 1 : _speed + 1; }); if (_isPlaying) { _pause(); _play(); } }
}
```

#### Visual do Terminal:

```
┌────────────────────────────────────┐
│ ● ● ●  FRESH_NEWS // AI_DEBATE    │  ← Header com dots simulando janela
├────────────────────────────────────┤
│                                    │
│ 🤖 ARIA [AI_ANALYST]               │  ← Avatar + Nome + Role (cor #8B5CF6)
│ > A nova arquitetura de atenção    │  ← Typewriter em monospace
│   permitirá que modelos locais...  │
│                                    │
│ 🛡️ SENTINEL [SEC_OPS]              │  ← (cor #F43F5E)
│ > Do ponto de vista de segu|       │  ← Cursor piscando
│                                    │
├────────────────────────────────────┤
│  [▶/⏸]  [⏮ Reset]  [2x Speed]    │  ← Controles
└────────────────────────────────────┘
```

- Fundo: `Color(0xFF0A0A0A)`
- Borda: 2px `Color(0xFF333333)`
- Header: dots vermelho/amarelo/verde + título monospace
- Mensagens: padding left com indicator `>`
- Cursor: caractere `|` piscando a cada 500ms
- Controles: row de botões estilizados

---

## Ações Admin (Condicional)

Se `isAdmin == true` (do `authProvider`):

```dart
if (isAdmin && newsletter.isDraft) ...[
  Row(
    children: [
      Expanded(
        child: FNButton(
          label: 'APROVAR E PUBLICAR',
          leading: Icon(LucideIcons.check),
          primaryColor: Colors.green,
          onPressed: () => _publishNewsletter(),
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: FNButton(
          label: 'REJEITAR EDIÇÃO',
          leading: Icon(LucideIcons.x),
          primaryColor: Colors.red,
          onPressed: () => _rejectNewsletter(),
        ),
      ),
    ],
  ),
],
```


======================================================================
ESPECIFICAÇÃO DE DETALHE DO POST (06_POST_DETAIL.md)
======================================================================
# 06 — Post Detail Screen // Fresh News Mobile

> **Destinatário**: Membro 2 (Telas de Consumo)
> **Objetivo**: Implementar a tela de detalhe de um post individual.
> **Pré-requisito**: Módulos 00, 01, 09 executados.

---

## Comportamento (Web Original)

A rota `/post/[id]` exibe o conteúdo completo de um post individual curado.

---

## Dados Necessários

```dart
final postDetailProvider = FutureProvider.autoDispose.family<Post, String>((ref, id) {
  return ref.read(postRepositoryProvider).getById(id);
});
```

### Post Entity (campos relevantes)

| Campo | Tipo | Uso na Tela |
|---|---|---|
| title | String | Título principal |
| content | String? | Conteúdo completo |
| summary | String? | Resumo (fallback se content vazio) |
| source | String? | Nome da fonte |
| url | String | Link original |
| score | int | Score de relevância |
| category | String | Categoria (ex: "IA", "TECH_HACKER") |
| subCategory | String | Sub-categoria |
| world | String | Mundo (TECH/MUSIC/GEAR/GAME) |
| themeConfig | Map? | Configuração visual (dna, cores, prompt) |
| whatsappSummary | String? | Resumo curto para compartilhamento |
| createdAt | DateTime | Data de criação |

---

## Layout Mobile

```
┌──────────────────────────────┐
│ AppBar (Glass)               │
│ ← Back          [Compartilhar]│
├──────────────────────────────┤
│ Metadata Badges              │
│ [CATEGORIA] [SCORE: 85]      │
│ [SUB_CATEGORIA] [MUNDO]      │
├──────────────────────────────┤
│ Title                        │
│ "Título Grande do Post"      │
│ (32sp bold italic uppercase) │
├──────────────────────────────┤
│ Source + Date                │
│ FONTE: TechCrunch · 01/06   │
├──────────────────────────────┤
│ ── Separator ──              │
├──────────────────────────────┤
│ Content                      │
│ Texto completo do post       │
│ (ou summary como fallback)   │
│ ...                          │
├──────────────────────────────┤
│ ── Separator ──              │
├──────────────────────────────┤
│ WhatsApp Summary (se houver) │
│ ┌──────────────────────────┐ │
│ │ 📱 RESUMO_WHATSAPP       │ │
│ │ Texto curto para share   │ │
│ │ [📋 Copiar] [📤 Share]   │ │
│ └──────────────────────────┘ │
├──────────────────────────────┤
│ Theme Config (se houver)     │
│ DNA: futuristic_tech         │
│ PROMPT: "..."                │
├──────────────────────────────┤
│ CTA Button                   │
│ [🔗 LER FONTE ORIGINAL]     │
├──────────────────────────────┤
│ Footer                       │
└──────────────────────────────┘
```

---

## Componentes

### 1. Metadata Badges Row

Badges horizontal scrollable com informações do post:

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      FNBadge(label: post.category, color: getCategoryColor(post.category)),
      SizedBox(width: 8),
      FNBadge(label: 'SCORE: ${post.score}'),
      SizedBox(width: 8),
      FNBadge(label: post.subCategory),
      SizedBox(width: 8),
      FNBadge(label: post.world),
    ],
  ),
)
```

### 2. Content Section

- Texto completo formatado
- Usa `post.content` se disponível, senão `post.summary`
- Estilo: texto em 16sp, line-height 1.6, cor `muted-foreground`
- Se muito longo, não tentar truncar — scroll natural

### 3. WhatsApp Summary Card

- Container glass com borda primária
- Ícone 📱 + "RESUMO_WHATSAPP"
- Texto resumido otimizado para share
- Dois botões:
  - **Copiar**: copia para clipboard com feedback "Copiado!"
  - **Compartilhar**: abre share sheet nativo com `Share.share(text)`

### 4. CTA — Fonte Original

- Botão full-width com ícone de link
- Ao clicar: `launchUrl(Uri.parse(post.url))` — abre no browser

### 5. Share Action (AppBar)

```dart
IconButton(
  icon: Icon(LucideIcons.share2),
  onPressed: () {
    final text = post.whatsappSummary ?? post.summary ?? post.title;
    Share.share('${post.title}\n\n$text\n\nLeia mais: ${post.url}');
  },
)
```

---

## Tracking

Ao abrir a tela, registrar o clique para alimentar o motor de afinidades:

```dart
@override
void initState() {
  super.initState();
  // Registrar tracking se houver subscriber logado
  final subscriberId = ref.read(subscriberIdProvider);
  if (subscriberId != null) {
    ref.read(trackingRepositoryProvider).trackClick(
      subscriberId: subscriberId,
      category: post.category,
    );
  }
}
```

======================================================================

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
- O arquivo de providers de arquivo em `mobile/lib/features/archive/application/archive_providers.dart`.
- O card de post em `mobile/lib/features/archive/presentation/widgets/post_card.dart` suportando afinidades e cores de categorias.
- A tela do arquivo histórico em `mobile/lib/features/archive/presentation/archive_screen.dart`.
- O provider de detalhes da newsletter em `mobile/lib/features/newsletter_detail/application/newsletter_detail_provider.dart`.
- O simulador de debate em `mobile/lib/features/newsletter_detail/presentation/widgets/terminal_debate.dart`.
- A tela de detalhes da newsletter em `mobile/lib/features/newsletter_detail/presentation/newsletter_detail_screen.dart` com os blocos e ações admin.
- A tela de detalhes de posts em `mobile/lib/features/post_detail/presentation/post_detail_screen.dart` com o WhatsApp Summary Card e chamada de tracking.
