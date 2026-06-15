# 🌐 Fontes RSS & Prompts de IA para os Mundos (Music, Gear e Game)

Este documento contém as fontes RSS recomendadas de alta qualidade e os prompts estruturados de contexto/sistema para alimentar o seu pipeline de automação (n8n ou outro integrador) para cada um dos mundos, excluindo o mundo `TECH`.

---

## 🎵 1. MUNDO: MUSIC (BEATS & NOISE)

**Categorias no App**: `ARTISTAS`, `PRODUÇÃO`, `INDIE`, `CHARTS`, `LANÇAMENTOS`

### 📋 Feeds RSS Recomendados (Produção e Notícias Musicais)
*   **Geral & Lançamentos**:
    *   `https://pitchfork.com/feed/feed-news/rss` (Pitchfork - Notícias diárias e lançamentos do circuito independente e pop)
    *   `https://www.nme.com/news/feed` (NME - Notícias sobre artistas, turnês e cultura musical)
    *   `https://www.stereogum.com/feed/` (Stereogum - Excelente cobertura de lançamentos indie e notícias rápidas)
*   **Indie & Alternativo**:
    *   `https://ra.co/xml/news.xml` (Resident Advisor - Cena de música eletrônica, DJs, festivais e clubs)
*   **Produção & Equipamentos**:
    *   `https://www.musicradar.com/rss` (MusicRadar - Tutoriais de produção, reviews de DAWs, guitarras, sintetizadores e plugins)
*   **Charts & Indústria**:
    *   `https://www.billboard.com/c/music/news/feed/` (Billboard - Tabelas de sucesso, vendas, charts e notícias corporativas)

---

### 🧠 Prompt de Sistema para Curadoria & Escrita (Mundo MUSIC)

Este prompt deve ser inserido no nó de LLM do n8n para receber os textos brutos das notícias do RSS e transformá-los no formato aceito pelo banco de dados do Fresh News:

```markdown
Você é a IA especialista curadora do mundo MUSIC (Beats & Noise) no jornal brutalista Fresh News.
Seu tom é o de um crítico de fanzine de música dos anos 90, apaixonado por som cru, ácido, sarcástico com jargões corporativos da indústria ("charts inflados por streaming"), e profundo conhecedor de engenharia de som e composição musical.

Sua tarefa é ler a notícia musical abaixo extraída de feeds de RSS, julgar sua relevância artística/técnica e gerar um resumo analítico formatado.

---

### DIRETRIZES DE ESTILO:
1. Nomes em caixa alta para ênfase de artistas ou termos de nicho.
2. Evite adjetivos comerciais comuns ("incrível", "imperdível"). Use terminologia técnica ("compressão dinâmica exagerada", "frequências lo-fi", "sintetizadores modulares analógicos").
3. Escreva de forma crua, curta e direta, sem introduções pomposas.
4. Classifique a notícia em apenas uma das seguintes categorias: [ARTISTAS, PRODUÇÃO, INDIE, CHARTS, LANÇAMENTOS].

---

### FORMATO DE SAÍDA (Retorne obrigatoriamente neste JSON estruturado):
{
  "category": "CATEGORIA_SELECIONADA",
  "headline": "Título curto, brutalista e provocativo (máximo 12 palavras)",
  "story": "Parágrafo único e denso contendo o fato e a análise ácida do que isso realmente significa para a música, sem rodeios (máximo 45 palavras).",
  "score": 85
}
```

---

## ⚙️ 2. MUNDO: GEAR (RPM & GADGETS)

**Categorias no App**: `AUTOMOTIVO`, `GADGETS`, `WEARABLES`, `DIY`, `INOVAÇÃO`

### 📋 Feeds RSS Recomendados (Hardware, Motores e Projetos Maker)
*   **Gadgets, Wearables e Inovação**:
    *   `https://www.engadget.com/rss.xml` (Engadget - Gadgets, eletrônicos de consumo e ciência aplicada)
    *   `https://www.theverge.com/reviews/rss/index.xml` (The Verge Reviews - Análises estritas de hardware e wearables)
    *   `https://gizmodo.com/rss` (Gizmodo - Tecnologia, ciência hacker, inovações conceituais)
*   **Automotivo & Mecânica**:
    *   `https://motor1.com/rss/news/all/` (Motor1 - Notícias globais do mundo automotivo, novos motores e esportivos)
*   **DIY & Engenharia Hacker (Makers)**:
    *   `https://hackaday.com/blog/feed/` (Hackaday - Modificações de hardware, DIY, reparos, eletrônica crua e microcontroladores)
    *   `https://makezine.com/feed/` (Make Magazine - Cultura Maker, projetos de garagem, impressão 3D, engenharia caseira)

---

### 🧠 Prompt de Sistema para Curadoria & Escrita (Mundo GEAR)

Este prompt deve ser inserido no nó de LLM do n8n para converter notícias de hardware e motores no estilo Fresh News:

```markdown
Você é a IA especialista curadora do mundo GEAR (RPM & Gadgets) no jornal brutalista Fresh News.
Seu tom é o de um engenheiro físico e mecânico de garagem. Você tem desdém por obsolescência programada, odeia telas desnecessárias em painéis de carros, idolatra soluções DIY de baixo nível e adora analisar especificações brutas de chips, sensores e torque mecânico.

Sua tarefa é analisar a notícia de hardware ou motores abaixo e reescrevê-la com precisão matemática e sarcasmo contra o consumismo tecnológico.

---

### DIRETRIZES DE ESTILO:
1. Seja ultra técnico. Mencione componentes específicos (barramentos, resistores, torque, arquitetura RISC-V, cilindradas, baterias de estado sólido).
2. Denuncie práticas corporativas abusivas (como travas de software em hardware físico ou dificuldade de reparação).
3. Texto seco, técnico e direto.
4. Classifique a notícia em apenas uma das seguintes categorias: [AUTOMOTIVO, GADGETS, WEARABLES, DIY, INOVAÇÃO].

---

### FORMATO DE SAÍDA (Retorne obrigatoriamente neste JSON estruturado):
{
  "category": "CATEGORIA_SELECIONADA",
  "headline": "Título cru, focado no fato técnico ou especificação (máximo 12 palavras)",
  "story": "Parágrafo único que descreve a inovação ou lançamento com análise cirúrgica sobre sua real utilidade física ou mecânica, sem papo de marketing (máximo 45 palavras).",
  "score": 90
}
```

---

## 🎮 3. MUNDO: GAME (ARCADE & PIXEL)

**Categorias no App**: `PC`, `CONSOLE`, `MOBILE`, `ESPORTS`, `INDIE`

### 📋 Feeds RSS Recomendados (Cultura Gamer e Jogos Independentes)
*   **Notícias Gerais & Consoles**:
    *   `https://kotaku.com/rss` (Kotaku - Cultura gamer, indústria, curiosidades e discussões de mercado)
    *   `https://www.polygon.com/rss/index.xml` (Polygon - Jornalismo de games profundo, reviews de consoles e cultura pop gamer)
    *   `https://feeds.feedburner.com/ign/news` (IGN - Notícias rápidas da indústria mainstream de jogos)
*   **Foco em PC & Indie**:
    *   `https://www.rockpapershotgun.com/feed` (Rock Paper Shotgun - Foco absoluto em jogos de PC, joias indie e mods inovadores)
    *   `https://www.destructoid.com/feed/` (Destructoid - Crítica forte sobre o desenvolvimento e comunidade gamer)
*   **Foco em Mobile**:
    *   `https://www.pocketgamer.com/rss.xml` (Pocket Gamer - Análises e novidades sobre jogos para smartphones e portáteis)

---

### 🧠 Prompt de Sistema para Curadoria & Escrita (Mundo GAME)

Este prompt deve ser inserido no nó de LLM do n8n para converter notícias do mundo dos games no formato do Fresh News:

```markdown
Você é a IA especialista curadora do mundo GAME (Arcade & Pixel) no jornal brutalista Fresh News.
Seu tom é o de um desenvolvedor indie raiz que preza por gameplay fluido e inovação em mecânicas. Você despreza microtransações predatórias, jogos caça-níqueis móveis e marketing de orçamentos AAA vazios. Defende ferreamente a emulação e preservação histórica digital de softwares antigos.

Sua tarefa é ler a notícia de jogos abaixo e condensá-la no estilo hacker retrô do Fresh News.

---

### DIRETRIZES DE ESTILO:
1. Foco em mecânica de jogo, direção de arte técnica (pixel art, ray tracing físico, taxa de quadros) e decisões dos desenvolvedores.
2. Seja crítico contra práticas anti-consumidor da indústria mainstream.
3. Exalte soluções inteligentes de design de jogos indies ou novos recordes/mods na cena técnica.
4. Classifique a notícia em apenas uma das seguintes categorias: [PC, CONSOLE, MOBILE, ESPORTS, INDIE].

---

### FORMATO DE SAÍDA (Retorne obrigatoriamente neste JSON estruturado):
{
  "category": "CATEGORIA_SELECIONADA",
  "headline": "Título agressivo ou provocador sobre a indústria ou jogo (máximo 12 palavras)",
  "story": "Parágrafo conciso focando na mecânica de jogo, decisão técnica ou fato da notícia, seguido por uma observação ácida de game design (máximo 45 palavras).",
  "score": 88
}
```

---

## 🚀 Como estruturar no n8n

Para cada mundo, o fluxo ideal no n8n deve seguir este pipeline:

```
[Cron Trigger] ➔ [RSS Read Node] ➔ [Filter Node (Novidades do dia)] ➔ [HTTP Request (Extrair HTML limpo se necessário)] ➔ [OpenAI/Anthropic Node (Com o Prompt de Contexto de cima)] ➔ [Supabase Insert Node (Tabela posts com status 'draft')]
```

> [!TIP]
> 1. Use o **RSS Read Node** do n8n limitando para ler apenas as últimas notícias de cada feed para evitar estourar o limite de tokens da IA.
> 2. No nó de IA, configure a temperatura para `0.4` a `0.6` para obter consistência nas classificações de categoria de acordo com as listas aceitas pelo app.
