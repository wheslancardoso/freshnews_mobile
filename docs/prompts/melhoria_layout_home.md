# 🎨 Prompt de Instruções: Refinamento Estético e Harmonização da Home Screen

Este documento contém o prompt e as diretrizes detalhadas que você pode enviar para outra IA para refatorar e harmonizar o layout da `HomeScreen` (`lib/features/home/presentation/home_screen.dart`).

---

## 📋 Prompt para Copiar e Enviar à Outra IA

> **Instruções para o Operador**: Copie o bloco de citação abaixo e envie para o chat da IA de sua preferência.

```markdown
Você é um designer de interfaces móveis e desenvolvedor Flutter Sênior. Preciso que você refatore e harmonize o layout da tela inicial (`HomeScreen`) do nosso aplicativo móvel. 

O aplicativo segue uma estética **Brutalista Premium** (cantos angulares com raio máximo de 4px, bordas pretas sólidas de 2.0px a 2.5px, sombras rígidas deslocadas sem blur e cores vibrantes com alto contraste, como o verde neon `#22C55E` como primário genérico). 

### 🚨 Problemas Atuais Identificados:
1. **Redundância de Navegação**: Temos dois seletores do "World" ativo na mesma tela inicial: um `PopupMenuButton` no `SliverAppBar` e chips horizontais (`_buildWorldChips`) no corpo da página. Isso confunde o usuário.
2. **Layout Colado & Sem Respiro**: Há espaçamentos inconsistentes. Elementos de seções diferentes (Hero, Seletores, Categorias, Grid de Newsletters) estão grudados ou apertados demais, perdendo a clareza brutalista de blocos bem definidos.
3. **Elementos Gigantescos e Redundantes**: O Hero da home está ocupando muito espaço vertical, com fontes enormes e uma badge de status que polui o topo. Os botões e cards também estão desproporcionais e competindo por atenção.
4. **Acabamento Geral**: Falta uma transição mais suave e harmoniosa de margens entre o grid de newsletters e as outras seções da tela.

### 🎯 Diretrizes de Refatoração:

#### 1. Limpeza da AppBar e Unificação de Mundos
- Remova o `PopupMenuButton` da `SliverAppBar`. Vamos manter apenas os chips horizontais de Mundos (`_buildWorldChips`) no corpo da tela como o seletor oficial.
- Centralize ou alinhe melhor o logo/título no topo e garanta que o botão de configurações (se logado) fique bem posicionado nas `actions`.

#### 2. Harmonização da Seção Hero (Ajuste de Escala)
- Reduza a proporção do texto principal no Hero. Use um tamanho de fonte mais elegante (por exemplo, `FNTypography.headingLarge` ou reduza a escala do `displayLarge` para não dominar a tela inteira).
- Melhore a badge de status `"ONLINE // TRANSMITINDO"`. Ela deve ser menor, discreta e ter margens internas (padding) equilibradas.
- Aplique espaçamentos consistentes usando a escala definida em `FNSpacing` (ex: `FNSpacing.md` de 16px para espaços internos e `FNSpacing.xl` de 32px para separar blocos principais).

#### 3. Organização e Respiro dos Controles (`WorldChips` e `CategoryTabs`)
- Adicione margens de respiro superiores e inferiores bem definidas para os chips de mundos e abas de categorias. Eles não devem encostar um no outro verticalmente.
- Garanta que as abas de categorias (`_buildCategoryTabs`) tenham uma altura confortável (44px a 48px) e que a rolagem lateral seja limpa, com paddings nas extremidades da lista correspondendo às margens da tela (`FNSpacing.lg` / 24px).

#### 4. Grid de Newsletters e Altura dos Cards
- Ajuste as dimensões de `mainAxisExtent` do `SliverGrid` para o grid de edições de newsletters para evitar overflows visuais no card brutalista.
- Certifique-se de que os cards tenham uma distribuição consistente de espaçamentos para imagens, títulos e categorias.

#### 5. Seção de Inscrição (`SubscribeSection`)
- Harmonize os paddings internos do card brutalista de inscrição. Os inputs de texto e os botões devem ter espaçamento uniforme e cantos de 4px para combinar com o resto do sistema visual.

---

### 💻 Código Atual a Ser Refatorado:

Aqui está o código atual da `HomeScreen` para que você possa reestruturá-lo e aplicar as melhorias mantendo a gerência de estado (Riverpod) e as rotas (GoRouter) intactas:

[Insira ou anexe o conteúdo do arquivo lib/features/home/presentation/home_screen.dart aqui]
```

---

## 🛠️ O que foi corrigido no projeto para possibilitar o design ideal:

1. **Tokens de Estilo**: Todos os componentes (botões, cards, textfields e seletores) foram atualizados para usar cantos de **4px** e contornos pretos de **2.0px a 2.5px** de acordo com a estética Brutalismo Premium.
2. **Paleta de Cores**: Eliminou-se tons violetas genéricos. A interface adota o Verde Neon (`Color(0xFF22C55E)`) ou a cor correspondente a cada Mundo selecionado (`TECH`, `MUSIC`, `GEAR`, `GAME`) de forma dinâmica.
3. **Escala de Espaçamento (`FNSpacing`)**:
   - `FNSpacing.xs` = 4.0
   - `FNSpacing.sm` = 8.0
   - `FNSpacing.md` = 16.0
   - `FNSpacing.lg` = 24.0
   - `FNSpacing.xl` = 32.0
   - `FNSpacing.xxl` = 48.0
   - `FNSpacing.xxxl` = 64.0
