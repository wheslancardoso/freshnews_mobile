import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fresh_news_mobile/core/constants/app_constants.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/infrastructure/post_repository.dart';
import 'package:fresh_news_mobile/shared/infrastructure/newsletter_repository.dart';
import 'package:fresh_news_mobile/shared/domain/post.entity.dart';

final generateNewsletterServiceProvider = Provider<GenerateNewsletterService>((ref) {
  return GenerateNewsletterService(
    ref.read(postRepositoryProvider),
    ref.read(newsletterRepositoryProvider),
    Dio(),
  );
});

class GenerateNewsletterService {
  final PostRepository _postRepository;
  final NewsletterRepository _newsletterRepository;
  final Dio _dio;

  GenerateNewsletterService(this._postRepository, this._newsletterRepository, this._dio);

  String _getMapPrompt(World world) {
    final categoriesStr = WorldRegistry.get(world).categories.join(' | ');
    switch (world) {
      case World.music:
        return '''Você é um Editor de Música Sênior e Crítico da Fresh News. Sua tarefa é produzir uma newsletter analítica sobre música, batidas e cultura de áudio.

# PERSONAS ESPECIALISTAS:
1. **HIP_HOP (Beatmaker-Chefe)**
2. **ROCK_INDIE (Crítico de Fanzine)**
3. **ELECTRONICA (Produtor de Techno)**
4. **CULTURA_BR (Teórico Cultural)**

# REGRAS DE OURO:
- **NÃO FAÇA RESUMOS GENÉRICOS**: Detalhe os aspectos artísticos e técnicos.
- **TOM COMENTADO**: Use sua persona para dar opinião e visão histórica.
- **IDIOMA**: Português Brasileiro (pt-BR).

# SAÍDA JSON OBRIGATÓRIA (Retorne um objeto com a chave "items"):
{
  "items": [
    {
      "id": "ID original fornecido",
      "topic_slug": "slug-unico-do-assunto-para-evitar-duplicidade",
      "category": "$categoriesStr",
      "title": "Título provisório impactante (Máx 80 chars)",
      "summary": "Comentário profundo e analítico. Mínimo 400, Máximo 1200 caracteres.",
      "whatsapp_summary": "Versão curta com emoji para WhatsApp",
      "image_prompt": "Prompt detalhado para geração de imagem no estilo fanzine analógico com a logo 'N'.",
      "relevance_score": 0,
      "theme_config": {
        "dna": "MUSIC_VERTICAL",
        "primary_color": "#0D0B0A",
        "accent_color": "#EAB308",
        "font_style": "Serif",
        "ui_effects": ["terminal_glow"]
      }
    }
  ]
}''';
      case World.gear:
        return '''Você é um Editor de Engenharia e Gadgets Sênior da Fresh News. Sua tarefa é produzir uma newsletter "Deep Dive" analítica focada em hardware hacker, engenharia mecânica, EDC e design de produto.

# PERSONAS ESPECIALISTAS:
1. **RAW_HARDWARE (Maker de Bancada)**
2. **GEARHEAD (Engenheiro de Pista)**
3. **EDC (Curador de bolso)**
4. **DESIGN_INDUSTRIAL (Desenhista Técnico)**

# REGRAS DE OURO:
- **NÃO FAÇA RESUMOS GENÉRICOS**: Vá a fundo nos termos da engenharia mecânica, metalúrgica ou elétrica.
- **TOM COMENTADO**: Faça considerações sobre a durabilidade e eficiência técnica.
- **IDIOMA**: Português Brasileiro (pt-BR).

# SAÍDA JSON OBRIGATÓRIA (Retorne um objeto com a chave "items"):
{
  "items": [
    {
      "id": "ID original fornecido",
      "topic_slug": "slug-unico-do-assunto-para-evitar-duplicidade",
      "category": "$categoriesStr",
      "title": "Título provisório impactante (Máx 80 chars)",
      "summary": "Comentário profundo e analítico. Mínimo 400, Máximo 1200 caracteres.",
      "whatsapp_summary": "Versão curta com emoji para WhatsApp",
      "image_prompt": "Prompt detalhado para geração de imagem no estilo blueprint/metal com a logo 'N' integrada.",
      "relevance_score": 0,
      "theme_config": {
        "dna": "GEAR_VERTICAL",
        "primary_color": "#0F1115",
        "accent_color": "#F59E0B",
        "font_style": "Outfit",
        "ui_effects": ["scanlines"]
      }
    }
  ]
}''';
      case World.game:
        return '''Você é um Editor de Games e Cultura Retro Sênior da Fresh News. Sua tarefa é produzir uma newsletter "Deep Dive" focada em desenvolvimento indie, consoles, esports e história dos jogos.

# PERSONAS ESPECIALISTAS:
1. **INDIE_GAME (Pixel-Artist)**
2. **RETRO_PLAYER (Nostálgico 16-Bit)**
3. **ESPORTS_COACH (Estrategista)**
4. **TECH_CONSOLE (Engenheiro de Silício)**

# REGRAS DE OURO:
- **NÃO FAÇA RESUMOS GENÉRICOS**: Vá fundo na mecânica do jogo, no código das engines ou na física da computação gráfica.
- **TOM COMENTADO**: Use sua persona para tecer opiniões sobre design e hardware de jogo.
- **IDIOMA**: Português Brasileiro (pt-BR).

# SAÍDA JSON OBRIGATÓRIA (Retorne um objeto com a chave "items"):
{
  "items": [
    {
      "id": "ID original fornecido",
      "topic_slug": "slug-unico-do-assunto-para-evitar-duplicidade",
      "category": "$categoriesStr",
      "title": "Título provisório impactante (Máx 80 chars)",
      "summary": "Comentário profundo e analítico. Mínimo 400, Máximo 1200 caracteres.",
      "whatsapp_summary": "Versão curta com emoji para WhatsApp",
      "image_prompt": "Prompt detalhado para geração de imagem no estilo neon/pixel com a logo 'N' de neon integrada.",
      "relevance_score": 0,
      "theme_config": {
        "dna": "GAME_VERTICAL",
        "primary_color": "#0B080F",
        "accent_color": "#06B6D4",
        "font_style": "Outfit",
        "ui_effects": ["glitch_effect"]
      }
    }
  ]
}''';
      case World.tech:
      default:
        return '''Você é um Editor de Tecnologia Sênior da Fresh News. Sua tarefa é produzir uma newsletter "Deep Dive", que vai muito além de resumos genéricos. Queremos comentários analíticos, técnicos e aprofundados.

# PERSONAS ESPECIALISTAS:
1. **IA (Neuralista-Chefe)**
2. **SEGURANÇA (Red Team)**
3. **DEV (Arquiteto Software Sênior)**
4. **CLOUD (SRE / Cloud Architect)**

# REGRAS DE OURO:
- **NÃO FAÇA RESUMOS GENÉRICOS**: Entre a fundo. Detalhe os "comos" e "porquês".
- **TOM COMENTADO**: Use sua persona para dar opinião técnica e visão de futuro sobre o assunto.
- **IDIOMA**: Português Brasileiro (pt-BR).
- **FILTRO**: Ignore notícias puramente comerciais ou de eletrônicos de consumo sem impacto em engenharia.

# SAÍDA JSON OBRIGATÓRIA (Retorne um objeto com a chave "items"):
{
  "items": [
    {
      "id": "ID original fornecido",
      "topic_slug": "slug-unico-do-assunto-para-evitar-duplicidade",
      "category": "$categoriesStr",
      "title": "Título provisório impactante (Máx 80 chars)",
      "summary": "Comentário profundo e analítico. Mínimo 400, Máximo 1200 caracteres.",
      "whatsapp_summary": "Versão curta com emoji para WhatsApp",
      "image_prompt": "Prompt detalhado para geração de imagem no estilo Liquid Glass com a logo 'N' integrada.",
      "relevance_score": 0,
      "theme_config": {
        "dna": "TECH_HACKER",
        "primary_color": "#0D0D0D",
        "accent_color": "#8B5CF6",
        "font_style": "Outfit",
        "ui_effects": ["neural_particles"]
      }
    }
  ]
}''';
    }
  }

  Future<Map<String, dynamic>> _callOpenAi(List<Map<String, String>> messages) async {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${AppConstants.openAiApiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o',
        'messages': messages,
        'response_format': {'type': 'json_object'},
      },
    );

    final content = response.data['choices'][0]['message']['content'];
    return jsonDecode(content as String);
  }

  Future<void> generate(World world) async {
    try {
      final worldSlug = world.config.slug;

      // 1. Fetch 25 pending/approved posts
      final pendingPosts = await _postRepository.getPending(world: world);
      final approvedPosts = await _postRepository.getApproved(world: world, limit: 25);
      
      final allPosts = <Post>[];
      allPosts.addAll(approvedPosts);
      for (final p in pendingPosts) {
        if (!allPosts.any((a) => a.id == p.id)) {
          allPosts.add(p);
        }
      }
      
      if (allPosts.length > 25) {
        allPosts.removeRange(25, allPosts.length);
      }

      if (allPosts.isEmpty) {
        throw Exception('Nenhum post pendente ou aprovado encontrado para o mundo $worldSlug.');
      }

      // Prepare items for AI
      final itemsForAi = allPosts.map((post) => {
        'id': post.id,
        'title': post.title,
        'link': post.url,
        'content': (post.content.length > 2000) ? post.content.substring(0, 2000) : post.content,
        'source': post.source,
      }).toList();

      // 2. Chunking
      final chunks = <List<Map<String, dynamic>>>[];
      const chunkSize = 5;
      for (var i = 0; i < itemsForAi.length; i += chunkSize) {
        chunks.add(itemsForAi.sublist(i, i + chunkSize > itemsForAi.length ? itemsForAi.length : i + chunkSize));
      }

      // 3. Map: Call OpenAI in parallel
      final mapPrompt = _getMapPrompt(world);
      final futures = chunks.map((chunk) async {
        try {
          final res = await _callOpenAi([
            {'role': 'system', 'content': mapPrompt},
            {'role': 'user', 'content': 'Processe estes ${chunk.length} itens:\n${jsonEncode(chunk)}'}
          ]);
          
          List<dynamic> items = [];
          if (res.containsKey('items') && res['items'] is List) {
            items = res['items'] as List<dynamic>;
          } else {
            for (final value in res.values) {
              if (value is List) {
                items = value;
                break;
              }
            }
          }
          return items;
        } catch (e) {
          print('Erro no chunk: $e');
          return [];
        }
      });

      final mapResults = await Future.wait(futures);
      final rawItems = mapResults.expand((e) => e).toList();

      if (rawItems.isEmpty) {
        throw Exception('Falha ao processar os itens na IA.');
      }

      // 4. Reduce: Deduplicate
      final seenTopics = <String, Map<String, dynamic>>{};
      for (final item in rawItems) {
        final slug = item['topic_slug'] ?? item['id'];
        final score = item['relevance_score'] ?? 0;
        if (!seenTopics.containsKey(slug) || score > (seenTopics[slug]!['relevance_score'] ?? 0)) {
          seenTopics[slug] = item as Map<String, dynamic>;
        }
      }
      
      final reducedItems = seenTopics.values.toList();

      // Update posts in DB
      final idsToMarkPublished = <String>[];
      for (final item in reducedItems) {
        final id = item['id'];
        if (id == null) continue;
        idsToMarkPublished.add(id);
        
        await _postRepository.updatePost(
          id,
          title: item['title'],
          summary: item['summary'],
          category: item['category'],
        );
      }

      // 5. Generate Master Metadata
      final allHeadlines = reducedItems.map((i) => i['title']).join('\\n');
      final metaResponse = await _callOpenAi([
        {
          'role': 'system',
          'content': '''Você é o editor-chefe do 'Fresh News' responsável pelo editorial do mundo ${world.name.toUpperCase()} (${world.config.label}).
Sua missão é consolidar a edição diária, escrevendo um título super imersivo e uma introdução que capture a essência deste mundo (Tagline: ${WorldRegistry.get(world).tagline}).
Por exemplo, se for Tech, use um tom hacker/cyberpunk. Se for Music, um tom artístico/vibrante. Se for Gear, focado em engenharia/RPM. Se for Game, focado em pixel/retro.

SAÍDA JSON OBRIGATÓRIA:
{
  "title": "Título criativo e MUITO impactante, condizente com o mundo",
  "intro": "Uma introdução imersiva, instigante e temática de 2-3 linhas que dê o tom da edição e resuma o principal destaque",
  "quickTakes": ["⚡ Manchete curta 1", "🔥 Manchete curta 2"],
  "image_prompt": "Prompt detalhado da capa desta edição, seguindo a estética visual do mundo."
}'''
        },
        {'role': 'user', 'content': 'Gere os metadados baseado nestas headlines:\\n\$allHeadlines'}
      ]);

      // Group categories
      final categoriesMap = <String, List<Map<String, dynamic>>>{};
      for (final item in reducedItems) {
        final cat = item['category'] ?? 'GERAL';
        if (!categoriesMap.containsKey(cat)) {
          categoriesMap[cat] = [];
        }
        
        final originalPost = allPosts.firstWhere((p) => p.id == item['id'], orElse: () => allPosts.first);
        categoriesMap[cat]!.add({
          'headline': item['title'],
          'story': item['summary'],
          'link': originalPost.url,
          'theme': item['theme_config'],
        });
      }

      final categoriesList = categoriesMap.entries.map((e) => {
        'name': e.key,
        'items': e.value,
      }).toList();

      final contentJson = {
        'title': metaResponse['title'],
        'intro': metaResponse['intro'],
        'quickTakes': metaResponse['quickTakes'],
        'categories': categoriesList,
        'image_prompt': metaResponse['image_prompt'],
      };

      // 6. Save Newsletter
      final maxEdition = await _newsletterRepository.getMaxEditionNumber(worldSlug);
      final newEdition = maxEdition + 1;
      
      await _newsletterRepository.createDraft(
        world: worldSlug,
        editionNumber: newEdition,
        title: metaResponse['title'] ?? 'Edição de ${DateFormat('dd/MM/yy').format(DateTime.now())}',
        summaryIntro: metaResponse['intro'] ?? '',
        contentJson: contentJson,
        imagePrompt: metaResponse['image_prompt'] ?? '',
      );

      // 7. Mark posts as published
      if (idsToMarkPublished.isNotEmpty) {
        await _postRepository.updateStatuses(idsToMarkPublished, 'published');
      }

    } catch (e) {
      throw Exception('Erro fatal na geração (Map-Reduce Dart): $e');
    }
  }
}
