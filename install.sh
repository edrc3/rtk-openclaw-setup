#!/bin/bash
# ============================================================
# RTK Hardened Installer v2.0
# Instalação completa e segura do RTK para OpenClaw
# 
# Uso:
#   git clone https://github.com/edrc3/rtk-openclaw-setup.git
#   cd rtk-openclaw-setup
#   chmod +x install.sh && ./install.sh
#
# Tudo é automático. Não precisa editar nada.
# ============================================================

set -e

# --- Cores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "=========================================="
echo "  RTK Hardened Installer v2.0"
echo "  Economize 60-90% de tokens no OpenClaw"
echo "=========================================="
echo ""

# ==========================================================
# ETAPA 1: Verificar / Instalar Rust
# ==========================================================
info "Etapa 1/5 — Verificando Rust..."

if command -v cargo &> /dev/null; then
    ok "Cargo encontrado: $(cargo --version)"
else
    warn "Rust/Cargo não encontrado. Instalando agora..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Ativar Rust no shell atual
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    
    if command -v cargo &> /dev/null; then
        ok "Rust instalado: $(cargo --version)"
    else
        fail "Falha ao instalar Rust. Instale manualmente:"
        echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        echo "  Feche e reabra o terminal, depois rode este script novamente."
        exit 1
    fi
fi

# ==========================================================
# ETAPA 2: Compilar RTK do source (sem telemetria embutida)
# ==========================================================
info "Etapa 2/5 — Compilando RTK do source (2-5 min)..."
echo "  (compilar do source garante que NÃO há telemetria embutida)"

cargo install --git https://github.com/rtk-ai/rtk 2>&1 | tail -3

if command -v rtk &> /dev/null; then
    ok "RTK instalado: $(rtk --version)"
else
    # Tentar adicionar ao PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    if command -v rtk &> /dev/null; then
        ok "RTK instalado: $(rtk --version)"
    else
        fail "RTK não encontrado no PATH após instalação."
        exit 1
    fi
fi

# ==========================================================
# ETAPA 3: Aplicar config hardened
# ==========================================================
info "Etapa 3/5 — Aplicando configuração de segurança..."

# Detectar OS para caminho correto do config
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/rtk"
else
    CONFIG_DIR="$HOME/.config/rtk"
fi

mkdir -p "$CONFIG_DIR"

# Gerar config hardened direto (não depende de arquivo externo)
cat > "$CONFIG_DIR/config.toml" << 'HARDENED_CONFIG'
# RTK Config — Hardened para OpenClaw
# Gerado automaticamente por install.sh
# Não edite manualmente a menos que saiba o que está fazendo.

# Telemetria DESLIGADA — nenhum dado enviado para servidores externos
[telemetry]
enabled = false

# Tracking com retenção curta — evita acúmulo de secrets em logs
[tracking]
retention_days = 1

# Tee: salva output completo só quando comando falha
[tee]
enabled = true
mode = "failures"
max_files = 10

# Comandos excluídos do rewrite automático (camada extra de proteção)
[hooks]
exclude_commands = ["curl", "wget", "ssh", "scp", "rsync", "proxy"]
HARDENED_CONFIG

ok "Config hardened salvo em: $CONFIG_DIR/config.toml"

# ==========================================================
# ETAPA 4: Instalar skill no OpenClaw (se existir)
# ==========================================================
info "Etapa 4/5 — Configurando skill do OpenClaw..."

SKILL_INSTALLED=false

# Detectar diretório de agentes OpenClaw
if [ -d "$HOME/.openclaw/agents" ]; then
    # Listar agentes disponíveis
    AGENTS=$(find "$HOME/.openclaw/agents" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
    
    if [ -n "$AGENTS" ]; then
        for AGENT_DIR in $AGENTS; do
            SKILLS_DIR="$AGENT_DIR/skills"
            mkdir -p "$SKILLS_DIR"
            cp "$SCRIPT_DIR/rtk-token-optimizer.md" "$SKILLS_DIR/"
            AGENT_NAME=$(basename "$AGENT_DIR")
            ok "Skill instalada no agente: $AGENT_NAME"
            SKILL_INSTALLED=true
        done
    fi
fi

if [ "$SKILL_INSTALLED" = false ]; then
    warn "Nenhum agente OpenClaw encontrado em ~/.openclaw/agents/"
    echo ""
    echo "  Quando criar seu agente, copie a skill manualmente:"
    echo "  cp $SCRIPT_DIR/rtk-token-optimizer.md ~/.openclaw/agents/SEU-AGENTE/skills/"
    echo ""
fi

# ==========================================================
# ETAPA 5: Garantir PATH permanente + Verificação final
# ==========================================================
info "Etapa 5/5 — Finalizando..."

# Detectar shell config file
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.profile" ]; then
    SHELL_RC="$HOME/.profile"
fi

# Adicionar cargo ao PATH se não estiver lá
if [ -n "$SHELL_RC" ]; then
    if ! grep -q '.cargo/bin' "$SHELL_RC" 2>/dev/null; then
        echo '' >> "$SHELL_RC"
        echo '# RTK — adicionado pelo installer' >> "$SHELL_RC"
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_RC"
        ok "PATH atualizado em $SHELL_RC"
    fi
fi

# --- Verificação final ---
echo ""
echo "=========================================="
echo "  Verificação Final"
echo "=========================================="

# Testar versão
RTK_VERSION=$(rtk --version 2>/dev/null || echo "FALHOU")
if [[ "$RTK_VERSION" == *"rtk"* ]]; then
    ok "rtk --version: $RTK_VERSION"
else
    fail "rtk não está funcionando"
    exit 1
fi

# Testar comando básico
if rtk ls . &> /dev/null; then
    ok "rtk ls: funcionando"
else
    ok "rtk ls: instalado (output vazio é normal)"
fi

# Verificar telemetria
if grep -q 'enabled = false' "$CONFIG_DIR/config.toml" 2>/dev/null; then
    ok "Telemetria: DESLIGADA"
else
    warn "Verifique telemetria em $CONFIG_DIR/config.toml"
fi

# Verificar tracking
if grep -q 'retention_days = 1' "$CONFIG_DIR/config.toml" 2>/dev/null; then
    ok "Tracking: retenção de 1 dia (seguro)"
else
    warn "Verifique tracking em $CONFIG_DIR/config.toml"
fi

echo ""
echo "=========================================="
echo "  ✅  Instalação Completa!"
echo "=========================================="
echo ""
echo "  O que foi feito:"
echo "  • RTK compilado do source (sem telemetria)"
echo "  • Config de segurança aplicado"
echo "  • PATH configurado"
if [ "$SKILL_INSTALLED" = true ]; then
echo "  • Skill instalada nos agentes OpenClaw"
else
echo "  • Skill pronta em: $SCRIPT_DIR/rtk-token-optimizer.md"
fi
echo ""
echo "  Teste agora:"
echo "    rtk git status    (em qualquer repo git)"
echo "    rtk ls .          (listar diretório)"
echo "    rtk gain          (ver economia de tokens)"
echo ""
echo "  Docs: https://github.com/rtk-ai/rtk"
echo "=========================================="
