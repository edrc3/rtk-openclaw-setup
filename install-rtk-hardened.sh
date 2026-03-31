#!/bin/bash
# ============================================================
# install-rtk-hardened.sh
# Instala RTK do source via Cargo e aplica config hardened
# RC3 Empreendimentos — uso com OpenClaw
# ============================================================

set -e

echo "=========================================="
echo "  RTK — Instalação Hardened (do source)"
echo "=========================================="
echo ""

# --- 1. Verificar se Rust/Cargo está instalado ---
if ! command -v cargo &> /dev/null; then
    echo "❌ Cargo (Rust) não encontrado."
    echo ""
    echo "Instale o Rust primeiro:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo ""
    echo "Depois rode este script novamente."
    exit 1
fi
echo "✅ Cargo encontrado: $(cargo --version)"

# --- 2. Instalar RTK do source (sem telemetria compilada) ---
echo ""
echo "📦 Compilando RTK do source (pode levar 2-5 min)..."
cargo install --git https://github.com/rtk-ai/rtk
echo "✅ RTK instalado: $(rtk --version)"

# --- 3. Criar diretório de config ---
CONFIG_DIR=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_DIR="$HOME/Library/Application Support/rtk"
else
    CONFIG_DIR="$HOME/.config/rtk"
fi

mkdir -p "$CONFIG_DIR"

# --- 4. Copiar config hardened ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/config.toml" ]; then
    cp "$SCRIPT_DIR/config.toml" "$CONFIG_DIR/config.toml"
    echo "✅ Config hardened instalado em: $CONFIG_DIR/config.toml"
else
    echo "⚠️  config.toml não encontrado na pasta do script."
    echo "   Copie manualmente para: $CONFIG_DIR/config.toml"
fi

# --- 5. Verificação pós-instalação ---
echo ""
echo "=========================================="
echo "  Verificação Pós-Instalação"
echo "=========================================="

# Testar se rtk funciona
if rtk --version &> /dev/null; then
    echo "✅ rtk --version: $(rtk --version)"
else
    echo "❌ rtk não está no PATH"
    echo "   Adicione ao seu .bashrc ou .zshrc:"
    echo '   export PATH="$HOME/.cargo/bin:$PATH"'
    exit 1
fi

# Testar comando básico
echo ""
echo "Testando rtk ls (diretório atual)..."
rtk ls . 2>/dev/null && echo "✅ rtk ls funcionando" || echo "⚠️  rtk ls falhou (pode ser normal em diretório vazio)"

# Verificar que telemetria está desligada
if [ -f "$CONFIG_DIR/config.toml" ]; then
    if grep -q 'enabled = false' "$CONFIG_DIR/config.toml"; then
        echo "✅ Telemetria desabilitada no config"
    else
        echo "⚠️  Verifique se telemetry.enabled = false no config"
    fi
fi

echo ""
echo "=========================================="
echo "  Instalação Completa!"
echo "=========================================="
echo ""
echo "Próximos passos:"
echo "  1. Copie rtk-token-optimizer.md para a pasta de skills"
echo "     do seu agente OpenClaw"
echo "  2. Reinicie o agente"
echo "  3. Teste com: rtk git status"
echo ""
echo "Documentação: https://github.com/rtk-ai/rtk"
echo "=========================================="
