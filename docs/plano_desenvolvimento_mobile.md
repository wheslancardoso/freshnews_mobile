# 📱 Plano de Desenvolvimento - Fresh News Mobile (Flutter)

Este documento centraliza o planejamento, requisitos e o checklist de tarefas para o desenvolvimento do aplicativo móvel nativo **Fresh News Mobile**, desenvolvido em **Flutter** para Android e iOS.

O plano foi ajustado para remover o leitor de debate de IAs de bastidores, mantendo o foco total na autenticação segura, feed multiverso, Chameleon Theme reativo, sincronização omnichannel de preferências e notificações push.

---

## 👥 Resumo de Arquitetura & Diretrizes de Design
- **Gerenciamento de Estado & DI:** Padrão **Provider** para reatividade local/global de telas e **GetIt** como localizador de serviços e injeção de dependência.
- **Conectividade:** Integração direta com a base de dados **Supabase** (tabelas `subscribers`, `posts` e `user_clicks`), aplicando **Row Level Security (RLS)** estrito.
- **Estética Brutalista (Digital Brutalism):** Dark mode profundo (`#000000`), raio de borda zero (`BorderRadius.zero`), tipografia de alto impacto (fonte **Space Grotesk**), linhas de contorno pretas grossas (`2.5px`) e sombras sólidas duras sem desfoque.
- **Chameleon Color System:** Adaptação visual dinâmica das cores de botões, realces e barras do aplicativo a partir dos valores HSL de `theme_config` retornados por post ou mundo ativo.

---

## 📋 Checklist de Implementação do Aplicativo

### 🚀 Fase 1: Setup Inicial, Dependências & Supabase Connection
*Esta fase compreende a inicialização física do projeto móvel e a configuração da estrutura arquitetural base.*

- [ ] **1.1 Inicialização do Projeto Flutter**
  - [ ] Criar o diretório do projeto no repositório com o comando `flutter create --org com.freshnews --project-name fresh_news ./mobile`.
- [ ] **1.2 Configuração de Dependências (`pubspec.yaml`)**
  - [ ] Adicionar `supabase_flutter` para conectividade e autenticação do banco de dados.
  - [ ] Adicionar `provider` para gerência de estados reativos globais.
  - [ ] Adicionar `get_it` para injeção e resolução de dependências.
  - [ ] Adicionar `google_fonts` para carregar a fonteSpace Grotesk de forma nativa.
  - [ ] Adicionar `flutter_dotenv` para carregar as variáveis de ambiente locais do Supabase.
- [ ] **1.3 Arquitetura de Pastas (Feature-First)**
  - [ ] Estruturar a árvore de diretórios em `/mobile/lib/`:
    - `features/auth/` (Cadastro, Login e Preferências)
    - `features/feed/` (Feed de notícias e World Selector)
    - `shared/theme/` (Chameleon Theme e Design System)
    - `shared/widgets/` (Botões brutalistas, cards e inputs genéricos)
    - `shared/services/` (Inicializador do Supabase e APIs)
- [ ] **1.4 Conexão com o Supabase**
  - [ ] Criar o arquivo `.env` contendo as chaves do Supabase (`SUPABASE_URL` e `SUPABASE_ANON_KEY`) obtidas das credenciais de produção.
  - [ ] Implementar a inicialização do Supabase no escopo da função `main()` do `main.dart`.
- [ ] **1.5 Inicialização do Design System Brutalista**
  - [ ] Criar utilitários de tema e paleta de cores brutalistas.
  - [ ] Configurar a fonte Space Grotesk como a tipografia padrão do `ThemeData`.
  - [ ] Garantir cantos completamente retos (`BorderRadius.zero`) e bordas sólidas de `2.5px` como padrão para os componentes globais do app.

---

### 🔑 Fase 2: Autenticação Segura & Sincronização de Preferências
*Implementação do cadastro de assinantes via Supabase Auth e o aprendizado comportamental do usuário.*

- [ ] **2.1 Feature de Autenticação (`features/auth`)**
  - [ ] Criar o repositório de autenticação (`auth_repository.dart`) para integração com o `SupabaseAuth`.
  - [ ] Desenvolver a tela de Login brutalista (`login_screen.dart`): entrada limpa de e-mail e botão com realce neon para envio de Magic Link para a caixa de entrada.
- [ ] **2.2 Gerenciamento de Onboarding & Preferências**
  - [ ] Desenvolver a tela de Ajustes de Preferências (`preferences_screen.dart`): painel de toggles para ativação de mundos (`TECH` e `MUSIC`) e subcategorias.
  - [ ] Implementar a sincronização dos dados diretamente na tabela `subscribers` do Supabase.
  - [ ] Tratar e exibir erros de conexão e credenciais com alertas com estilo retrô/brutalista.
- [ ] **2.3 Navegação e Estado de Sessão**
  - [ ] Configurar o fluxo de navegação no `main.dart` escutando o estado de sessão (`onAuthStateChange`) para redirecionar o usuário autenticado diretamente ao feed.
- [ ] **2.4 Aprendizado de Preferências (ML Reativo)**
  - [ ] Implementar o repositório de rastreamento (`tracking_repository.dart`) integrado à tabela `user_clicks`.
  - [ ] Desenvolver a lógica de gravação automática de cliques em posts e links de fonte em segundo plano (Feedback Implícito).
  - [ ] Criar a rotina reativa que calcula as Top 3 categorias baseada nas últimas 30 interações e grava no campo `preferences` do assinante no banco.
  - [ ] **Widget Exclusivo (Opcional):** Desenvolver um card de visualização de estatísticas de leitura para o assinante no painel de perfil.

---

### 🎨 Fase 3: Feed Principal por Mundo & Chameleon Theme
*Criação do visual reativo do feed com alternância dinâmica do multiverso (Música/Tech).*

- [ ] **3.1 Feature de Feed (`features/feed`)**
  - [ ] Criar repositório do feed (`feed_repository.dart`) para listar os posts publicados da tabela `posts`.
  - [ ] Desenvolver a tela de Feed Principal (`feed_screen.dart`): cards de artigos brutalistas contendo imagem, título em Space Grotesk, subcategoria e indicador de score.
  - [ ] Implementar scroll infinito e suporte a Pull-to-Refresh.
- [ ] **3.2 World Selector (Multiverso)**
  - [ ] Criar a barra de seleção no topo do feed para alternar entre os universos `TECH` e `MUSIC`.
  - [ ] Configurar a filtragem dos posts em tela conforme a seleção e ordenação por relevância/data.
- [ ] **3.3 Motor Visual do Chameleon Theme**
  - [ ] Desenvolver o gerenciador do Chameleon Theme (`ChameleonThemeNotifier` via Provider) para escuta e propagação global de cores HSL.
  - [ ] Configurar a alteração em tempo real do tema visual do aplicativo móvel (cores de destaques, barras e botões) dependendo do post em foco na tela ou do mundo ativo.

---

### 🔔 Fase 4: Notificações Push & Polimento Visual
*Configuração de alertas e refinamento estético do aplicativo móvel.*

- [ ] **4.1 Integração de Notificações Push**
  - [ ] Configurar o projeto Firebase no painel do desenvolvedor do Google/Apple.
  - [ ] Adicionar os SDKs do Firebase Cloud Messaging (FCM) no `pubspec.yaml` e as dependências nativas de Android e iOS.
  - [ ] Implementar a lógica de permissões e geração do token de dispositivo (`notification_service.dart`).
- [ ] **4.2 Sincronização de Token FCM**
  - [ ] Implementar a persistência do token do dispositivo físico na tabela `subscribers` do Supabase para direcionar as push notifications com base nas preferências comportamentais do usuário.
- [ ] **4.3 Polimento Visual Brutalista**
  - [ ] Adicionar overlay de scanline retro CRT nas telas de feed e leitura.
  - [ ] Configurar feedback tátil (`HapticFeedback.lightImpact`) para vibrações discretas em toques de botões e seletores.
  - [ ] Realizar auditoria visual geral do aplicativo garantindo cantos com raio zero e bordas sólidas pretas de 2.5px.
