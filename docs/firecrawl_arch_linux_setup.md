# Guia Definitivo: Self-Hosting do Firecrawl no Arch Linux (Home Lab)

Este guia serve como um manual passo-a-passo para migrar o robô de extração pesada (Firecrawl/Playwright) da VPS (Hostinger) para o seu computador local rodando Arch Linux + Hyprland. Isso garante eficiência máxima, uso nativo de recursos e zero custos extras.

---

## 1. Preparação do Ambiente (Docker Nativo)

Como você utiliza Arch Linux, o Docker rodará nativamente no kernel, o que traz uma performance brutal comparada a ambientes Windows/Mac.

Abra o seu terminal (Kitty, Alacritty, etc) e rode:

```bash
# Atualiza os repositórios e instala os pacotes necessários
sudo pacman -Syu docker docker-compose git base-devel

# Inicia o serviço do Docker e garante que ele suba junto com o sistema
sudo systemctl enable --now docker

# Adiciona o seu usuário ao grupo do docker para não precisar usar 'sudo' o tempo todo
sudo usermod -aG docker $USER

# IMPORTANTE: Faça logout e login novamente na sua sessão do Hyprland 
# para que o grupo do docker seja ativado.
```

## 2. Baixar e Subir o Firecrawl

Vamos clonar o repositório oficial do Firecrawl e subir os containers localmente.

```bash
# Crie uma pasta para seus projetos de infraestrutura (se não tiver)
mkdir -p ~/homelab && cd ~/homelab

# Clone o repositório oficial
git clone https://github.com/mendableai/firecrawl.git
cd firecrawl

# Copie o arquivo de variáveis de ambiente padrão
cp .env.example .env

# (Opcional) Edite o .env se quiser colocar chaves da OpenAI nativas ou senhas
# nano .env

# Suba a infraestrutura inteira (Redis, Postgres, RabbitMQ, API e Playwright)
docker-compose up -d
```

Neste momento, o Firecrawl já estará rodando e sugando a memória do seu Arch para abrir o Chromium Headless de forma super rápida. Ele estará acessível no seu navegador local em: `http://localhost:3002`.

---

## 3. A Mágica: Expondo via Cloudflare Tunnels

Agora precisamos que o seu **n8n na Hostinger** consiga acessar o seu **Arch Linux** na sua casa.
Ao invés de abrir portas no seu roteador (o que é perigoso e chato), usaremos o `cloudflared`.

### 3.1 Instalar o `cloudflared`

Você pode instalar direto do repositório ou via AUR:
```bash
# Usando pacman (se disponível nos repositórios comunitários)
sudo pacman -S cloudflared

# Ou usando o yay (AUR)
yay -S cloudflared
```

### 3.2 Autenticar e Criar o Túnel

```bash
# Logue na sua conta da Cloudflare (vai abrir o navegador)
cloudflared tunnel login

# Crie um túnel com um nome fácil
cloudflared tunnel create firecrawl-home

# IMPORTANTE: Ao rodar o comando acima, ele vai te devolver um ID do túnel (ex: 8a3f2b1...).
# Copie esse ID.
```

### 3.3 Apontar o Domínio para o Túnel

Agora, diga para a Cloudflare que o domínio `firecrawl.wfixtech.com.br` deve apontar para esse túnel recém-criado:

```bash
cloudflared tunnel route dns firecrawl-home firecrawl.wfixtech.com.br
```

### 3.4 Configurar e Ligar o Túnel

Crie um arquivo de configuração simples. Onde você estiver no terminal, crie o arquivo `config.yml`:

```yaml
# config.yml
tunnel: <SEU_ID_DO_TUNEL_AQUI>
credentials-file: /home/<SEU_USUARIO>/.cloudflared/<SEU_ID_DO_TUNEL_AQUI>.json

ingress:
  - hostname: firecrawl.wfixtech.com.br
    service: http://localhost:3002
  - service: http_status:404
```

Por fim, inicie o túnel:
```bash
cloudflared tunnel run --config ./config.yml firecrawl-home
```

> **Dica Pro:** Quando tudo estiver testado e funcionando, você pode rodar `sudo cloudflared service install` para transformar o túnel em um serviço do `systemd` no Arch, fazendo com que o túnel abra sozinho sempre que você ligar o PC.

---

## 4. O Teste Final

Quando o túnel estiver rodando, abra o n8n na sua VPS da Hostinger e rode o fluxo de notícias.
O n8n vai bater no endereço `https://firecrawl.wfixtech.com.br/v1/scrape`, a Cloudflare vai direcionar isso de forma segura para o túnel no seu Arch Linux, o Docker local vai abrir a página do Globo Esporte/NBA usando o seu hardware, e devolver os dados limpinhos para a VPS.

Tudo isso com HTTPS automático e com a potência nativa da sua máquina de casa!
