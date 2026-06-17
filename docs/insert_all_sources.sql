-- ---------------------------------------------------------------------------------------------------
-- Inserts baseados no mapeamento de fontes (Curadoria para App)
-- ATENÇÃO: As colunas category_hint e world devem ser mapeadas corretamente!
-- world = O mundo do fluxo (GAME, MUSIC, TECH, SPORTS)
-- category_hint = A subcategoria (FUTEBOL, IA, INDIE, etc) para ajudar no roteamento.
-- ---------------------------------------------------------------------------------------------------

-- =========================================================
-- MUNDO: SPORTS
-- =========================================================
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active)
VALUES 
-- FUTEBOL
('Trivela', 'https://trivela.com.br/feed', 'FUTEBOL', 'SPORTS', true),
('Placar', 'https://placar.com.br/feed', 'FUTEBOL', 'SPORTS', true),
('O Futbolero Brasil', 'https://ofutebolero.com.br/rss/feed.xml', 'FUTEBOL', 'SPORTS', true),

-- NBA
('Jumper Brasil', 'https://jumperbrasil.com.br/feed/', 'NBA', 'SPORTS', true),
('ESPN NBA', 'https://www.espn.com/espn/rss/nba/news', 'NBA', 'SPORTS', true),
('Yahoo Sports NBA', 'https://sports.yahoo.com/nba/rss.xml', 'NBA', 'SPORTS', true),

-- SKATE
('Thrasher Magazine', 'https://www.thrashermagazine.com/?format=feed', 'SKATE', 'SPORTS', true),
('Jenkem Magazine', 'https://www.jenkemmag.com/home/feed', 'SKATE', 'SPORTS', true),
('Skateboarding.com', 'https://skateboarding.com/.rss/full', 'SKATE', 'SPORTS', true),
('CemporcentoSKATE', 'https://cemporcentoskate.com/feed', 'SKATE', 'SPORTS', true),

-- MMA
('MMA Junkie', 'https://mmajunkie.usatoday.com/feed/', 'MMA', 'SPORTS', true),
('MMA Fighting', 'https://www.mmafighting.com/rss/current', 'MMA', 'SPORTS', true),
('Super Lutas', 'https://www.superlutas.com.br/feed', 'MMA', 'SPORTS', true),

-- ESPORTS
('Mais Esports', 'https://maisesports.com.br/feed', 'ESPORTS', 'SPORTS', true),
('HLTV.org', 'https://www.hltv.org/news', 'ESPORTS', 'SPORTS', true),
('Esports Charts', 'https://escharts.com/blog', 'ESPORTS', 'SPORTS', true);


-- =========================================================
-- MUNDO: TECH
-- =========================================================
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active)
VALUES 
-- IA
('MIT Tech Review (AI)', 'https://www.technologyreview.com/topic/artificial-intelligence/feed/', 'IA', 'TECH', true),
('The Verge (AI)', 'https://www.theverge.com/rss/artificial-intelligence/index.xml', 'IA', 'TECH', true),
('Tecnoblog (IA)', 'https://tecnoblog.net/feed/', 'IA', 'TECH', true),

-- SEC
('The Hacker News', 'https://feeds.feedburner.com/TheHackersNews', 'SEC', 'TECH', true),
('Bleeping Computer', 'https://www.bleepingcomputer.com/feed/', 'SEC', 'TECH', true),

-- DEV
('Dev.to', 'https://dev.to/feed', 'DEV', 'TECH', true),
('Smashing Magazine', 'https://www.smashingmagazine.com/feed/', 'DEV', 'TECH', true),
('Filipe Deschamps', 'https://filipedeschamps.com.br/rss', 'DEV', 'TECH', true),

-- CLOUD
('AWS News Blog', 'https://aws.amazon.com/about-aws/whats-new/recent/feed/', 'CLOUD', 'TECH', true),
('Google Cloud Blog', 'https://cloudblog.withgoogle.com/rss/', 'CLOUD', 'TECH', true),

-- STARTUP
('TechCrunch', 'https://techcrunch.com/feed/', 'STARTUP', 'TECH', true),
('StartSe', 'https://www.startse.com/feed', 'STARTUP', 'TECH', true);


-- =========================================================
-- MUNDO: GAME
-- =========================================================
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active)
VALUES 
-- INDIE
('IndieGames+', 'https://indiegamesplus.com/feed', 'INDIE', 'GAME', true),
('Rock Paper Shotgun (Indie)', 'https://www.rockpapershotgun.com/feed/indie', 'INDIE', 'GAME', true),

-- CONSOLE
('Push Square', 'https://www.pushsquare.com/feeds/latest', 'CONSOLE', 'GAME', true),
('Nintendo Life', 'https://www.nintendolife.com/feeds/latest', 'CONSOLE', 'GAME', true),
('Pure Xbox', 'https://www.purexbox.com/feeds/latest', 'CONSOLE', 'GAME', true),

-- PC
('PC Gamer', 'https://www.pcgamer.com/rss/', 'PC', 'GAME', true),
('Jovem Nerd', 'https://jovemnerd.com.br/feed', 'PC', 'GAME', true),
('Voxel', 'https://www.tecmundo.com.br/rss', 'PC', 'GAME', true),

-- MOBILE
('TouchArcade', 'https://toucharcade.com/feed/', 'MOBILE', 'GAME', true),
('Pocket Gamer', 'https://www.pocketgamer.com/index.rss', 'MOBILE', 'GAME', true),

-- ESPORTS
('Dot Esports', 'https://dotesports.com/feed', 'ESPORTS', 'GAME', true),
('The Enemy', 'https://www.theenemy.com.br/rss', 'ESPORTS', 'GAME', true);


-- =========================================================
-- MUNDO: MUSIC
-- =========================================================
INSERT INTO public.sources (name, rss_url, category_hint, world, is_active)
VALUES 
-- ARTISTAS
('Pitchfork', 'https://pitchfork.com/rss/news/', 'ARTISTAS', 'MUSIC', true),
('Tenho Mais Discos Que Amigos', 'https://www.tenhomaisdiscosqueamigos.com/feed/', 'ARTISTAS', 'MUSIC', true),
('Omelete (Música)', 'https://www.omelete.com.br/rss/musica', 'ARTISTAS', 'MUSIC', true),

-- PRODUCAO
('Sound on Sound', 'https://www.soundonsound.com/rss/news', 'PRODUCAO', 'MUSIC', true),
('MusicRadar', 'https://www.musicradar.com/rss', 'PRODUCAO', 'MUSIC', true),

-- INDIE
('Stereogum', 'https://www.stereogum.com/feed/', 'INDIE', 'MUSIC', true),
('Gorilla vs. Bear', 'https://www.gorillavsbear.net/feed/', 'INDIE', 'MUSIC', true),

-- CHARTS
('Billboard', 'https://www.billboard.com/feed/', 'CHARTS', 'MUSIC', true),
('Music Business Worldwide', 'https://www.musicbusinessworldwide.com/feed/', 'CHARTS', 'MUSIC', true),

-- LANCAMENTOS
('Consequence of Sound', 'https://consequence.net/feed/', 'LANCAMENTOS', 'MUSIC', true),
('NME', 'https://www.nme.com/feed', 'LANCAMENTOS', 'MUSIC', true);
