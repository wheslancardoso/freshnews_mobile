# 📋 Checklist de Implementação — Fresh News Mobile

Este checklist resume todas as tarefas pendentes do projeto Fresh News Mobile com base nas especificações detalhadas do grupo. Marque os itens como `[x]` conforme forem desenvolvidos.

---

## 🔑 1. Autenticação & Sessão do Assinante
- [ ] Criar a tela de login de Assinante (`SubscriberAuthScreen` em `lib/features/auth/presentation/subscriber_auth_screen.dart`).
- [ ] Implementar envio de Magic Link via Supabase Auth em `AuthNotifier` (`lib/features/auth/application/auth_notifier.dart`).
- [ ] Tratar deeplink no GoRouter (`lib/app/router.dart`) para direcionar o assinante logado com sucesso para a tela de Onboarding/Preferências.
- [ ] Conectar a sessão ativa ao `subscriberIdProvider` em `lib/features/archive/application/archive_providers.dart` para substituir o valor hardcoded `null`.

---

## ⚙️ 2. Módulo 15 — Unsubscribe & Preferências (Telas de Consumo)
- [ ] Desenvolver a tela de cancelamento de assinatura (`UnsubscribeScreen` em `lib/features/unsubscribe/presentation/unsubscribe_screen.dart`).
- [ ] Criar o `preferencesProvider` para ler e salvar preferências de subcategorias e mundos ativos do assinante no Supabase (`lib/features/preferences/application/preferences_provider.dart`).
- [ ] Implementar a tela de preferências completa (`PreferencesScreen` em `lib/features/preferences/presentation/preferences_screen.dart`).
- [ ] Criar o `ProfileCard` com badge de status de assinatura e data de cadastro.
- [ ] Criar o widget `DangerZone` para cancelamento de assinatura direto pelo aplicativo com confirmação.
- [ ] Substituir os placeholders no GoRouter pelas novas telas.

---

## 📈 3. Módulo 12 — Tracking & ML Reativo
- [ ] Atualizar o `TrackingRepository` em `lib/shared/infrastructure/tracking_repository.dart`:
  - [ ] Implementar método de ML Reativo local `_recalculatePreferences(String subscriberId)` (recalcular top 3 categorias favoritas baseadas nos últimos 30 cliques e salvar no Supabase).
  - [ ] Implementar `getCategoryStats(String subscriberId)` para carregar estatísticas de leitura.
- [ ] Desenvolver o widget `ReadingStats` para exibir gráficos de afinidade de categorias em barras horizontais nas preferências do usuário.
- [ ] Integrar o disparo de `trackClick` na tela de leitura de newsletters (`NewsletterDetailScreen`).
- [ ] Integrar tracking no clique dos links externos "Ler fonte original".

---

## 🔔 4. Step 5 — Notificações Push & Polimento Visual
- [ ] Adicionar dependências no `pubspec.yaml` (`firebase_core`, `firebase_messaging` e `flutter_local_notifications`).
- [ ] Criar o `NotificationService` em `lib/core/services/notification_service.dart` para gerenciar permissões, tokens e push handlers.
- [ ] Sincronizar o token FCM do dispositivo com a coluna `fcm_token` da tabela `subscribers`.
- [ ] Configurar a inscrição em tópicos FCM (`fresh_news_all` e mundos selecionados) conforme alteração de preferências.
- [ ] Inicializar o Firebase e o serviço de notificação no `main.dart`.
- [ ] Implementar a navegação global por deeplink ao tocar em uma notificação para direcionar à `NewsletterDetailScreen`.
- [ ] Criar o overlay retro `ScanlineOverlay` (`lib/shared/widgets/scanline_overlay.dart`) e adicioná-lo sobre a tela de feed.
- [ ] Adicionar feedback tátil com `HapticFeedback.lightImpact()` ao tocar nos botões, switches e cards de posts.

---

## 🛡️ 5. Módulo 11 — Painel Administrativo
- [ ] Criar o `AdminShell` com tab bar customizada (`Curadoria` / `Edições`) em `lib/features/admin/presentation/admin_shell.dart`.
- [ ] Desenvolver a aba de curadoria (`AdminPostsScreen` em `lib/features/admin/presentation/admin_posts_screen.dart`) com métricas e lista de rascunhos.
- [ ] Desenvolver a aba de edições (`AdminNewslettersScreen` em `lib/features/admin/presentation/admin_newsletters_screen.dart`) com seletor de mundo e botão "Gerar Nova Edição".
- [ ] Desenvolver o card de administração complexo (`NewsletterCardAdmin` em `lib/features/admin/presentation/widgets/newsletter_card_admin.dart`):
  - [ ] Inputs inline para título, resumo, prompt de imagem, etc.
  - [ ] Integração com galeria do dispositivo, compressão de imagens em WebP e upload binário para o Supabase Storage.
- [ ] Substituir os placeholders administrativos no GoRouter.
