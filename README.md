OpenCode Settings
=================

Requisitos mínimos
- Sistema: WSL (Windows Subsystem for Linux). Os scripts validam `/proc/version` e abortam fora do WSL.
- Ferramentas: `curl` (preferencial) ou `npm` (fallback) disponíveis no PATH.
- Acesso ao diretório deste repositório (para executar os scripts em `install/`).

Como instalar (modo desenvolvedor)
1. Abra um terminal WSL no diretório raiz deste repositório.
2. Execute o instalador de desenvolvedor:

```bash
bash install/dev.sh
```

O script verifica a plataforma, instala o `opencode` CLI (via instalador oficial ou `npm` como fallback), cria `~/.config/opencode/opencode.json` e copia os agentes de `agent/` para `~/.config/opencode/agent` usando um mecanismo que preserva configurações personalizadas.

Agentes presentes hoje
- `agent/nextjs.md` — Next.js / React Expert Agent
  - Marker: `@nextjs`
  - Propósito: padronizar e gerar código Next.js/React de produção — foco em TypeScript estrito, SEO, performance, acessibilidade e arquitetura limpa.
  - Regras principais: TypeScript (`strict: true`) obrigatório; preferir Server Components e App Router; separar UI/business/data; escrever testes (Jest/RTL/Playwright).
  - Arquivo com especificação completa: `agent/nextjs.md`

- `agent/laravel.md` — Laravel + Livewire Expert Agent
  - Marker: `@laravel`
  - Propósito: guiar geração/revisão de código Laravel e Livewire com ênfase em tipagem forte, segurança e qualidade (Pint/PHPStan).
  - Regras principais: `declare(strict_types=1);` obrigatório; tipagem explícita de propriedades e retornos; extrair queries complexas em Query Objects; preferir Actions e componentes Livewire tipados.
  - Arquivo com especificação completa: `agent/laravel.md`

- `agent/fullstack.md` — Fullstack Next.js + Laravel Expert Agent
  - Marker: `@fullstack`
  - Propósito: unificar a expertise de Next.js e Laravel para o desenvolvimento de aplicações fullstack completas e integradas.
  - Regras principais: combina as regras de tipagem estrita do Next.js e Laravel; foco em contratos de API robustos; arquitetura limpa em ambas as pontas.
  - Arquivo com especificação completa: `agent/fullstack.md`

Observações rápidas
- Se o instalador mostrar "This installer only supports WSL", execute os scripts dentro de uma sessão WSL.
- Se o `opencode` não for instalado automaticamente, rode manualmente: `curl -fsSL https://opencode.ai/install | bash` ou `npm install -g opencode-ai`.
