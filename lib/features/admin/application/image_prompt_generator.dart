import 'package:fresh_news_mobile/core/constants/world.dart';

class ImagePromptGenerator {
  static String generate(World world, String title) {
    // English translation of the title might be better for Midjourney, but if title is in PT-BR, 
    // Midjourney still understands it somewhat, or we can just inject it as a conceptual anchor.
    // The base style is crucial.
    final basePrompt = 'Editorial magazine cover art, high-end digital publication, central theme: "$title", ';
    
    switch (world) {
      case World.tech:
        return basePrompt +
            'cyberpunk aesthetic, glowing neon green accents, dark matrix-style background, brutalist layout, holographic data streams, ultra photorealistic, 8k resolution, --ar 16:9';
      case World.music:
        return basePrompt +
            'golden hour studio lighting, warm yellow neon, dynamic concert aesthetic, vintage vinyl or modern synthesizer vibes, cinematic lighting, ultra photorealistic, 8k resolution, --ar 16:9';
      case World.sports:
        return basePrompt +
            'gritty sports documentary aesthetic, high contrast vibrant orange accents, concrete and arena textures, sweat and motion blur, cinematic stadium lighting, ultra photorealistic, 8k resolution, --ar 16:9';
      case World.game:
        return basePrompt +
            'synthwave aesthetic, deep purple and violet neon, pixel art or hyper-realistic CGI, esports arcade vibe, glowing controller accents, ultra photorealistic, 8k resolution, --ar 16:9';
    }
  }
}
