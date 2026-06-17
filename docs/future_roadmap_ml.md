# 🧠 Roadmap de Personalização ML (Fresh News)

Este documento centraliza as ideias de como utilizar a base de dados de telemetria implícita (Dwell Time, Cliques) que já é alimentada pela tabela `user_reading_signals` para criar uma experiência de usuário ultra-personalizada e imersiva.

## 🌟 O Próximo Grande Passo Escolhido: Mutação Definitiva de UI (Evolução Camaleão)

A decisão para a próxima fase arquitetural é expandir o efeito "Camaleão" de um estado transitório (ativado durante a leitura) para um **estado permanente e formador de identidade**. 

### O Conceito
Em vez do aplicativo possuir um "Dark Mode" genérico, a interface completa (Home Screen, Profile, Cards, Navigation Bar) irá gradualmente mutar e assumir a paleta de cores e os efeitos visuais (`terminal_glow`, `scanlines`, `cloud_compute_grid`) da **categoria mais consumida pelo usuário nos últimos 30 dias**.

### Como funcionaria a arquitetura:
1. **Extração de Perfil (Backend/Supabase):** 
   Uma view ou Edge Function no Supabase agregaria os `user_reading_signals` do usuário, identificando a `top_category` baseada na soma dos `weights` (pesos de dwell time e clicks).
2. **Distribuição (Frontend):** 
   No momento do login ou na inicialização, o app baixaria essa `top_category`.
3. **Injeção Global no Provider:** 
   O `chameleonThemeProvider` (que hoje responde ao scroll) teria um "Base State" ou "Idle State" atrelado à categoria favorita do usuário, e não mais uma cor estática cinza/preta genérica.

**Exemplo Prático:**
- **Leitor Fã de Cibersegurança (SEC):** Seu app inteiro teria nuances avermelhadas, textos de interface com `terminal_glow` vermelho e bordas agressivas.
- **Leitor Fã de Consoles (Game):** Seu app viveria imerso num grid de computação cibernética ciano/verde neon constante.

---

## 💡 Outras Ideações Futuras Registradas

Para registro histórico, abaixo estão os outros caminhos idealizados que podem ser explorados posteriormente.

### 1. Edições "Crossover" (Cross-World Discovery)
Geração automática de boletins (via n8n/LLMs) que cruzem os dois mundos favoritos do usuário. Exemplo: Se ele lê muito sobre *IA (Tech)* e *PRODUÇÃO (Music)*, o sistema gera uma matéria exclusiva como *"Como LLMs estão mudando estúdios indie"*.

### 2. O "Spotify Wrapped" Contínuo (Gamificação Tribal)
Um dashboard na aba "Perfil" onde o usuário vê sua verdadeira "Identidade Fresh News". O app mostra estatísticas como: *"Seu perfil é 70% Hacker e 30% Gearhead. Você está no top 5% dos leitores do Brasil na categoria Cibersegurança"*. 

### 3. Modulação de Tamanho (Anti-Fadiga)
O ML detecta padrões de queda brusca no *Dwell Time* (sintoma de fadiga de leitura ou pressa). Automaticamente, o backend (n8n) passa a entregar as edições desse usuário num modo *"TL;DR"* (textos condensados pela metade). Assim que o tempo de leitura dele volta a subir, os deep-dives originais retornam.

### 4. Notificações Push Cirúrgicas (Zero-Spam)
Cruzamento das notícias que acabaram de ser publicadas com a categoria "Top 1" dos usuários. Push enviado de forma ultra-segmentada. Ex: *"Saiu um deep-dive técnico novo sobre o Godot 4.0, que é a sua categoria favorita"*.
