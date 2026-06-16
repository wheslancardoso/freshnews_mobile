# 20 · Contexto e Próximos Passos dos Workflows n8n (Fresh News)

Este documento registra o estado atual da integração entre os workflows do **n8n**, o banco de dados **Supabase** e o aplicativo mobile **Fresh News**, detalhando os problemas solucionados, as correções de segurança aplicadas e o roteiro de próximos passos para evolução do sistema de newsletters.

---

## 📖 1. Contexto Geral e Fluxo de Execução

O sistema de newsletters do **Fresh News** utiliza um pipeline híbrido composto por:
1. **Coleta e Triagem (n8n)**: Executado periodicamente via Cron.
   - Busca notícias em fontes RSS cadastradas no Supabase.
   - Utiliza **Firecrawl** para extrair o conteúdo completo do post/artigo.
   - Classifica e avalia a relevância por inteligência artificial (OpenAI).
   - Salva os posts no Supabase com status `pending`.
2. **Fechamento da Edição (n8n)**:
   - Coleta os posts classificados com status `pending` nos últimos 3 dias para o respectivo "mundo" (ex: GEAR).
   - Envia o compilado para a IA (OpenAI GPT) gerar a capa (Título, Teaser Editorial, Quick Takes, Mensagens de WhatsApp de saudação e despedida).
   - Insere o registro em `newsletters` e associa os posts participantes ao `newsletter_id` correspondente.
3. **Entrega (n8n)**:
   - Dispara e-mails via Resend utilizando os templates do sistema e mensagens via WhatsApp.

---

## 🛠️ 2. Histórico de Problemas Identificados e Solucionados

Durante as últimas iterações, foram resolvidos os seguintes pontos críticos:

### A. Vazamento de Credenciais (Leak de API Key do Resend)
* **Problema**: A chave de API do Resend (`re_A318WPGu...`) estava hardcoded e vazada em arquivos JSON de exportação de workflows do n8n que foram integrados ao repositório git.
* **Correção**: 
  - Realizou-se um rollback de commits.
  - O segredo foi removido de todos os arquivos do fluxo de trabalho:
    * `n8n_workflows/Test_Email_Workflow.json`
    * `n8n_workflows/FreshNews Delivery Pipeline (Email & WhatsApp).json`
    * `n8n_workflows/delivery_workflow.json`
  - Substituiu-se a chave pelo placeholder: `Bearer YOUR_RESEND_API_KEY`.
  - Foi efetuado um force-push limpo para o repositório GitHub.

> [!WARNING]
> É indispensável revogar a chave `re_A318WPGu_2VVwVUDndxPMK1a8cowJG3wY` imediatamente no painel do Resend e gerar uma nova chave para o ambiente.

### B. Incompatibilidade de Schema no Banco de Dados
* **Problema**: O fluxo do n8n falhava ao tentar inserir registros porque a tabela `newsletters` não possuía as colunas necessárias para o fluxo de WhatsApp, e os posts não possuíam vínculo formal com a newsletter gerada.
* **Correção**: Executadas alterações no banco de dados via Supabase para:
  - Adicionar as colunas `whatsapp_greeting` e `whatsapp_farewell` (tipo `TEXT`) na tabela `newsletters`.
  - Adicionar a coluna `newsletter_id` (tipo `UUID` referenciando `newsletters(id) ON DELETE SET NULL`) na tabela `posts`.

### C. Ajuste e Qualidade das Fontes RSS (Mundo GEAR)
* **Problema**: O mundo GEAR estava poluído com notícias de projetos DIY (Arduino, Adafruit, Hackster.io), gerando newsletters desalinhadas do foco de motores, F1, engenharia automotiva e tecnologia de performance.
* **Correção**:
  - Atualização do seed sql em `docs/deep research/supabase_sources_seed.sql`.
  - Atualização direta no Supabase para remover fontes DIY de baixa relevância e adicionar feeds de alta qualidade: *Autosport, Motorsport.com, The Drive, Jalopnik, Car and Driver, Motor1 BR, Grande Prêmio* e *Racecar Engineering*.

### D. Título Padrão ("Fresh News Edição") e Ausência de Resumo Editorial
* **Problema**: A edição do mundo GEAR chegava ao app sempre com o título genérico fixo e sem o resumo editorial gerado pela IA. A IA respondia com instruções em vez do conteúdo consolidado da newsletter.
* **Correção**:
  - **Uso de Expressões no n8n**: O nó "IA: Editor de Fechamento" continha `{{ $json.content_to_read }}` na mensagem de Sistema, mas sem o caractere `=` no início do campo, fazendo o n8n interpretar o valor como uma string literal. Foi adicionada a atribuição correta baseada em expressões (`={{ ... }}`).
  - **Estrutura de Retorno do OpenAI no n8n**: Nós LangChain OpenAI retornam a resposta da IA aninhada em `output[0].content[0].text`. Ajustou-se o código JavaScript do nó "Montar content_json" para mapear dinamicamente e tratar essa resposta da IA, extraindo o JSON de forma robusta por expressão regular:
    ```javascript
    let aiText = "";
    if ($json.output && Array.isArray($json.output) && $json.output[0] && $json.output[0].content) {
      aiText = $json.output[0].content[0].text || "";
    } else {
      aiText = $json.text || $json.content || "";
    }
    ```

### E. Janela de Acúmulo de Notícias (Fórmula de Data)
* **Problema**: A expressão `{{ $now.minus({days: 3}) }}` falhava em filtrar notícias dos últimos 3 dias no nó do Postgres devido a limitações da versão local do n8n.
* **Correção**: Substituição pela expressão padrão do JavaScript para determinar o timestamp de 3 dias atrás:
  `{{ new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString() }}`

---

## 🚀 3. Próximos Passos e Recomendações

### 1. Rotação da Chave do Resend
* **Ação**: Criar uma nova API Key no console do Resend.
* **Onde atualizar**: No n8n, dentro das credenciais HTTP Header / Bearer Token associadas aos nós de envio de e-mail dos workflows `delivery_workflow.json` e `FreshNews Delivery Pipeline (Email & WhatsApp).json`.

### 2. Geração de Imagem de Capa para a Newsletter
* **Ação**: Implementar a geração automatizada de imagens de capa que representam visualmente a edição ("Mundo") gerada.
* **Contexto**: O gerador de prompts de imagem já está implementado em Dart no arquivo [image_prompt_generator.dart](file:///c:/Users/wheslan.quintanilha/Documents/freshnews_mobile/lib/features/admin/application/image_prompt_generator.dart). O fluxo pode chamar essa lógica via Edge Function do Supabase ou integrar um passo no n8n que faça o request para a API de geração de imagens com base no resumo editorial.

### 3. Ajuste de Timeouts do Firecrawl
* **Ação**: Prevenir que falhas de scrap de notícias individuais travem a execução diária do fluxo de coleta de posts.
* **Configuração recomendada**: Nos parâmetros do nó do Firecrawl, configurar o Timeout para `20000` (20 segundos) e habilitar em "Settings" do nó a opção **On Error: Continue** (ou "Continue On Error"). Assim, se uma URL estiver fora do ar ou lenta, o n8n ignora e prossegue para a próxima notícia.

### 4. Expansão para Outros Mundos (TECH, GAME, MUSIC)
* **Ação**: Validar e replicar as configurações ajustadas para o GEAR nos outros fluxos de criação de edições.
* **Pontos de Atenção**: Garantir que as tabelas de posts de cada mundo estejam devidamente populadas antes de disparar o workflow de fechamento correspondente, para evitar a geração de edições vazias.

### 5. Alternativa Arquitetural: Centralizar Processamento no App Flutter
* **Ação**: Devido à complexidade de gerenciar múltiplos nodes e timeouts de rede no n8n, há a possibilidade de migrar a lógica de orquestração (busca de feeds, chamada de IA para resumos e persistência) diretamente para o backend do app ou via Supabase Edge Functions.
* **Decisão**: A ser avaliado pelo time de engenharia caso o n8n se torne um ponto único de falhas complexas de depuração.
