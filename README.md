# RTK Hardened Setup para OpenClaw

Instalação **automática e segura** do [RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) para agentes OpenClaw.

**Um comando instala tudo.** Não precisa configurar nada manualmente.

## O que é

O RTK comprime a saída de comandos de terminal antes que chegue ao seu agente de IA. Resultado: **60-90% menos tokens consumidos** por sessão.

```
Sem RTK:  git status → 2.000 tokens
Com RTK:  rtk git status → 200 tokens  (-90%)
```

## O que este setup faz de diferente

O RTK oficial tem [vulnerabilidades documentadas](https://github.com/rtk-ai/rtk/issues/640). Este setup resolve automaticamente:

| Proteção | Como |
|---|---|
| ✅ Sem telemetria | Compila do source, sem endpoint embutido |
| ✅ Sem shell injection | Skill bloqueia comandos perigosos |
| ✅ Sem vazamento de secrets | Tracking com retenção de 1 dia |
| ✅ Sem auto-approval | Uso via skill, sem hook automático |

## Instalação

```bash
git clone https://github.com/edrc3/rtk-openclaw-setup.git
cd rtk-openclaw-setup
chmod +x install.sh
./install.sh
```

O script cuida de tudo: instala Rust (se necessário), compila RTK do source, aplica config de segurança, configura o PATH e instala a skill nos agentes OpenClaw.

**Primeira instalação leva 5-10 minutos** (compilação do Rust).

## Verificar se está funcionando

```bash
rtk --version     # versão instalada
rtk ls .          # teste rápido
rtk gain          # economia de tokens acumulada
```

## Atualizar

```bash
cargo install --git https://github.com/rtk-ai/rtk --force
```

O config de segurança é preservado.

## Desinstalar

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Remove tudo: binário, config, database e skills.

## Arquivos

| Arquivo | Função |
|---|---|
| `install.sh` | Instalação completa e automática |
| `uninstall.sh` | Remoção completa |
| `rtk-token-optimizer.md` | Skill de segurança para o agente OpenClaw |

## Para quem usa VPS (Hostinger, etc.)

O mesmo script funciona em servidores Ubuntu. Conecte pelo terminal web e rode os mesmos comandos da seção "Instalação" acima.

## Créditos

- [RTK](https://github.com/rtk-ai/rtk) — Projeto original
- Análise de segurança: [Issue #640](https://github.com/rtk-ai/rtk/issues/640)
- Setup hardened: [RC3 Empreendimentos](https://github.com/edrc3)
