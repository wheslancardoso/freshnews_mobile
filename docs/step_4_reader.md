# 📱 Step 4: Leitor Brutalista & Debate de IAs

> **Módulo:** Leitor Imersivo & Chat de Debate das IAs  
> **Status:** ⚠️ Concluído com Ressalvas (Pendente Chameleon Scroll Observer)  
> **Responsável:** Lan & Antigravity  
> **Data de Início:** 11/06/2026 | **Data de Conclusão:** 11/06/2026  

---

## 📝 Instruções para o Grupo
Edite as seções abaixo para descrever como a IA deve construir a tela de leitura de posts e a interface de visualização do chat/debate das IAs especialistas.

---

## 🎯 Requisitos de Negócio
- Ao clicar em um post do feed, abrir a tela de leitura detalhada.
- Exibir o título, conteúdo formatado, subcategoria, autor (ou fonte) e pontuação.
- Se o post fizer parte de uma edição de newsletter compilada que possui debate, exibir a seção **"Painel de Debate das IAs"**.
- Puxar o campo `debate_log` (formato JSON/Array) da tabela `newsletters` (ou posts vinculados) e renderizá-lo como uma conversa de chat entre as IAs especialistas que participaram da curadoria.

---

## 🎨 Requisitos de Design
- Layout de leitura imersivo, com tipografia grande e limpa para o corpo do texto (leitura confortável).
- **Debate de IAs**: Renderizar as mensagens das IAs como balões de chat brutalistas (caixas com borda preta sólida, fundos coloridos correspondentes às cores dos especialistas):
  - IA de Segurança: Borda e texto com destaque em vermelho/laranja.
  - IA de Cloud/Dev: Destaques em azul/ciano.
  - IA de Hip-Hop: Destaques em ouro/amarelo.
  - IA de Rock/Indie: Destaques em vermelho escuro.
- Cada IA deve ter seu avatar (ou iniciais em um círculo brutalista) e seu respectivo nome (ex: "Especialista em Criptografia", "Especialista em Hip-Hop").

---

## 💬 [PROMPT PARA A IA - EXECUTADO]
> "Crie a tela de leitura imersiva de posts e newsletters (`NewsletterDetailScreen`). Carregue o campo `debate_log` do Supabase e renderize as discussões de curadoria em um chat estilo retro brutalista com balões de conversa coloridos e estilizados de forma customizada para cada especialista de IA."

---

## 🤖 Instruções para a Execução da IA
1. Ler este arquivo e extrair o prompt da seção acima.
2. Criar a feature `reader` em `/mobile/lib/features/reader/`.
3. Desenvolver os componentes UI da tela de leitura com suporte a rolagem suave.
4. Implementar o widget de renderização do `debate_log`, mapeando cada item do JSON (IA remetente, mensagem, timestamp) para um balão de chat brutalista colorido.
5. Garantir que o Chameleon Theme se adapte à subcategoria do artigo que está sendo lido enquanto o usuário estiver nessa tela.

---

## ⚠️ Ressalva Importante (Chameleon Scroll Observer)
Atualmente o aplicativo altera o tema de forma global baseado no post inteiro ao abrir a tela. Contudo, para newsletters compostas (que trazem múltiplos tópicos na mesma edição), o aplicativo ainda não atualiza a cor reativamente à medida que o usuário rola a tela por cada assunto (Scroll Observer).
Para implementar isso no Flutter, consulte as diretrizes detalhadas de código e listeners no arquivo [step_3_chameleon_engine.md](file:///c:/Users/wheslan.quintanilha/Documents/freshnews_mobile/docs/step_3_chameleon_engine.md).
