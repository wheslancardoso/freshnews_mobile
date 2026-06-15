# 🧠 Estratégia de Machine Learning: Recomendação por Afinidade

> **Status:** Planejado (não implementado)  
> **Requisito:** Projeto acadêmico — integração de ML/IA no app mobile.  
> **Data:** Junho/2026

---

## 1. Contexto e Problema

O FreshNews é uma revista digital com curadoria finita. O usuário **não navega por artigos soltos** — ele abre Edições Semanais (Newsletters) que contêm notícias agrupadas por categoria.

A estrutura de dados é hierárquica:

```
Newsletter (Edição #42)
  └── NewsletterContent
        ├── List<NewsCategory>     ← "IA", "Hardware", "Startups"
        │     └── List<NewsItem>   ← notícias individuais agrupadas
        ├── List<String> quickTakes
        └── List<DebateMessage> debateLog
```

**Desafio:** Como aplicar ML para personalização sem quebrar a filosofia "anti-feed-infinito" do app? O usuário não curte, não salva, não segue tags. Ele apenas lê.

---

## 2. A Solução: "Smart Highlights" (Destaques Inteligentes)

Todos os usuários continuam recebendo a mesma Edição da Semana. Porém, **dentro da edição**, o ML:

1. **Reordena** as categorias para que as de maior afinidade apareçam primeiro.
2. **Destaca** artigos com um badge brutalista `[ALTA AFINIDADE]`.
3. **Gera um resumo** opcional na Capa: _"Nesta edição, encontramos 3 artigos perfeitos para o seu interesse em IA."_

---

## 3. Coleta de Sinais Implícitos (Telemetria)

Em vez de pedir interação explícita (curtir/salvar), capturamos **comportamento real de leitura**. Três sinais principais:

### 3.1 Tempo de Permanência por Categoria (Dwell Time)

O widget `VisibilityDetector` (já utilizado no projeto para o Chameleon Theme) registra **quanto tempo** cada `NewsCategory` ficou visível na viewport do usuário.

**Exemplo de registro:**

```json
{
  "user_id": "abc-123",
  "newsletter_id": "ed-42",
  "signals": [
    { "category": "IA",        "dwell_time_seconds": 45, "weight": 1.0 },
    { "category": "Hardware",   "dwell_time_seconds": 8,  "weight": 1.0 },
    { "category": "Startups",   "dwell_time_seconds": 32, "weight": 1.0 }
  ]
}
```

**Regras de peso:**
- `dwell_time < 5s` → Ignorar (passou rápido demais, não leu).
- `5s ≤ dwell_time < 15s` → Peso `0.5` (leitura superficial).
- `15s ≤ dwell_time < 40s` → Peso `1.0` (leitura normal).
- `dwell_time ≥ 40s` → Peso `1.5` (interesse alto — ficou relendo ou absorvendo).

### 3.2 Clique no Link Externo (Expansão de Artigo)

Cada `NewsItem` possui um campo `link` que abre o artigo completo no navegador. Um clique aqui é um **sinal fortíssimo** de interesse real, pois o usuário saiu do app para ler mais.

```json
{ "user_id": "abc-123", "category": "IA", "action": "link_click", "weight": 3.0 }
```

### 3.3 Scroll Depth (Profundidade de Leitura na Edição)

Se a edição possui 5 categorias e o usuário scrollou até a 3ª e voltou, as categorias 4 e 5 recebem um **sinal negativo implícito** (não necessariamente penalização, mas ausência de interesse).

```json
{
  "total_categories": 5,
  "max_category_reached": 3,
  "unseen_categories": ["Cloud", "Segurança"]
}
```

---

## 4. Construção do Perfil de Afinidade (User Affinity Vector)

### 4.1 Nível 1 — Feature Vector por Categorias (Recomendado para MVP)

A cada interação de leitura, acumulamos um **mapa de pesos por categoria**. O vetor é recalculado com média ponderada exponencial (dando mais peso a interações recentes):

```json
{
  "user_id": "abc-123",
  "affinity_vector": {
    "IA": 0.87,
    "Startups": 0.62,
    "Hardware": 0.23,
    "Segurança": 0.15,
    "Cloud": 0.41
  },
  "updated_at": "2026-06-15T22:00:00Z"
}
```

**Fórmula de atualização (Exponential Moving Average):**

```
novo_score = (alpha * score_sessao_atual) + ((1 - alpha) * score_anterior)
```

Onde `alpha = 0.3` (30% de peso para a sessão atual, 70% para o histórico acumulado). Isso evita que uma única sessão distorça o perfil.

**Técnica de ML:** Content-Based Filtering com Feature Vectors explícitos.

### 4.2 Nível 2 — Text Embeddings com pgvector (Evolução Futura)

Para uma personalização mais fina (baseada no **conteúdo textual** das notícias, não só na categoria):

1. Ativar a extensão `pgvector` no Supabase.
2. Ao aprovar um artigo no Admin, gerar um embedding do texto via OpenAI `text-embedding-3-small` (1536 dimensões).
3. Armazenar na coluna `embedding vector(1536)` da tabela de artigos/newsletters.
4. O "User Embedding" é a média ponderada dos embeddings dos artigos que o usuário consumiu com peso alto.
5. Usar **Similaridade de Cosseno** para ranquear artigos novos contra o perfil do usuário.

```sql
-- Exemplo: buscar artigos mais similares ao perfil do usuário
SELECT id, title, 1 - (embedding <=> user_embedding) AS similarity
FROM newsletter_items
WHERE newsletter_id = 'ed-43'
ORDER BY similarity DESC;
```

---

## 5. Tabelas no Supabase (Schema Proposto)

### 5.1 `user_reading_signals` (Coleta de Telemetria)

```sql
CREATE TABLE user_reading_signals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES subscribers(id),
  newsletter_id UUID NOT NULL REFERENCES newsletters(id),
  category TEXT NOT NULL,
  signal_type TEXT NOT NULL CHECK (signal_type IN ('dwell_time', 'link_click', 'scroll_depth')),
  value NUMERIC NOT NULL,        -- segundos para dwell_time, 1.0 para click, depth ratio para scroll
  weight NUMERIC NOT NULL,       -- peso calculado conforme regras da seção 3
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_signals_user ON user_reading_signals(user_id);
CREATE INDEX idx_signals_newsletter ON user_reading_signals(newsletter_id);
```

### 5.2 `user_affinity_profiles` (Perfil Calculado)

```sql
CREATE TABLE user_affinity_profiles (
  user_id UUID PRIMARY KEY REFERENCES subscribers(id),
  affinity_vector JSONB NOT NULL DEFAULT '{}',
  total_editions_read INT DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5.3 Extensão pgvector (Nível 2 — opcional)

```sql
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE newsletters ADD COLUMN embedding vector(1536);
ALTER TABLE user_affinity_profiles ADD COLUMN user_embedding vector(1536);
```

---

## 6. Fluxo Completo (Pipeline)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        COLETA (Flutter)                            │
│                                                                     │
│  VisibilityDetector  →  Dwell Time por NewsCategory                │
│  onTap(link)         →  Link Click por NewsItem                    │
│  ScrollController    →  Scroll Depth na edição                     │
│                                                                     │
│  Ao fechar a edição, envia batch para Supabase:                    │
│  supabase.from('user_reading_signals').insert(signals)             │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   PROCESSAMENTO (Supabase Edge Function)           │
│                                                                     │
│  1. Lê sinais do usuário                                           │
│  2. Calcula score por categoria (média ponderada exponencial)      │
│  3. Atualiza `user_affinity_profiles.affinity_vector`              │
│  4. (Nível 2) Recalcula `user_embedding` via média dos embeddings  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     PERSONALIZAÇÃO (Flutter)                       │
│                                                                     │
│  Ao abrir uma edição:                                              │
│  1. Puxa `affinity_vector` do perfil do usuário                    │
│  2. Compara com as categorias da edição                            │
│  3. Reordena categorias por score de afinidade                     │
│  4. Aplica badge [ALTA AFINIDADE] em artigos com score > 0.85     │
│  5. (Opcional) Gera texto na Capa: "3 artigos para você"           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 7. Impacto na UI (Flutter)

### 7.1 Badge de Alta Afinidade

Artigos com score acima de `0.85` recebem um container brutalista no estilo do app:

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: activeWorld.config.primaryColor,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: Colors.black, width: 2.0),
  ),
  child: Text('✨ ALTA AFINIDADE', style: FNTypography.techLabelSmall),
)
```

### 7.2 Reordenação Sutil

As categorias da edição são reordenadas antes da renderização:

```dart
final sorted = categories.toList()
  ..sort((a, b) {
    final scoreA = affinityVector[a.name] ?? 0.0;
    final scoreB = affinityVector[b.name] ?? 0.0;
    return scoreB.compareTo(scoreA);
  });
```

### 7.3 Texto Inteligente na Capa (Home)

Na Home (Hero Screen), um pequeno texto glassmorphism:

> _"Nesta edição, 2 artigos de IA combinam com o seu perfil."_

---

## 8. Justificativa Acadêmica

| Aspecto | Detalhe |
|---|---|
| **Tipo de ML** | Sistema de Recomendação — Content-Based Filtering |
| **Técnica (Nível 1)** | Feature Vectors explícitos + Média Ponderada Exponencial |
| **Técnica (Nível 2)** | Text Embeddings (OpenAI) + Cosine Similarity (pgvector) |
| **Coleta de dados** | Telemetria implícita (Dwell Time, Click, Scroll Depth) |
| **Diferencial** | Personalização sem Feed Infinito — reordena conteúdo finito |
| **Stack** | Flutter (coleta) → Supabase (armazenamento + processamento) → pgvector (similaridade vetorial) |

---

## 9. Referências Técnicas

- [pgvector — Supabase Docs](https://supabase.com/docs/guides/ai/vector-columns)
- [OpenAI Embeddings API](https://platform.openai.com/docs/guides/embeddings)
- [Content-Based Filtering — Google ML Course](https://developers.google.com/machine-learning/recommendation/content-based/basics)
- [Exponential Moving Average](https://en.wikipedia.org/wiki/Exponential_smoothing)
