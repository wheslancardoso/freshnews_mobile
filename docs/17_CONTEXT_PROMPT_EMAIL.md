# Prompt de Contextualização: Template de E-mail Multiverso

> **Instruções de Uso:**
> Copie o texto abaixo e cole na sua sessão com o projeto Web ou com outro agente para passar todo o contexto necessário sobre como construir o novo template de E-mail dinâmico.

---
**[COPIE A PARTIR DAQUI]**

Você está me ajudando a polir e reconstruir o nosso template de e-mail (possivelmente usando React Email/Tailwind ou HTML puro) para a nossa plataforma de curadoria automatizada: **FreshNews**. 

Anteriormente, o FreshNews focava apenas no nicho de Tecnologia. No entanto, o sistema acabou de evoluir para uma arquitetura de **Multiverso**. Agora nós geramos newsletters separadas para mundos diferentes.

Eu preciso que o novo Template de E-mail tenha um **"Tema Camaleônico"**: a estrutura base (header, tipografia, blocos) permanece a mesma, mas as **Cores, Ícones, Tonalidade da Marca e Saudações** devem mudar dinamicamente dependendo da variável `world` que está sendo passada.

### 1. Os Mundos (Multiverso)
Aqui estão os mundos atuais, seus públicos e suas cores neon/brutalistas de assinatura:

- **`tech` (Terminal / IA / Dev)**
  - **Cor Primária:** Verde Neon (`#00FF41` ou similar)
  - **Vibe:** Estilo Hacker, Código, Matrix, Terminal CLI.
  - **Público:** Desenvolvedores, Engenheiros, Entusiastas de IA.
- **`game` (Indie / AAA / Consoles)**
  - **Cor Primária:** Rosa Choque / Magenta (`#FF0055`)
  - **Vibe:** Arcade, 8-bit, Glitch, Cyberpunk, Retrowave.
  - **Público:** Gamers, Desenvolvedores Indie, Streamers.
- **`music` (Indie / Streaming / Festivais)**
  - **Cor Primária:** Roxo Elétrico (`#9D00FF`)
  - **Vibe:** Palco neon, Sintetizadores, Vinil, Lo-fi.
  - **Público:** Músicos, Produtores, Audiófilos.
- **`gear` (Hardware / Setup / Gadgets)**
  - **Cor Primária:** Laranja Mecânico (`#FF9900`)
  - **Vibe:** Industrial, Blueprints, PCB (Placa de circuito), Maquinário.
  - **Público:** Entusiastas de Hardware, Setup Builders, Makers.

### 2. A Estrutura de Dados (Payload do E-mail)
O código que gera o e-mail receberá os seguintes dados do banco de dados (neste formato JSON):

```json
{
  "edition_number": 30,
  "title": "A Ascensão da IA Quântica",
  "world": "tech",
  "summary_intro": "Uma visão crítica sobre como as novas IAs estão moldando o futuro da programação.",
  "content_json": {
    "quickTakes": [
      "OpenAI anuncia novo modelo de linguagem.",
      "Vazamento aponta novo chip da NVIDIA."
    ],
    "categories": [
      {
        "name": "Inteligência Artificial",
        "items": [
          {
            "headline": "Novo framework revolucionário",
            "story": "Texto profundo, crítico e em tom de insider detalhando a notícia...",
            "relevance": 9
          }
        ]
      }
    ]
  }
}
```

### 3. Requisitos para o Design do E-mail
Baseado nesses dados, quero que você projete/atualize o template com as seguintes características:
1. **Header Dinâmico:** Que mostre o logotipo ou nome "FreshNews" estilizado com a cor correspondente ao `world`. E exiba a `edition_number`.
2. **Intro Block:** Destaque para o `title` e um bloco em itálico ou caixa sutil para o `summary_intro`.
3. **Quick Takes (Giro Rápido):** Uma lista elegante com bullets coloridos na cor do mundo, exibindo os itens do array `quickTakes`.
4. **Categories (Deep Dive):** Para cada categoria, uma seção com borda superior ou badge na cor do mundo, exibindo o nome da categoria. Dentro dela, os `items` com `headline` bem visível e a `story` com tipografia legível (ex: sans-serif limpa para leitura densa).
5. **Rodapé (Footer):** Uma assinatura "Deslogando do Terminal..." ou algo do tipo, e os avisos legais obrigatórios.

Por favor, analise a base atual de templates de email que temos no projeto Web e proponha o novo código ou componentes React Email para atender a este novo comportamento Camaleônico, garantindo que o CSS renderize perfeitamente no Gmail e no Outlook.

**[FIM DO PROMPT]**
