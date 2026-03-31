# RTK Hardened Setup para OpenClaw

Setup seguro do [RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) para uso com agentes OpenClaw. Economize 60-90% de tokens em comandos de shell com proteções de segurança aplicadas.

## Por que este setup?

O RTK oficial é um projeto sólido, mas tem alguns riscos de segurança documentados ([Issue #640](https://github.com/rtk-ai/rtk/issues/640)). Este setup aplica as seguintes proteções:

| Risco | Proteção aplicada |
|---|---|
| Telemetria sem consentimento | Compilação do source + config desligado |
| Shell injection (rtk err/test/summary) | Whitelist de comandos na skill |
| Secrets no banco de dados local | Retenção de 1 dia + instrução anti-leak |
| Hook auto-approval | Uso manual (sem hook automático) |
| Trust model bypass | Sem uso em CI/produção |

## Arquivos incluídos

```
rtk-openclaw-setup/
├── README.md                    ← Este arquivo
├── config.toml                  ← Config hardened (telemetria off, tracking seguro)
├── install-rtk-hardened.sh      ← Script de instalação automatizada
└── rtk-token-optimizer.md       ← Skill para o agente OpenClaw
```

## Instalação — Passo a Passo

### Pré-requisito: Rust instalado

Se você ainda não tem Rust/Cargo, instale primeiro:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Feche e reabra o terminal depois.

### Opção A: Instalação automática (recomendado)

```bash
# 1. Clone ou baixe este repositório
# 2. Entre na pasta
cd rtk-openclaw-setup

# 3. Dê permissão e rode o script
chmod +x install-rtk-hardened.sh
./install-rtk-hardened.sh
```

### Opção B: Instalação manual

```bash
# 1. Instalar RTK do source
cargo install --git https://github.com/rtk-ai/rtk

# 2. Criar pasta de config
mkdir -p ~/.config/rtk          # Linux
# ou: mkdir -p ~/Library/Application\ Support/rtk   # macOS

# 3. Copiar config hardened
cp config.toml ~/.config/rtk/config.toml

# 4. Verificar
rtk --version
rtk gain
```

### Configurar no OpenClaw

Copie o arquivo `rtk-token-optimizer.md` para a pasta de skills do seu agente:

```bash
# Ajuste o caminho conforme a estrutura do seu agente
cp rtk-token-optimizer.md ~/.openclaw/agents/SEU-AGENTE/skills/
```

Reinicie o agente. Ele vai começar a prefixar comandos com `rtk` automaticamente, respeitando a whitelist de segurança.

## Uso no dia a dia

Não precisa fazer nada de especial. O agente OpenClaw vai usar RTK nos comandos permitidos automaticamente. Para verificar a economia:

```bash
rtk gain          # resumo de tokens economizados
rtk gain --graph  # gráfico ASCII dos últimos 30 dias
```

## Para seu VPS Hostinger (Ubuntu)

Se quiser instalar no servidor também:

```bash
# Conecte via painel Hostinger (terminal web)
# 1. Instale Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# 2. Rode o script de instalação
./install-rtk-hardened.sh

# 3. Adicione ao PATH permanente
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Atualização

Para atualizar o RTK quando sair nova versão:

```bash
cargo install --git https://github.com/rtk-ai/rtk --force
```

O config hardened será preservado (ele não é sobrescrito).

## Créditos

- [RTK](https://github.com/rtk-ai/rtk) — Projeto original por rtk-ai
- Análise de segurança baseada na [Issue #640](https://github.com/rtk-ai/rtk/issues/640)
- Setup hardened por RC3 Empreendimentos
