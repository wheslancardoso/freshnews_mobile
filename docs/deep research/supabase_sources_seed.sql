-- =====================================================================
-- 💾 SEED DE FONTES RSS (Supabase SQL) — Fresh News
-- 
-- Este script realiza a migração arquitetônica e a inserção das fontes 
-- reais mapeadas na pesquisa profunda para os mundos:
-- * MUSIC (Beats & Noise)
-- * GEAR (RPM & Gadgets)
-- * GAME (Arcade & Pixel)
-- =====================================================================

-- ─── 🏗️ 1. MELHORIA ARQUITETÔNICA DA TABELA SOURCES ──────────────────
-- Adiciona a coluna 'world' na tabela sources para que o pipeline do n8n
-- saiba exatamente a qual multiverso rotear os posts ingeridos.
ALTER TABLE public.sources 
ADD COLUMN IF NOT EXISTS world TEXT NOT NULL DEFAULT 'TECH';

-- ─── 📥 2. INSERÇÃO DAS FONTES MAPEADAS (EVITANDO DUPLICADOS) ──────────

-- 🎵 MUNDO: MUSIC (BEATS & NOISE)
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active) VALUES
  ('CDM (Create Digital Music)', 'https://cdm.link/feed', 'PRODUÇÃO', 'MUSIC', true),
  ('KVR Audio (Top News)', 'https://www.kvraudio.com/rss/kvr_news_top.rss', 'PRODUÇÃO', 'MUSIC', true),
  ('Bedroom Producers Blog', 'https://bedroomproducersblog.com/feed', 'INDIE', 'MUSIC', true),
  ('Gearnews (Zone: Synth)', 'https://www.gearnews.com/zone/synth/feed', 'PRODUÇÃO', 'MUSIC', true),
  ('Synthtopia', 'https://www.synthtopia.com/feed/', 'PRODUÇÃO', 'MUSIC', true),
  ('MusicRadar (Music Tech Tag)', 'https://www.musicradar.com/feeds/tag/music-tech', 'PRODUÇÃO', 'MUSIC', true),
  ('Intellijel (Modular News)', 'https://intellijel.com/feed', 'PRODUÇÃO', 'MUSIC', true),
  ('Inverted Audio (News)', 'https://inverted-audio.com/news/feed', 'INDIE', 'MUSIC', true),
  ('Inverted Audio (Ambient)', 'https://inverted-audio.com/genre/ambient/feed', 'INDIE', 'MUSIC', true),
  ('Attack Magazine', 'https://www.attackmagazine.com/feed/', 'PRODUÇÃO', 'MUSIC', true),
  ('XLR8R', 'https://xlr8r.com/feed', 'INDIE', 'MUSIC', true),
  ('The Ransom Note', 'https://www.theransomnote.com/feed/', 'INDIE', 'MUSIC', true),
  ('Pitchfork (Album Reviews)', 'https://pitchfork.com/feed/feed-album-reviews/rss', 'LANÇAMENTOS', 'MUSIC', true),
  ('Stereogum (Music)', 'https://www.stereogum.com/category/music/feed', 'LANÇAMENTOS', 'MUSIC', true),
  ('The Quietus', 'https://thequietus.com/feed', 'INDIE', 'MUSIC', true),
  ('Boomkat (New Releases)', 'https://boomkat.com/new-releases.rss', 'LANÇAMENTOS', 'MUSIC', true),
  ('Hype Machine (Popular)', 'http://hypem.com/feed/time/today/1/feed.xml', 'CHARTS', 'MUSIC', true)
ON CONFLICT (rss_url) DO UPDATE 
SET category_hint = EXCLUDED.category_hint,
    world = EXCLUDED.world;

-- ⚙️ MUNDO: GEAR (RPM & GADGETS)
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active) VALUES
  ('Hackaday', 'https://hackaday.com/blog/feed/', 'DIY', 'GEAR', true),
  ('Adafruit Blog', 'https://blog.adafruit.com/feed/', 'DIY', 'GEAR', true),
  ('Hackster.io News', 'https://www.hackster.io/news.rss', 'DIY', 'GEAR', true),
  ('Arduino Official Blog', 'http://blog.arduino.cc/feed/', 'DIY', 'GEAR', true),
  ('IEEE Spectrum (Robotics)', 'https://spectrum.ieee.org/feeds/topic/robotics', 'INOVAÇÃO', 'GEAR', true),
  ('MotoIQ (Projects Hub)', 'https://motoiq.com/category/projects/feed/', 'AUTOMOTIVO', 'GEAR', true),
  ('Racecar Engineering', 'https://www.racecar-engineering.com/feed/', 'AUTOMOTIVO', 'GEAR', true),
  ('Automotive IQ', 'https://www.automotive-iq.com/rss', 'AUTOMOTIVO', 'GEAR', true),
  ('Motor1 BR', 'https://motor1.uol.com.br/rss/', 'AUTOMOTIVO', 'GEAR', true),
  ('Pine64 Community Blog', 'https://pine64.org/blog/index.xml', 'GADGETS', 'GEAR', true),
  ('Liliputing', 'https://liliputing.com/feed/', 'GADGETS', 'GEAR', true),
  ('Open Wearables (GitHub Commits)', 'https://github.com/the-momentum/open-wearables/commits/main.atom', 'WEARABLES', 'GEAR', true),
  ('OpenBCI Forum Discussions', 'http://openbci.com/forum/index.php?p=/discussions/feed.rss', 'WEARABLES', 'GEAR', true),
  ('Adafruit (Wearables Category)', 'https://blog.adafruit.com/category/wearables/feed/', 'WEARABLES', 'GEAR', true)
ON CONFLICT (rss_url) DO UPDATE 
SET category_hint = EXCLUDED.category_hint,
    world = EXCLUDED.world;

-- 🎮 MUNDO: GAME (ARCADE & PIXEL)
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active) VALUES
  ('Retro Game Corps', 'https://retrogamecorps.com/feed/', 'CONSOLE', 'GAME', true),
  ('ROMhacking.net (Patches)', 'https://www.romhacking.net/romhackingdotnet.rss', 'INDIE', 'GAME', true),
  ('Libretro Blog', 'https://libretro.com/index.php/feed', 'CONSOLE', 'GAME', true),
  ('mGBA Official', 'https://mgba.io/feed.xml', 'PC', 'GAME', true),
  ('Dolphin Emulator Blog', 'https://dolphin-emu.org/blog/feeds', 'CONSOLE', 'GAME', true),
  ('Read Only Memo', 'https://readonlymemo.com/rss/', 'INDIE', 'GAME', true),
  ('Adventures in PC Emulation', 'https://martypc.blogspot.com/feeds/posts/default', 'PC', 'GAME', true),
  ('TASVideos Publications', 'https://tasvideos.org/publications.rss', 'PC', 'GAME', true),
  ('Warp Door', 'https://warpdoor.com/rss', 'INDIE', 'GAME', true),
  ('Indie DB Headlines', 'https://rss.indiedb.com/headlines/feed', 'INDIE', 'GAME', true),
  ('Indie DB Articles', 'https://rss.indiedb.com/articles/feed', 'INDIE', 'GAME', true),
  ('Red Blob Games', 'https://www.redblobgames.com/blog/posts.xml', 'INDIE', 'GAME', true),
  ('Indie Gamer Chick', 'https://indiegamerchick.com/feed/', 'INDIE', 'GAME', true),
  ('TIGSource', 'http://www.tigsource.com/feed/', 'INDIE', 'GAME', true),
  ('Game Wisdom', 'https://game-wisdom.com/feed', 'CONSOLE', 'GAME', true),
  ('Designer Notes', 'https://www.designer-notes.com/?feed=rss2', 'PC', 'GAME', true),
  ('Hardcore Gaming 101', 'https://www.hardcoregaming101.net/feed/', 'CONSOLE', 'GAME', true),
  ('Superjump Magazine', 'https://www.superjumpmagazine.com/rss/', 'PC', 'GAME', true),
  ('Aftermath', 'https://aftermath.site/rss/', 'PC', 'GAME', true),
  ('HLTV.org (CS News)', 'https://www.hltv.org/news.rss.php', 'ESPORTS', 'GAME', true),
  ('HLTV.org (CS Demos)', 'https://www.hltv.org/demo.rss.php', 'ESPORTS', 'GAME', true),
  ('Esports Insider', 'https://esportsinsider.com/feed', 'ESPORTS', 'GAME', true),
  ('The Esports Observer', 'https://esportsobserver.com/feed', 'ESPORTS', 'GAME', true),
  ('Dotabuff Blog', 'https://dotabuff.com/blog.rss', 'ESPORTS', 'GAME', true),
  ('TouchArcade', 'https://toucharcade.com/feed', 'MOBILE', 'GAME', true),
  ('Pocket Tactics', 'https://pockettactics.com/mainrss.xml', 'MOBILE', 'GAME', true),
  ('Pocket Gamer (News Feed)', 'https://www.pocketgamer.com/news/index.rss', 'MOBILE', 'GAME', true),
  ('Pocket Gamer Biz', 'https://www.pocketgamer.biz/rss/', 'MOBILE', 'GAME', true)
ON CONFLICT (rss_url) DO UPDATE 
SET category_hint = EXCLUDED.category_hint,
    world = EXCLUDED.world;

-- ─── 📝 3. EXEMPLO DE CONSULTA DO n8n ────────────────────────────────
-- SELECT name, rss_url, category_hint, bot_protection 
-- FROM public.sources 
-- WHERE is_active = true AND world = 'MUSIC';
