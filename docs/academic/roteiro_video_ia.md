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
Navegue até a aba inferior de "Perfil" e clique no botão de "Preferências". Role até a seção de "Categorias de Interesse". Deixe claro que nada está marcado e que o gráfico "Seu Perfil de Leitura" não aparece por falta de dados.

**[Fala do Roteiro]**
"Vejam que aqui na tela de Preferências, a minha seção de Categorias de Interesse está vazia. Eu não marquei nada explicitamente. Na maioria dos apps, eu receberia um conteúdo genérico por causa disso, sem qualquer personalização."

---

## 🎬 Cena 3: A Entrada de Dados Silenciosa (Dwell Time & Cliques) (Tempo estimado: 45s)

**[Ação na Tela]** 
Volte para a Home e abra uma Edição da Newsletter.
Role a tela até achar uma seção de notícias chamada "IA".
Fique com a tela parada nessa seção por **pelo menos 15 a 20 segundos** para ultrapassar o limiar de scroll rápido. 
Em seguida, clique na opção de "Ler fonte original" da notícia de IA.

**[Fala do Roteiro]**
"Para resolver isso, implementamos Filtragem Baseada em Conteúdo com Telemetria Implícita. Enquanto eu leio esta notícia de IA, o frontend em Flutter monitora a visibilidade usando a classe `VisibilityDetector`. Se eu ficar pelo menos 12 segundos, o app envia o 'Dwell Time' (tempo de leitura) com pesos proporcionais. Como estou aqui há mais de 15 segundos, o app registrará um peso de leitura normal."

*(Faça o clique na fonte original)*
"Agora, vou clicar em 'Ler fonte original'. Isso dispara um clique que envia um sinal de conversão forte com peso máximo para o banco."

---

## 🎬 Cena 4: O Processamento (Back-end e Trigger SQL) (Tempo estimado: 20s)

**[Ação na Tela]** 
Volte para o aplicativo e se prepare para navegar até a tela de preferências.

**[Fala do Roteiro]**
"Esses sinais brutos de telemetria são disparados para a tabela `user_reading_signals` no Supabase. No banco de dados, criamos um Trigger PostgreSQL que intercepta a inserção e aplica a fórmula de Média Móvel Exponencial (EMA), atualizando em tempo real o Vetor de Afinidade (Affinity Vector) no JSONB do usuário com um fator de peso de 30% para a ação atual e 70% para o histórico."

---

## 🎬 Cena 5: Explainable AI, Gráficos e Feed Dinâmico (Tempo estimado: 45s)

**[Ação na Tela]** 
Navegue até a aba "Perfil -> Preferências". 
Mostre a barra de progresso no painel "SEU PERFIL DE LEITURA" mostrando a porcentagem de leitura em IA.
Role até "Categorias de Interesse": a categoria "IA" estará com o ícone de brilhinho (✨).
Volte para a Home e reabra a edição: a categoria "IA" agora aparece no topo com a tag ✨ *Baseado no seu perfil*.

**[Fala do Roteiro]**
"Vejam a mágica na tela de Preferências! Primeiro, a seção 'SEU PERFIL DE LEITURA' agora exibe um gráfico de barras com a porcentagem exata das minhas interações. Segundo, a categoria de 'IA' foi selecionada automaticamente com esse ícone de brilho mágico (✨). É o nosso modelo de 'Explainable AI': o app explica de forma transparente que notou o nosso interesse baseado no comportamento de leitura. Se o usuário quiser, ele tem a liberdade de desmarcar."

*(Abra a newsletter na Home e mostre a ordenação)*
"Para coroar a experiência, as seções da newsletter foram reordenadas dinamicamente: a categoria de IA subiu para o topo do feed acompanhada do selo 'Baseado no seu perfil'. Eliminamos o Cold Start de forma fluida, ética e totalmente controlada pelo leitor. Obrigado pela atenção!"
