# 📱 Step 5: Notificações Push & Polimento Visual Brutalista

> **Módulo:** Notificações & Ajustes de UX/UI Retro-Futurista  
> **Status:** 🟢 Concluído  
> **Responsável:** Lan & Antigravity  
> **Data de Início:** 11/06/2026 | **Data de Conclusão:** 11/06/2026  

---

## 📝 Instruções para o Grupo
Edite as seções abaixo para descrever como a IA deve integrar push notifications e aplicar os efeitos estéticos finais (como efeitos de scanline retro, feedback tátil brutalista e cantos completamente retos).

---

## 🎯 Requisitos de Negócio
- Configurar push notifications (Firebase Cloud Messaging - FCM, OneSignal ou outro serviço escolhido no prompt) para enviar alertas ao leitor quando uma nova newsletter ou post de alta pontuação for publicado.
- Permitir que o usuário ative ou desative notificações por categoria/mundo na tela de configurações/preferências.
- Sincronizar o token de push do dispositivo do usuário com a coluna correspondente na tabela `subscribers` do Supabase para possibilitar o disparo segmentado de notificações.

---

## 🎨 Requisitos de Design (Polimento Visual)
- **Efeito de Scanline Retro**: Adicionar um efeito sutil de linhas de varredura (scanlines) CRT translúcidas no topo ou em elementos específicos do app para acentuar a estética hacker/brutalista.
- **Feedback Tátil**: Adicionar pequenas vibrações táteis (`HapticFeedback.lightImpact`) ao tocar em botões e alternadores.
- **Cantos Retos & Alinhamento Milimétrico**: Garantir que todos os cantos arredondados padrão de widgets nativos do Flutter sejam desativados em favor de cantos retos clássicos brutalistas (`BorderRadius.zero`).

---

## 💬 [PROMPT PARA A IA - EXECUTADO]
> "Adicione e configure o Firebase Cloud Messaging (`firebase_messaging`) e `flutter_local_notifications` no aplicativo. Sincronize o FCM Token gerado com a coluna `fcm_token` da tabela `subscribers` do Supabase. Crie o overlay estético de CRT (`ScanlineOverlay`) sobre o Feed e aplique `HapticFeedback` nas principais interações táteis (cards de posts, switches e abas)."

---

## 🤖 Instruções para a Execução da IA
1. Ler este arquivo e extrair o prompt da seção acima.
2. Adicionar as dependências de push notifications no `pubspec.yaml` (ex: `firebase_core`, `firebase_messaging`).
3. Criar a lógica de gerenciamento de tokens de push e sincronização com a tabela `subscribers` do Supabase.
4. Implementar widgets estéticos customizados, como o overlay de scanline retro e efeitos de flicker (se aplicável).
5. Revisar todos os widgets criados nos passos anteriores para assegurar que a regra de cantos retos e as bordas de 2.5px estejam consistentes.
