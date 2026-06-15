-- Criação da Tabela de Sinais de Rastreio (Telemetria)
CREATE TABLE IF NOT EXISTS user_reading_signals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES subscribers(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    signal_type TEXT NOT NULL, -- 'dwell_time', 'link_click'
    weight NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Adicionando o vetor de afinidade direto na tabela subscribers para otimização de leitura
ALTER TABLE subscribers ADD COLUMN IF NOT EXISTS affinity_vector JSONB NOT NULL DEFAULT '{}'::jsonb;

-- Função Postgres para recalcular o vetor via Média Ponderada Exponencial
CREATE OR REPLACE FUNCTION process_reading_signal()
RETURNS TRIGGER AS $$
DECLARE
    current_vector JSONB;
    old_score NUMERIC;
    new_score NUMERIC;
    alpha NUMERIC := 0.3; -- 30% peso para a interação atual, 70% para o histórico
BEGIN
    -- Busca o vetor atual do usuário
    SELECT affinity_vector INTO current_vector FROM subscribers WHERE id = NEW.user_id;
    
    -- Extrai o score antigo da categoria (se não existir, é 0)
    old_score := COALESCE((current_vector->>NEW.category)::NUMERIC, 0.0);
    
    -- Calcula o novo score: (alpha * novo_peso) + ((1 - alpha) * score_antigo)
    new_score := (alpha * NEW.weight) + ((1.0 - alpha) * old_score);
    
    -- Atualiza o vetor na tabela subscribers
    UPDATE subscribers
    SET affinity_vector = jsonb_set(
        current_vector,
        array[NEW.category],
        to_jsonb(new_score)
    )
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Cria o Trigger na tabela de sinais
DROP TRIGGER IF EXISTS trg_process_reading_signal ON user_reading_signals;
CREATE TRIGGER trg_process_reading_signal
AFTER INSERT ON user_reading_signals
FOR EACH ROW
EXECUTE FUNCTION process_reading_signal();

-- Políticas de RLS para Segurança
ALTER TABLE user_reading_signals ENABLE ROW LEVEL SECURITY;

-- Usuário pode inserir seus próprios sinais
CREATE POLICY "Users can insert their own signals"
ON user_reading_signals FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Usuário pode ler seus próprios sinais (opcional, bom para debugar)
CREATE POLICY "Users can read their own signals"
ON user_reading_signals FOR SELECT
USING (auth.uid() = user_id);
