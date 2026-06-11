# 📱 Step 2: Autenticação, Cadastro & Preferências

> **Módulo:** Autenticação & Cadastro de Preferências  
> **Status:** 🟢 Concluído  
> **Responsável:** Lan & Antigravity  
> **Data de Início:** 11/06/2026 | **Data de Conclusão:** 11/06/2026  

---

## 📝 Instruções para o Grupo
Edite as seções abaixo para descrever como a IA deve construir a tela de login, o cadastro e a tela de preferências do usuário sincronizadas com o Supabase.

---

## 🎯 Requisitos de Negócio
- Implementar tela de autenticação (Magic Link ou login convencional por e-mail/senha, conforme definido no prompt do grupo) integrada com o `SupabaseAuth`.
- Redirecionar novos usuários para uma tela de onboarding/preferências.
- Implementar a tela de preferências onde o usuário pode:
- Ativar/desativar mundos (`TECH` e `MUSIC`).
- Escolher subcategorias de interesse (ex: IA, Segurança, Hip-Hop, Rock/Indie).
- Sincronizar as preferências diretamente com a tabela `subscribers` no Supabase (colunas `preferences`, `active_worlds` e `phone`).

---

## 🎨 Requisitos de Design
- Tela de login limpa, com estilo brutalista marcante: caixa de texto com bordas pretas de 2.5px, botão de login largo com cor de preenchimento chamativa (ex: verde neon ou amarelo) e efeito de clique rígido.
- Seletor de preferências usando checkboxes ou botões do tipo toggle brutalistas retos.

---

## 💬 [PROMPT PARA A IA - EXECUTADO]
> "Crie o login do assinante (`SubscriberAuthScreen`) via Supabase Auth enviando Magic Link por e-mail. Trate o callback do deep link para autenticação e redirecionamento. Desenvolva o `preferencesProvider` e a tela `PreferencesScreen` integrada com o Supabase para persistir as preferências do leitor (mundos ativos, subcategorias e número de telefone) com estilo brutalista marcante."

---

## 🤖 Instruções para a Execução da IA
1. Ler este arquivo e extrair o prompt da seção acima.
2. Criar a feature `auth` em `/mobile/lib/features/auth/` com os subdiretórios de apresentação (`presentation/`), domínio/regras (`domain/`) e dados (`infrastructure/`).
3. Implementar a lógica de integração com o `supabase_flutter` para login e atualização de preferências do usuário.
4. Implementar os widgets de interface da tela de Login e tela de Preferências no estilo brutalista.
5. Garantir o tratamento adequado de erros (e-mail inválido, erro de conexão) exibindo alertas brutalistas na interface.
6. Atualizar a navegação no `main.dart` para gerenciar o estado da sessão de usuário (`onAuthStateChange`).
