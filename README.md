OpenCode Settings
=================

O repositório fornece scripts e configuração para instalar e configurar agentes e integrações do OpenCode no seu ambiente (focado em WSL — Windows Subsystem for Linux).

O que este repositório faz
- Automatiza a instalação do `opencode` CLI (via instalador oficial ou npm como fallback).
- Cria a configuração base do OpenCode em `~/.config/opencode/opencode.json`.
- Copia agentes (ex.: `agent/laravel.md`, `agent/nextjs.md`) para `~/.config/opencode/agent` usando um mecanismo de cópia inteligente que preserva arquivos customizados do usuário.

Principais arquivos
- `install/dev.sh` — script de instalação para desenvolvedores (usa `install/common.sh`).
- `install/common.sh` — funções comuns de instalação, checagem de WSL, criação de diretórios e cópia inteligente.
- `agent/` — definição/descrição dos agentes (ex.: `laravel.md`, `nextjs.md`).
- `opencode.json` — configuração local de exemplo usada pelo repositório.

Requisitos
- Sistema: WSL (o instalador verifica `/proc/version` e exige WSL).
- Ferramentas: `curl` (preferencial para instalar o CLI). `npm` é usado como fallback.

Instalação (modo desenvolvedor)
1. Abra um terminal WSL no diretório deste repositório.
2. Torne o instalador executável (se necessário) e execute:

```bash
bash install/dev.sh
```

O que o script faz
- Verifica se está em WSL; aborta se não for.
- Tenta instalar o `opencode` CLI via instalador oficial (`curl ... | bash`).
- Se falhar, tenta instalar via `npm install -g opencode-ai` (quando `npm` estiver disponível).
- Cria os diretórios de configuração em `~/.config/opencode` e grava um `opencode.json` padrão.
- Copia os arquivos de agente do diretório `agent/` para `~/.config/opencode/agent` usando regras inteligentes (não sobrescreve arquivos não gerenciados pelo instalador; pergunta ao usuário quando houver atualizações).

Uso após a instalação
- Autentique-se e inicie o OpenCode:

```bash
opencode auth login        # Login com GitHub Copilot
opencode mcp auth jira     # (opcional) autenticar Jira
opencode mcp auth notion   # (opcional) autenticar Notion
opencode                   # Inicia OpenCode
```

Comportamento da cópia inteligente
- Arquivos marcados com o marcador `@dev` são considerados gerenciados e podem ser atualizados automaticamente.
- Se um arquivo alvo existir e não contiver o marcador, o instalador o preserva (não sobrescreve).
- Quando há diferenças entre fonte e destino, o instalador pergunta (atualizar/ignorar/todas/pular todas).

Personalização
- Você pode editar `~/.config/opencode/opencode.json` para habilitar/desabilitar MCPs e ajustar comandos locais.
- Adicione novos agentes colocando arquivos em `agent/` e rodando novamente `install/dev.sh` para copiá-los.

Solução de problemas
- Mensagem: "This installer only supports WSL" — significa que você não está executando o script dentro do WSL.
- `opencode` não instalado — verifique se `curl` e/ou `npm` estão disponíveis; rodar manualmente `curl -fsSL https://opencode.ai/install | bash` pode ajudar.

Próximos passos sugeridos
1. Rodar os comandos de autenticação do `opencode` mostrados em "Uso após a instalação".
2. Personalizar `~/.config/opencode/opencode.json` conforme suas necessidades.
3. Abrir `agent/` para editar ou adicionar novos agentes.
