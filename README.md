# 📱 Fresh News — Aplicativo Mobile (Flutter)

Este é o repositório do aplicativo móvel **Fresh News**, desenvolvido com **Flutter** para plataformas Android e iOS. O aplicativo traz a experiência brutalista hacker de curadoria de conteúdo e debate de inteligências artificiais diretamente para os dispositivos móveis.

---

## 🏗️ Arquitetura do Projeto

O projeto adota uma arquitetura estruturada baseada em **Feature-First** (Funcionalidades) integrada ao **Riverpod** para gerenciamento de estado e injeção de dependências.

```
docs/               # Documentação de arquitetura, padrões de código, ADRs e histórico (Logs)
lib/
  ├── app/                  # Configurações globais de roteamento (GoRouter) e App Widget
  ├── core/                 # Componentes compartilhados, constantes, serviços globais e rede
  │     ├── constants/      # Constantes estáticas e configurações de mundos (Mundos TECH/MUSIC/GEAR/GAME)
  │     ├── network/        # Inicializadores e clientes de API/Supabase
  │     ├── providers/      # Provedores de estado compartilhados
  │     ├── services/       # Serviços como Firebase Cloud Messaging (FCM) e Notificações Locais
  │     ├── theme/          # Sistema de Tema Brutalista e Efeitos (Chameleon Theme, Scanlines)
  │     └── utils/          # Helpers utilitários gerais
  ├── features/             # Módulos de funcionalidades de negócios independentes
  │     ├── admin/          # Painel Administrativo de Curadoria & Geração de Edições
  │     ├── archive/        # Listagem de Edições Anteriores (Newsletters)
  │     ├── auth/           # Login Administrativo e Magic Link de Assinantes
  │     ├── home/           # Feed de Notícias Principal com Seletor de Multiverso
  │     ├── newsletter_detail/# Detalhamento de Edições e Leitor Imersivo de Newsletter
  │     ├── post_detail/    # Visualização de Artigos Isolados
  │     ├── preferences/    # Gestão de Tópicos de Interesse e Gráficos de Afinidade (ML Reativo)
  │     ├── subscribe/      # Fluxo de Inscrição na Plataforma
  │     ├── unsubscribe/    # Tela de Desinscrição e Gestão de Cancelamento
  │     └── world_selector/ # Alternância de Mundos Remotos
  └── shared/               # Recursos reutilizáveis compartilhados entre múltiplos módulos
        ├── domain/         # Modelos de Domínio do Negócio (Post, Newsletter, Subscriber)
        ├── infrastructure/ # Repositórios concretos integrados ao Supabase e Tracking local
        └── widgets/        # Elementos de UI Brutalistas (Bordas grossas, botões sem cantos redondos)
n8n_workflows/      # Pipelines automatizados do n8n para delivery multiplataforma (E-mail e WhatsApp)
```

---

## 🎨 Design System (Brutalismo Camaleão)

O design visual é o diferencial estético do aplicativo, baseado em layouts retro-futuristas:
1. **Tipografia Brutal**: Uso proeminente da fonte **Space Grotesk** para cabeçalhos e elementos de texto.
2. **Bordas & Sombras Rígidas**: Sem cantos arredondados suavizados (`BorderRadius.zero` ou raio máximo de 4px) e bordas sólidas pretas grossas de `2.5px`, acompanhadas de sombras projetadas duras sem desfoque.
3. **Chameleon Color Theme**: O tema do aplicativo se adapta dinamicamente às cores do mundo e da categoria selecionados:
   - **Mundo TECH**: Verde Neon (`#22C55E`)
   - **Mundo MUSIC**: Dourado Hip-Hop (`#EAB308`) com variações dinâmicas de categoria.
   - **Mundo GEAR**: Vermelho Automotivo (`#EF4444`)
   - **Mundo GAME**: Roxo Arcade (`#A855F7`)
4. **Efeito Scanline Retro**: Um overlay translúcido de linhas de varredura de TV CRT analógica sobre o feed do aplicativo para reforçar o visual hacker.
5. **Feedback Tátil**: Vibrações rápidas em toques e interações do usuário.

---

## 🛠️ Tecnologias & Bibliotecas Utilizadas

* **Flutter SDK**: `v3.4.0` ou superior.
* **Supabase Flutter (`supabase_flutter`)**: Banco de dados relacional remoto, gerenciamento de sessões, uploads binários via Storage e Magic Links.
* **Riverpod (`flutter_riverpod` / `riverpod_annotation`)**: Gerenciamento de estado declarativo, reativo e injeção de dependências.
* **GoRouter (`go_router`)**: Roteamento baseado em URLs declarativas com suporte a redirecionamentos condicionais, deep linking e caminhos parametrizados.
* **Firebase Core / FCM (`firebase_messaging` / `firebase_core`)**: Serviços de mensagens e notificações push em segundo plano.
* **Flutter Local Notifications (`flutter_local_notifications`)**: Exibição de alertas visuais de push locais e manipulação de payloads de clique.
* **Flutter Animate (`flutter_animate`)**: Micro-animações e transições brutalistas de UI.
* **Image Picker / Compress (`image_picker` / `flutter_image_compress`)**: Captura e compressão automatizada de imagens para WebP antes do envio ao Supabase.

---

## 🚀 Principais Módulos do Sistema

1. **Autenticação & Magic Link**: Login simples para leitores através do Supabase Auth que envia um link direto para a caixa de e-mail do usuário. Ao clicar no link, o GoRouter processa o token do Deep Link e autentica o usuário de forma integrada.
2. **Unsubscribe & Configurações**: Dashboard para gerenciar preferências de leitura de subcategorias e mundos. Inclui uma "Zona de Perigo" brutalista para cancelamento direto da assinatura do serviço.
3. **ML Reativo Local**: Gravação de cliques do assinante localmente e envio de estatísticas para recalcular dinamicamente as categorias favoritas baseadas no histórico de leitura recente (últimos 30 acessos), ilustrado no perfil em um gráfico de barras brutalista.
4. **Painel do Debate das IAs**: Na tela de detalhes da newsletter, exibe-se um painel interativo ("Bastidores do Debate") mostrando o debate de curadoria das IAs especialistas formatado como balões de chat brutalistas com as cores personalizadas de cada especialista de IA.
5. **Painel de Administração (Curador/Editor)**: Interface administrativa com duas abas:
   - **Curadoria**: Visualização de rascunhos de posts, métricas gerais de cliques e moderação.
   - **Edições**: Lançamento manual de novas edições integrando upload de fotos da galeria, compressão automática em WebP e geração automatizada de posts e newsletters.

---

## 💻 Como Rodar o Projeto

### Pré-requisitos
Certifique-se de ter o Flutter instalado e configurado em seu ambiente de desenvolvimento. Para obter as restrições estritas e versões exatas dos SDKs suportados no projeto, consulte [docs/21_VERSOES_E_REQUISITOS_BUILD.md](docs/21_VERSOES_E_REQUISITOS_BUILD.md).

### Passos de Execução
1. Clone este repositório e navegue até a pasta raiz:
   ```bash
   cd freshnews_mobile
   ```
2. Obtenha as dependências do pub:
   ```bash
   flutter pub get
   ```
3. Crie e configure o arquivo `.env` na raiz do projeto contendo as chaves do Supabase:
   ```env
   SUPABASE_URL=https://sua-url.supabase.co
   SUPABASE_ANON_KEY=seu-anon-key
   ```
4. Gere as classes e geradores automáticos do Riverpod utilizando o `build_runner`:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Inicie o aplicativo em um emulador ou dispositivo físico conectado:
   ```bash
   flutter run
   ```

### Executar Testes
Para executar a suíte de testes unitários e de widgets do aplicativo:
```bash
flutter test
```
