import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/app/router.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/core/network/supabase_client.dart';

// Função de background handler obrigatória para FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  NotificationService(this._ref);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fresh_news_channel',
    'Fresh News Notifications',
    description: 'Canal para notificações do Fresh News.',
    importance: Importance.max,
  );

  Future<void> initialize() async {
    try {
      // 1. Inicializa o Firebase Messaging
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Configura notificações locais para exibição em foreground
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_channel);
      }

      // 3. Solicita permissão do FCM
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Configura apresentação de notificações no iOS quando o app está aberto
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Configura ouvintes de mensagens
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);

      // Trata caso o app seja aberto a partir de uma notificação quando estava totalmente fechado
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _onNotificationOpenedApp(initialMessage);
      }

      // 5. Escuta atualização de token FCM e envia para o Supabase se logado
      messaging.onTokenRefresh.listen((token) {
        _syncTokenToSupabase(token);
      });

      // Sincroniza token atual imediatamente se logado
      final currentToken = await messaging.getToken();
      if (currentToken != null) {
        await _syncTokenToSupabase(currentToken);
      }
    } catch (e) {
      // Silencia falha em ambiente de teste/sem Google Play Services
      print('Firebase/Notification initialization skipped: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['newsletter_id'] as String?,
      );
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final newsletterId = response.payload;
    if (newsletterId != null && newsletterId.isNotEmpty) {
      _navigateToNewsletter(newsletterId);
    }
  }

  void _onNotificationOpenedApp(RemoteMessage message) {
    final newsletterId = message.data['newsletter_id'] as String?;
    if (newsletterId != null && newsletterId.isNotEmpty) {
      _navigateToNewsletter(newsletterId);
    }
  }

  void _navigateToNewsletter(String newsletterId) {
    try {
      _ref.read(routerProvider).push('/archive/$newsletterId');
    } catch (_) {
      // Fallback
      _ref.read(routerProvider).go('/archive/$newsletterId');
    }
  }

  Future<void> _syncTokenToSupabase(String token) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final email = session.user.email;
    if (email == null) return;

    try {
      // Obter o ID do subscriber usando o repositório ou tabela diretamente
      final response = await Supabase.instance.client
          .from('subscribers')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (response != null) {
        final subscriberId = response['id'] as String;
        await Supabase.instance.client
            .from('subscribers')
            .update({'fcm_token': token})
            .eq('id', subscriberId);
      }
    } catch (e) {
      // Silenciar erro em produção, registrar em debug
      print('Erro ao sincronizar FCM token: $e');
    }
  }

  /// Sincroniza as inscrições em tópicos do FCM com os mundos ativos do assinante
  Future<void> syncTopicSubscriptions(List<World> activeWorlds) async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Sempre inscrito no canal geral
      await messaging.subscribeToTopic('fresh_news_all');

      // Lista de todos os mundos disponíveis
      for (final world in World.values) {
        final topicName = 'fresh_news_${world.name.toUpperCase()}';
        if (activeWorlds.contains(world)) {
          await messaging.subscribeToTopic(topicName);
        } else {
          await messaging.unsubscribeFromTopic(topicName);
        }
      }
    } catch (e) {
      print('Erro ao sincronizar inscrições em tópicos FCM: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});
