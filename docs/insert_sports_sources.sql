-- Inserts baseados no mapeamento de fontes (Curadoria de Esportes para App.md)
-- Estes comandos vão popular a tabela de `sources` com as chaves corretas para a IA e o n8n.

-- Lembre-se de rodar este código no SQL Editor do seu Supabase.

-- 1. FUTEBOL
INSERT INTO public.sources (name, url, category, sub_category, world, is_active)
VALUES 
('Trivela', 'https://trivela.com.br/feed', 'SPORTS', 'FUTEBOL', 'SPORTS', true),
('Placar', 'https://placar.com.br/feed', 'SPORTS', 'FUTEBOL', 'SPORTS', true),
('O Futbolero Brasil', 'https://ofutebolero.com.br/rss/feed.xml', 'SPORTS', 'FUTEBOL', 'SPORTS', true);

-- 2. NBA
INSERT INTO public.sources (name, url, category, sub_category, world, is_active)
VALUES 
('Jumper Brasil', 'https://jumperbrasil.com.br/feed/', 'SPORTS', 'NBA', 'SPORTS', true),
('ESPN NBA', 'https://www.espn.com/espn/rss/nba/news', 'SPORTS', 'NBA', 'SPORTS', true),
('Yahoo Sports NBA', 'https://sports.yahoo.com/nba/rss.xml', 'SPORTS', 'NBA', 'SPORTS', true);

-- 3. SKATE
INSERT INTO public.sources (name, url, category, sub_category, world, is_active)
VALUES 
('Thrasher Magazine', 'https://www.thrashermagazine.com/?format=feed', 'SPORTS', 'SKATE', 'SPORTS', true),
('Jenkem Magazine', 'https://www.jenkemmag.com/home/feed', 'SPORTS', 'SKATE', 'SPORTS', true),
('Skateboarding.com', 'https://skateboarding.com/.rss/full', 'SPORTS', 'SKATE', 'SPORTS', true),
('CemporcentoSKATE', 'https://cemporcentoskate.com', 'SPORTS', 'SKATE', 'SPORTS', true);

-- 4. MMA
INSERT INTO public.sources (name, url, category, sub_category, world, is_active)
VALUES 
('MMA Junkie', 'https://mmajunkie.usatoday.com/feed/', 'SPORTS', 'MMA', 'SPORTS', true),
('MMA Fighting', 'https://www.mmafighting.com/rss/current', 'SPORTS', 'MMA', 'SPORTS', true),
('Super Lutas', 'https://www.superlutas.com.br/feed', 'SPORTS', 'MMA', 'SPORTS', true);

-- 5. ESPORTS
INSERT INTO public.sources (name, url, category, sub_category, world, is_active)
VALUES 
('Mais Esports', 'https://maisesports.com.br/feed', 'SPORTS', 'ESPORTS', 'SPORTS', true),
('HLTV.org', 'https://www.hltv.org/news', 'SPORTS', 'ESPORTS', 'SPORTS', true),
('Esports Charts', 'https://escharts.com/blog', 'SPORTS', 'ESPORTS', 'SPORTS', true);
