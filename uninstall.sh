#!/bin/bash
# ============================================================
# RTK Hardened — Desinstalação completa
# Remove RTK, config, tracking database e skill
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "  RTK — Desinstalação"
echo "=========================================="
echo ""

read -p "Tem certeza que deseja remover o RTK? (s/N): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
    echo "Cancelado."
    exit 0
fi

# Remover binário
if command -v cargo &> /dev/null; then
    cargo uninstall rtk 2>/dev/null && echo -e "${GREEN}✅ Binário RTK removido${NC}" || echo -e "${YELLOW}⚠️  Binário não encontrado via cargo${NC}"
fi

# Remover config
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/rtk"
else
    CONFIG_DIR="$HOME/.config/rtk"
fi

if [ -d "$CONFIG_DIR" ]; then
    rm -rf "$CONFIG_DIR"
    echo -e "${GREEN}✅ Config removido: $CONFIG_DIR${NC}"
fi

# Remover tracking database
DATA_DIR="$HOME/.local/share/rtk"
if [ -d "$DATA_DIR" ]; then
    rm -rf "$DATA_DIR"
    echo -e "${GREEN}✅ Database e tee removidos: $DATA_DIR${NC}"
fi

# Remover skills do OpenClaw
if [ -d "$HOME/.openclaw/agents" ]; then
    find "$HOME/.openclaw/agents" -name "rtk-token-optimizer.md" -delete 2>/dev/null
    echo -e "${GREEN}✅ Skills RTK removidas do OpenClaw${NC}"
fi

echo ""
echo -e "${GREEN}✅ Desinstalação completa.${NC}"
echo ""
