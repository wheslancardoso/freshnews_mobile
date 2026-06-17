# 21 · Versões de SDK e Requisitos de Build

Este documento registra as versões exatas das ferramentas de desenvolvimento utilizadas na máquina de desenvolvimento original, servindo como referência para evitar problemas de compatibilidade e erros de compilação (build) ao configurar o projeto em outras máquinas.

---

## 🛠️ 1. Ambiente de Desenvolvimento Original

As versões abaixo foram validadas e estão em uso no ambiente estável:

* **Flutter SDK**: `3.44.1` (canal `stable`)
* **Dart SDK**: `3.12.1`

---

## 📄 2. Especificação no `pubspec.yaml`

O projeto está configurado para aceitar a seguinte faixa de versões da SDK do Dart:

```yaml
environment:
  sdk: '>=3.4.0 <4.0.0'
```

---

## 🚀 3. Instruções para Configuração em Nova Máquina

Siga este passo a passo para garantir que o projeto compile sem problemas de versões de dependências em um novo ambiente:

### Passo 1: Instalação do Flutter
Instale uma versão do Flutter compatível com a faixa de SDK descrita acima. Recomenda-se utilizar exatamente a versão **3.44.x** (ou a versão estável mais próxima que atenda à SDK do Dart `>=3.4.0`).
* Para gerenciar múltiplas versões do Flutter na mesma máquina se necessário, você pode utilizar gerenciadores como o [FVM (Flutter Version Management)](https://fvm.app/).

### Passo 2: Limpeza do Projeto
Antes de baixar as dependências em uma nova máquina, limpe quaisquer arquivos temporários ou builds locais antigos:
```bash
flutter clean
```

### Passo 3: Obtenção das Dependências
Baixe os pacotes definidos no `pubspec.yaml`:
```bash
flutter pub get
```

### Passo 4: Geração de Código Automático (Build Runner)
Este projeto utiliza geração de código via `riverpod_generator` e `build_runner` (conforme as dependências do `pubspec.yaml`). Execute o comando abaixo para gerar os arquivos necessários:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📋 4. Diagnóstico e Verificação
Para certificar-se de que o seu ambiente está configurado corretamente, execute o comando:
```bash
flutter doctor
```
Certifique-se de que o suporte à plataforma desejada (Android/iOS/Web) está com os requisitos e ferramentas de compilação (Android SDK, Xcode, etc.) devidamente instalados e sem alertas críticos.
