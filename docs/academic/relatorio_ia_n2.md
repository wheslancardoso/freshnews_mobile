# Relatório de Avaliação Prática de IA — N2

**Projeto:** FreshNews (Revista Digital Anti-Feed)
**Disciplina:** Fábrica de Software

---

## 1. Problema que a Funcionalidade Resolve
O aplicativo FreshNews foi construído com a filosofia de "Anti-Feed Infinito", oferecendo edições semanais curadas para combater a sobrecarga de informação (*infoxicação*). 

O principal problema que nossa IA resolve é o **Cold Start e a Fricção de Personalização**. Usuários raramente preenchem longos formulários de interesse no onboarding. Se o usuário não diz o que quer ler, o engajamento cai. A nossa funcionalidade resolve isso através de um **Perfil Transparente (Explainable AI)**, que mapeia silenciosamente os interesses do usuário sem exigir "likes" explícitos, e apresenta esses dados visualmente para que o usuário retenha o controle total sobre seus dados.

## 2. Modelos e Técnicas de IA Empregados
Foram empregadas duas frentes de Inteligência Artificial no projeto:

### A) Filtragem Baseada em Conteúdo (Content-Based Filtering via Telemetria Implícita)
**Técnica:** Algoritmo estatístico de *Exponential Moving Average (EMA)* em banco de dados para criação de um Vetor de Afinidade (*Affinity Vector*).
**Justificativa:** Optamos por não usar algoritmos de caixa-preta pesados no frontend. O cálculo matemático de média móvel via Trigger SQL (PostgreSQL) garante performance instantânea. O algoritmo avalia o "Dwell Time" (tempo de tela visível) e cliques em links para inferir o grau de interesse do leitor em uma taxonomia específica (ex: IA, DEV, Startups).

### B) Processamento de Linguagem Natural (LLM via API de Terceiros)
**Técnica:** Integração com APIs LLM (OpenAI/Anthropic) orquestrada pelo *n8n* no backend de curadoria.
**Justificativa:** O backend necessita consumir Feeds RSS densos e transformá-los em resumos no estilo brutalista do app. A utilização de LLMs via System Prompts especializados (Personas) garante precisão semântica e formato JSON estrito para o banco de dados.

## 3. Integração e Fluxo da Aplicação

O fluxo da IA no aplicativo ocorre em tempo real de ponta a ponta:

1. **Coleta de Sinais (Frontend):** 
   - A classe `VisibilityDetector` no Flutter monitora exatamente quantos segundos uma categoria de notícias fica visível na tela (Dwell Time).
   - Cliques em `Ler fonte original` também disparam eventos de alta conversão.
2. **Processamento (Backend/Database):**
   - O aplicativo dispara os dados brutos para a tabela `user_reading_signals` no Supabase.
   - Um **Trigger PostgreSQL** intercepta a inserção e aciona a função `process_reading_signal()`.
   - A fórmula de EMA ponderada recalcula o `affinity_vector` e o salva diretamente no JSONB do usuário.
3. **Explicação e Retorno (Explainable AI):**
   - Ao abrir a aba de "Preferências", o aplicativo lê o vetor.
   - Se uma categoria ultrapassar o limiar de pontuação matemática (> 0.5), a interface **preenche automaticamente** o interesse na tela com um selo mágico (✨), informando ao usuário que a IA tomou aquela decisão.

## 4. Limitações Observadas e Melhorias Futuras
**Limitações Atuais:**
- O modelo de EMA (Nível 1) realiza o agrupamento por "Categorias" fixas. Isso significa que ele não compreende a semântica de *por que* o usuário leu o artigo, ele apenas sabe que a taxonomia do artigo era "Hardware", por exemplo.
- Se o usuário deixar o celular desbloqueado sobre a mesa, o *Dwell Time* pode gerar um falso positivo de alto interesse.

**Melhorias Futuras (Roadmap Nível 2):**
- **Embeddings Textuais (pgvector):** Planeja-se utilizar a extensão `pgvector` do Supabase junto com a API de Embeddings da OpenAI. Em vez de categorias estáticas, calcularemos a *Similaridade de Cosseno* entre o embedding tridimensional dos artigos lidos e os novos artigos, permitindo uma recomendação matemática de altíssima precisão baseada estritamente no texto.
