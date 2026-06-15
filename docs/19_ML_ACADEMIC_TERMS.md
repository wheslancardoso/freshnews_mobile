# 📚 Guia de Estudos Acadêmicos: Técnicas de ML no FreshNews

> **Propósito:** Documentação de apoio para redação de relatórios, monografias e defesas acadêmicas sobre a integração de Inteligência Artificial e Machine Learning no projeto FreshNews.

---

## 1. Classificação Geral do Sistema

O motor de "Destaques Inteligentes" (Smart Highlights) do aplicativo é classificado na literatura acadêmica como um **Sistema de Recomendação (Recommender System)**.

Ao contrário da **Filtragem Colaborativa (Collaborative Filtering)** — que baseia recomendações no que *outros* usuários com perfil semelhante estão consumindo —, o FreshNews adota a **Filtragem Baseada em Conteúdo (Content-Based Filtering)**.

### Por que Filtragem Baseada em Conteúdo?
Porque a recomendação é feita comparando as **características inerentes do conteúdo** (ex: categorias, tags, ou o próprio texto da notícia) diretamente com o **perfil de afinidade** do usuário individual. 

---

## 2. Abordagem Nível 1: Vetores Estáticos (A abordagem atual)

Se a recomendação for implementada analisando as categorias (ex: "IA", "Hardware") em que o usuário passa mais tempo ou clica:

* **Técnica de Modelagem:** Representação Vetorial de Características (*Feature Vector Representation*). O gosto do usuário se torna um "Vetor Matemático" de categorias.
* **Técnica de Atualização de Perfil:** Média Móvel Exponencial (*Exponential Moving Average - EMA*). Usamos o EMA para dar mais peso às interações recentes do usuário, esquecendo gradualmente interesses antigos.
* **Coleta de Dados:** O sistema utiliza **Telemetria Implícita** (*Implicit Feedback*). Em vez de pedir notas ou avaliações diretas (Feedback Explícito), infere-se a preferência por métricas como *Dwell Time* (tempo de tela) e *Click-through* (taxa de cliques).

---

## 3. Abordagem Nível 2: Processamento de Linguagem Natural (A evolução)

Caso o sistema passe a analisar o *texto dos artigos* em vez de apenas a categoria, usando a extensão `pgvector` no banco de dados e APIs como a da OpenAI:

* **Técnica de Representação:** Representação Vetorial Densa (*Dense Embeddings*) usando modelos de **Processamento de Linguagem Natural (NLP)**. O modelo transforma o significado semântico do texto inteiro em um vetor de milhares de dimensões (ex: 1536 dimensões no OpenAI).
* **Técnica Matemática de Decisão:** Similaridade de Cosseno (*Cosine Similarity*). O banco de dados calcula o ângulo entre o vetor do artigo e o vetor do usuário. Quanto menor o ângulo (mais próximo de 1), maior a semelhança semântica entre a notícia e o que o usuário gosta.

---

## 4. Sugestão de Parágrafo para Relatórios

> *"Para a curadoria personalizada de conteúdo, o aplicativo utiliza um Sistema de Recomendação baseado em Filtragem de Conteúdo (Content-Based Filtering). O perfil de afinidade do usuário é modelado através de Vetores de Características (Feature Vectors), cujos pesos são atualizados dinamicamente a cada interação implícita na interface (Dwell Time e Scroll Depth) através de Média Móvel Exponencial. A recomendação final é gerada calculando a distância entre o vetor que representa o conteúdo da edição e o vetor atual de afinidade do leitor, preservando a experiência curada e evitando o engajamento vicioso do formato de feeds infinitos."*
