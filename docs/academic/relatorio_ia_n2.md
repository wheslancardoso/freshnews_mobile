# Relatório de Avaliação Prática de IA — N2

**Projeto:** FreshNews (Revista Digital Anti-Feed)
**Disciplina:** Fábrica de Software

---

## 1. Problema que a Funcionalidade Resolve
O aplicativo FreshNews foi construído com a filosofia de "Anti-Feed Infinito", oferecendo edições semanais curadas para combater a sobrecarga de informação (*infoxicação*). 

O principal problema que nossa IA resolve é o **Cold Start e a Fricção de Personalização**. Usuários raramente preenchem longos formulários de interesse no onboarding. Se o usuário não diz o que quer ler, o engajamento cai. A nossa funcionalidade resolve isso através de um **Perfil Transparente (Explainable AI)**, que mapeia silenciosamente os interesses do usuário sem exigir "likes" explícitos, e apresenta esses dados visualmente para que o usuário retenha o controle total sobre seus dados.

## 2. Modelos e Técnicas de IA Empregados
Foram empregadas três frentes de Inteligência Artificial e processamento inteligente no projeto:

### A) Filtragem Baseada em Conteúdo (Content-Based Filtering via Telemetria Implícita com EMA)
*   **Técnica:** Algoritmo de Média Móvel Exponencial Ponderada (*Exponential Moving Average - EMA*) em banco de dados para criação de um Vetor de Afinidade (*Affinity Vector*).
*   **Justificativa:** Optamos por não usar modelos pesados ou de caixa-preta no frontend. O cálculo matemático de média móvel via Trigger SQL (PostgreSQL) garante performance instantânea. O algoritmo avalia o "Dwell Time" (tempo de tela visível de cada categoria de notícias) e cliques em links originais para inferir o grau de interesse do leitor em uma taxonomia específica (ex: IA, DEV, Startups).
*   **Métrica de Pesos (Telemetria):**
    *   *Dwell Time < 12 segundos:* Descartado silenciosamente (scroll rápido).
    *   *Dwell Time entre 12s e 15s:* Peso `0.5` (leitura superficial).
    *   *Dwell Time entre 15s e 40s:* Peso `1.0` (leitura normal).
    *   *Dwell Time >= 40s:* Peso `1.5` (interesse alto).
    *   *Cliques no link "Ler fonte original" (link_click):* Peso `3.0` (forte sinal de conversão).
*   **Fórmula Matemática (Trigger SQL):**
    $$new\_score = (\alpha \times NEW.weight) + ((1.0 - \alpha) \times old\_score)$$
    Onde $\alpha = 0.3$ (peso de 30% para a interação mais recente e 70% para o histórico de afinidade do usuário). O vetor resultante é salvo em formato JSONB na tabela `subscribers`.

### B) Recomendação Reativa Híbrida (Top 3 por Contagem de Cliques)
*   **Técnica:** Algoritmo estatístico de frequência de cliques nos posts utilizando os últimos 30 registros históricos.
*   **Justificativa:** Complementa o vetor de afinidade fornecendo ao usuário estatísticas visuais diretas de cliques e refinando o campo de preferências explícitas do assinante.
*   **Funcionamento:** A classe `TrackingRepository` no Flutter envia cada clique de leitura do usuário para a tabela `user_clicks`. O sistema então recupera os últimos 30 cliques, calcula a frequência de cada categoria e atualiza o vetor `preferences` com o Top 3 categorias favoritas do usuário.

### C) Processamento de Linguagem Natural (LLM via API de Terceiros)
*   **Técnica:** Integração com APIs LLM (OpenAI/Anthropic) orquestrada pelo *n8n* no backend de curadoria.
*   **Justificativa:** O backend necessita consumir Feeds RSS densos e transformá-los em resumos no estilo brutalista do app. A utilização de LLMs via System Prompts especializados (Personas) garante precisão semântica, formatação de tom editorial conciso e saída estritamente estruturada em JSON para o banco de dados.

## 3. Integração e Fluxo da Aplicação

O fluxo da IA no aplicativo ocorre em tempo real de ponta a ponta:

1.  **Coleta de Sinais (Frontend):** 
    *   A classe `VisibilityDetector` no Flutter monitora exatamente quantos segundos uma categoria de notícias fica visível na tela (Dwell Time). Se a categoria sair da tela ou o usuário sair do app, o tempo acumulado é enviado via `recordDwellTime`.
    *   Cliques em `Ler fonte original` disparam o evento de clique associado à categoria via `recordLinkClick`.
2.  **Processamento (Backend/Database):**
    *   O aplicativo dispara os dados brutos para a tabela `user_reading_signals` no Supabase.
    *   Um **Trigger PostgreSQL** (`trg_process_reading_signal`) intercepta a inserção e aciona a função `process_reading_signal()`.
    *   A fórmula de EMA ponderada recalcula o `affinity_vector` e o salva diretamente no JSONB do usuário da tabela `subscribers`.
3.  **Explicação e Retorno (Explainable AI & Ordenação Dinâmica):**
    *   **Aba de Preferências:** O aplicativo lê o vetor `affinity_vector`. Se uma categoria possuir pontuação matemática de afinidade maior ou igual a **0.3** (`affinityScore >= 0.3`), a interface apresenta a tag como pré-selecionada marcada com um ícone de brilho mágico (✨), informando ao usuário que a IA detectou seu interesse. O usuário pode desmarcar a categoria quando desejar, dando-lhe soberania de dados.
    *   **Ordenação Dinâmica de Feed:** Na tela de detalhes da edição (`NewsletterDetailScreen`), as seções de notícias são ordenadas dinamicamente com base no `affinity_vector`. As categorias com maior afinidade aparecem primeiro. Se o score da categoria for `>= 0.3`, a seção recebe o selo ✨ *Baseado no seu perfil*, justificando visualmente ao leitor o porquê de aquela categoria estar no topo.
    *   **Estatísticas de Leitura:** Na tela de preferências, o widget `ReadingStats` faz uma chamada ao `TrackingRepository` para buscar o histórico de cliques do usuário em `user_clicks`, exibindo sob a seção "SEU PERFIL DE LEITURA" a porcentagem de leitura em cada assunto através de barras de progresso elegantes.

## 4. Limitações Observadas e Melhorias Futuras
**Limitações Atuais:**
*   O modelo de EMA (Nível 1) realiza o agrupamento por "Categorias" fixas. Isso significa que ele não compreende a semântica fina de *por que* o usuário leu o artigo, ele apenas sabe que a taxonomia do artigo era "IA", por exemplo.
*   Se o usuário deixar o celular desbloqueado sobre a mesa em uma notícia específica, o *Dwell Time* pode gerar um falso positivo de alto interesse, elevando o score da categoria indevidamente.

**Melhorias Futuras (Roadmap Nível 2):**
*   **Embeddings Textuais (pgvector):** Planeja-se utilizar a extensão `pgvector` do Supabase junto com a API de Embeddings da OpenAI. Em vez de categorias estáticas, calcularemos a *Similaridade de Cosseno* entre o embedding tridimensional dos artigos lidos e os novos artigos, permitindo uma recomendação matemática de altíssima precisão baseada estritamente no texto.
