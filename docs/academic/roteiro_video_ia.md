# Roteiro de Gravação — Vídeo da N2 (IA)

> **DICA:** Coloque este roteiro em um segundo monitor ou divida a tela. Leia de forma natural enquanto executa as ações no celular/emulador.

---

## 🎬 Cena 1: Introdução (Tempo estimado: 30s)

**[Ação na Tela]** 
Deixe o aplicativo aberto na Tela Inicial (Home).

**[Fala do Roteiro]**
"Olá, avaliadores. Sou integrante do projeto FreshNews, e hoje vou demonstrar a nossa funcionalidade de Inteligência Artificial implementada para a disciplina de Fábrica de Software. Nosso app lida com curadoria de notícias, e nós resolvemos atacar o problema do 'Cold Start', que é quando o usuário tem preguiça de selecionar o que ele gosta de ler."

---

## 🎬 Cena 2: Mostrando a Aba Preferências Limpa (Tempo estimado: 20s)

**[Ação na Tela]** 
Navegue até a aba inferior de "Perfil" e clique no botão de "Preferências". Role até a sessão de "Categorias de Interesse". Deixe claro que nada está marcado.

**[Fala do Roteiro]**
"Vejam que aqui na tela de Preferências, a minha seção de Categorias de Interesse está vazia. Eu não marquei explicitamente que gosto de Inteligência Artificial ou Desenvolvimento. Na maioria dos apps, eu receberia um conteúdo genérico por causa disso."

---

## 🎬 Cena 3: A Entrada de Dados Silenciosa (Dwell Time) (Tempo estimado: 40s)

**[Ação na Tela]** 
Volte para a Home (ou Arquivo) e abra uma Edição da Newsletter.
Role o dedo até achar uma sessão chamada "IA" ou "DEV". 
Fique com a tela parada nessa notícia por cerca de 10 a 15 segundos. Se quiser, clique em "Ler fonte original".

**[Fala do Roteiro]**
"Para resolver o problema, nós implementamos uma Filtragem Baseada em Conteúdo com Telemetria Implícita. Reparem que eu estou lendo essa notícia da categoria IA. Enquanto eu leio, o frontend em Flutter usa sensores de Visibilidade para calcular o meu 'Dwell Time', ou seja, o meu tempo de permanência na tela lendo esse assunto."

*(Faça o clique na fonte original)*
"Acabei de clicar no link para ler a notícia completa. Esse é o gatilho final de dados."

---

## 🎬 Cena 4: O Processamento (Back-end) (Tempo estimado: 20s)

**[Ação na Tela]** 
Mostre rapidamente a tabela `user_reading_signals` no painel do Supabase ou apenas mantenha a tela no app enquanto explica.

**[Fala do Roteiro]**
"Ao sair ou interagir com a notícia, esses sinais são enviados para o nosso banco de dados. Lá, utilizamos uma técnica de Média Ponderada Exponencial via Triggers do PostgreSQL. O algoritmo processa o meu tempo de leitura e os meus cliques, e magicamente recalcula um 'Vetor de Afinidade' (Affinity Vector) no banco, atualizando o meu perfil instantaneamente."

---

## 🎬 Cena 5: O Resultado e o Explainable AI (Tempo estimado: 30s)

**[Ação na Tela]** 
Volte para o aplicativo (se você saiu) e vá novamente até a aba "Perfil -> Preferências". 
Role até a seção "Categorias de Interesse". A tag de "IA" deverá estar marcada automaticamente, junto com o ícone de brilhinho (✨).

**[Fala do Roteiro]**
"A melhor parte é a transparência com a LGPD. Ao invés do algoritmo agir pelas sombras, olhem a nossa tela de Preferências agora. A categoria de 'IA' foi ativada sozinha, e o sistema colocou esse ícone de brilho. É o nosso modelo de 'Explainable AI' avisando ao usuário: *Nossa inteligência notou que você gosta disso*. Se o usuário não quiser, ele tem a liberdade de desmarcar. Assim, nós matamos o problema do Cold Start e entregamos um feed cirúrgico."

**[Ação na Tela]** 
Acene / agradeça.

**[Fala do Roteiro]**
"É isso. Agradeço a atenção, e o relatório completo detalha a nossa orquestração com LLMs para os resumos! Obrigado."
