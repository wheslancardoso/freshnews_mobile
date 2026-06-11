# 🎨 Chameleon Engine: Guia de Implementação no Flutter

Este documento apresenta a especificação técnica e as instruções de implementação para portar o **Chameleon Engine** reativo (transições de cores dinâmicas e efeitos de tela) da versão Web Next.js para o aplicativo móvel desenvolvido em **Flutter**.

---

## 🧠 1. Conceito do Chameleon Engine no Mobile

Na versão Web, à medida que o leitor rola o histórico ou lê uma edição, a interface inteira transmuta de cor, fonte e efeitos gráficos de fundo baseada na **categoria/subcategoria do post em foco na tela**.

No Flutter, alcançaremos essa reatividade através de três componentes principais:
1. **`ChameleonThemeProvider`**: Um gerenciador de estado (Provider) que armazena a cor de fundo, a cor de destaque (accent), a fonte ativa e a lista de efeitos gráficos a serem desenhados.
2. **`VisibilityScrollObserver`**: Um componente que escuta a rolagem do feed ou da newsletter e detecta qual post/card ocupa a área de foco central da tela.
3. **`ChameleonEffectsOverlay`**: Um widget que desenha em overlay efeitos analógicos e digitais (Scanlines, Glitch, Blueprint Grid, Textura de Papel) usando `CustomPainter` e transformações visuais.

---

## 🛠️ 2. Arquitetura e Estrutura de Código

### 2.1 O Modelo de Configuração do Tema (`ChameleonThemeConfig`)
O modelo armazena os dados visuais lidos de cada post/categoria (`theme_config` JSONB do Supabase):

```dart
import 'package:flutter/material.dart';

class ChameleonThemeConfig {
  final Color bg;
  final Color accent;
  final Color primary;
  final String fontStyle;
  final List<String> effects;

  ChameleonThemeConfig({
    required this.bg,
    required this.accent,
    required this.primary,
    required this.fontStyle,
    required this.effects,
  });

  // Valores padrão (Mundo TECH)
  factory ChameleonThemeConfig.defaultTech() {
    return ChameleonThemeConfig(
      bg: const Color(0xFF090A0C),
      accent: const Color(0xFF22C55E), // Verde terminal
      primary: const Color(0xFF10B981),
      fontStyle: 'SpaceGrotesk',
      effects: ['glow'],
    );
  }
}
```

### 2.2 Gerenciador de Estado do Tema (`ChameleonThemeProvider`)
Usa `ChangeNotifier` para expor o estado do tema ativo. Transições suaves de cores são tratadas usando interpolação Linear ou animações implícitas do Flutter.

```dart
import 'package:flutter/material.dart';

class ChameleonThemeProvider extends ChangeNotifier {
  ChameleonThemeConfig _currentTheme = ChameleonThemeConfig.defaultTech();

  ChameleonThemeConfig get currentTheme => _currentTheme;

  void updateTheme(ChameleonThemeConfig newTheme) {
    if (_currentTheme.accent == newTheme.accent && 
        _currentTheme.effects.join(',') == newTheme.effects.join(',')) {
      return;
    }
    _currentTheme = newTheme;
    notifyListeners();
  }
}
```

---

## 📡 3. Detecção de Foco no Scroll (Scroll Observer)

No celular, queremos transmutar o app conforme o post fica centralizado no scroll. Usamos o pacote `visibility_detector` (`pub.dev/packages/visibility_detector`) para saber qual post está visível.

### Exemplo de Uso no `ListView.builder`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NewsletterFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        
        return VisibilityDetector(
          key: Key('post-${post.id}'),
          onVisibilityChanged: (info) {
            // Se o item estiver ocupando mais de 50% da área visível da tela
            if (info.visibleFraction > 0.5) {
              final themeConfig = getThemeConfigByCategory(post.subCategory);
              Provider.of<ChameleonThemeProvider>(context, listen: false)
                  .updateTheme(themeConfig);
            }
          },
          child: PostCard(post: post),
        );
      },
    );
  }
}
```

---

## 🎨 4. Renderizando Efeitos Brutalistas no Flutter

Para desenhar os efeitos específicos descritos no `theme_config` do banco de dados (Grid, Scanlines, Glitch), usaremos um widget de overlay que empilha esses efeitos sobre o fundo do card ou da tela inteira:

```dart
class ChameleonEffectsOverlay extends StatelessWidget {
  final List<String> effects;
  final Widget child;

  const ChameleonEffectsOverlay({required this.effects, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (effects.contains('scanlines')) const Positioned.fill(child: ScanlinesWidget()),
        if (effects.contains('cloud_compute_grid')) const Positioned.fill(child: BlueprintGridWidget()),
        if (effects.contains('terminal_glow')) const Positioned.fill(child: TerminalGlowBorder()),
      ],
    );
  }
}
```

### 4.1 Efeito Scanlines CRT (Retrô-Digital / Games / Music)
Podemos desenhar scanlines horizontais repetitivas usando um `CustomPainter` simples e de altíssima performance:

```dart
class ScanlinesWidget extends StatelessWidget {
  const ScanlinesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ScanlinesPainter(),
      ),
    );
  }
}

class ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1.0;

    // Desenha linhas a cada 4 pixels de altura
    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 4.2 Efeito Blueprint Grid (Industrial / Hardware / Gear)
Desenha uma malha técnica azulada/branca simulando um papel de desenho de engenharia:

```dart
class BlueprintGridWidget extends StatelessWidget {
  const BlueprintGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: BlueprintGridPainter(),
      ),
    );
  }
}

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    // Linhas verticais a cada 20 pixels
    for (double x = 0; x < size.width; x += 20.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Linhas horizontais a cada 20 pixels
    for (double y = 0; y < size.height; y += 20.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## ⚡ 5. Transições de Cores Suaves no App

Para que o fundo do app transicione suavemente de cor sem causar travamentos na rolagem:

1. Use **`AnimatedTheme`** na raiz do seu widget para trocar as cores globais de texto, bordas e destaque baseadas no `ThemeData` ativo:
   ```dart
   Consumer<ChameleonThemeProvider>(
     builder: (context, provider, child) {
       return AnimatedTheme(
         duration: const Duration(milliseconds: 600),
         curve: Curves.easeInOutCubic,
         data: ThemeData(
           scaffoldBackgroundColor: provider.currentTheme.bg,
           primaryColor: provider.currentTheme.primary,
           colorScheme: ColorScheme.dark().copyWith(
             secondary: provider.currentTheme.accent,
           ),
         ),
         child: child!,
       );
     },
     child: MainAppScaffold(),
   );
   ```

2. Para a tipografia brutalista dinâmica, use **`AnimatedDefaultTextStyle`** nas seções e cabeçalhos para atualizar a fonte (`Geist Mono` ou `Space Grotesk`) e tamanho suavemente.
