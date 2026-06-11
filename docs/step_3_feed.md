# 📱 Step 3: Feed Principal & Chameleon Theme

> **Módulo:** Feed de Notícias & Seletor de Mundos  
> **Status:** 🟢 Concluído  
> **Responsável:** Lan & Antigravity  
> **Data de Início:** 11/06/2026 | **Data de Conclusão:** 11/06/2026

---

## 📝 Instruções para o Grupo
Edite as seções abaixo para descrever como a IA deve construir a tela de Feed (Home) com o seletor de mundos e a reatividade de cores do Chameleon Theme.

---

## 🎯 Requisitos de Negócio
- Carregar os posts da tabela `posts` do Supabase onde `status = 'published'`.
- Implementar o **World Selector** (botão de alternância destacado no topo) para alternar entre os mundos `TECH` e `MUSIC`.
- O feed deve carregar apenas as notícias correspondentes ao mundo ativo e respeitar a ordenação por pontuação (`score`) ou data de publicação.
- Implementar pull-to-refresh para buscar novas publicações.

---

## 🎨 Requisitos de Design
- **Chameleon Theme Reativo**: O aplicativo deve mudar suas cores de destaque baseando-se no mundo selecionado ou na categoria do post em foco na tela:
  - Destaques e botões mudam conforme o mundo ativo e categorias selecionadas (verde neon para TECH, vermelho/ouro/roxo para MUSIC e suas subcategorias).
- Layout de feed brutalista: os posts devem ser renderizados dentro de "cards" com bordas pretas grossas de 2.5px, sombras duras e tipografia Space Grotesk destacada.

---

## 💬 [PROMPT PARA A IA - EXECUTADO]
> "Implemente o feed de notícias principal em `/features/home/presentation/home_screen.dart` com um seletor de mundos no topo. Integre com o Supabase para carregar posts de 'TECH' ou 'MUSIC'. Adicione suporte ao Chameleon Theme, onde a cor do tema se adapta ao mundo ativo (verde para TECH e variantes de vermelho/roxo/dourado para categorias de MUSIC). Crie cards brutalistas com sombras sólidas pretas e bordas grossas."

---

## 🤖 Instruções para a Execução da IA
1. Ler este arquivo e extrair o prompt da seção acima.
2. Criar a feature `feed` em `/mobile/lib/features/feed/` com a estrutura Feature-First padrão.
3. Desenvolver o gerenciador do Chameleon Theme em `/mobile/lib/shared/theme/` usando `ChangeNotifier` / `Provider` para propagar a mudança de cor global no app quando o mundo ou categoria ativa mudar.
4. Implementar a query de posts no Supabase conectada ao estado do feed.
5. Criar os componentes UI brutais (cards de posts, cabeçalho de multiverso, botões de ação do feed).
6. Adicionar suporte a scroll infinito ou pull-to-refresh.
