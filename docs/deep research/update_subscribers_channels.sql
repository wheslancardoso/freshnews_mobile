-- Script de atualização da tabela 'subscribers'
-- Propósito: Suporte aos canais de notificação (WhatsApp e Email) para LGPD e Opt-Out

ALTER TABLE subscribers 
ADD COLUMN phone TEXT;

ALTER TABLE subscribers 
ADD COLUMN notify_email BOOLEAN DEFAULT true;

ALTER TABLE subscribers 
ADD COLUMN notify_whatsapp BOOLEAN DEFAULT false;

-- Comentários na tabela para documentação do Supabase
COMMENT ON COLUMN subscribers.phone IS 'Número de telefone do usuário (preferencialmente no formato internacional +55...)';
COMMENT ON COLUMN subscribers.notify_email IS 'Flag indicando se o usuário aceita receber a newsletter por email';
COMMENT ON COLUMN subscribers.notify_whatsapp IS 'Flag indicando se o usuário aceita receber a newsletter por WhatsApp';
