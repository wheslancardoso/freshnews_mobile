# Deep Linking (App Links / Universal Links) Setup

Este documento descreve os passos necessários para configurar o Deep Linking no aplicativo Flutter do FreshNews, permitindo que URLs como `https://app.freshnews.com.br/editions/30` abram o aplicativo diretamente e naveguem para a tela correta.

## 1. Configuração do Roteamento (GoRouter)

O GoRouter nativamente suporta deep links. Precisamos garantir que a rota de edições esteja configurada para aceitar o parâmetro de ID vindo da URL:

```dart
GoRoute(
  path: '/editions/:id',
  name: 'edition_details',
  builder: (context, state) {
    final editionId = state.pathParameters['id'];
    return EditionDetailsScreen(editionId: editionId!);
  },
),
```

## 2. Configuração no Android (App Links)

Para que o Android abra os links automaticamente sem perguntar ao usuário, precisamos configurar os App Links.

### a) Atualizar o `AndroidManifest.xml`
No arquivo `android/app/src/main/AndroidManifest.xml`, dentro da tag `<activity>` principal, adicione o `intent-filter`:

```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="app.freshnews.com.br" />
</intent-filter>
```

### b) Hospedar o arquivo `assetlinks.json`
No servidor web hospedado no domínio `app.freshnews.com.br`, adicione o arquivo no caminho:
`https://app.freshnews.com.br/.well-known/assetlinks.json`

Conteúdo do arquivo (substitua pelo seu `package_name` e `sha256_cert_fingerprints`):
```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.wfixtech.freshnews",
    "sha256_cert_fingerprints": [
      "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
    ]
  }
}]
```

## 3. Configuração no iOS (Universal Links)

### a) Configurar o `Runner.entitlements`
No Xcode, ative a capability de "Associated Domains" e adicione:
`applinks:app.freshnews.com.br`

### b) Configurar o `Info.plist`
Garantir que o `FlutterDeepLinkingEnabled` está ativado:
```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

### c) Hospedar o arquivo `apple-app-site-association`
No servidor web, adicione o arquivo no caminho (sem extensão .json):
`https://app.freshnews.com.br/.well-known/apple-app-site-association`

Conteúdo do arquivo (substitua pelo seu App ID `TeamID.BundleID`):
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.wfixtech.freshnews",
        "paths": [ "/editions/*" ]
      }
    ]
  }
}
```

## 4. Testando o Deep Link

**Android:**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://app.freshnews.com.br/editions/30" com.wfixtech.freshnews
```

**iOS:**
```bash
xcrun simctl openurl booted https://app.freshnews.com.br/editions/30
```
