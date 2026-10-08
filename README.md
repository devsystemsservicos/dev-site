# DEV Systems & Serviços — website

Site institucional de página única, construído com [Astro](https://astro.build).
Sem dependências de runtime, sem base de dados, deploy como ficheiros estáticos.

---

## Arrancar

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # gera dist/
npm run preview    # serve dist/ localmente
```

Node 20+ .

---

## ⚠️ Antes de publicar: confirmar o domínio

Todos os contactos são reais e estão correctos:

| | |
| --- | --- |
| WhatsApp / telefone | `+258 86 239 3272` |
| Email | `devsystemsservicos@gmail.com` |
| Localização | Maputo, Moçambique |

Fica apenas um valor por confirmar — o domínio, que veio do mockup da
identidade visual e **não foi verificado**:

| Ficheiro | Campo | Valor actual |
| --- | --- | --- |
| `src/data/site.ts` | `site.url` | `https://www.dev.co.mz` |
| `astro.config.mjs` | `site` | `https://www.dev.co.mz` |

Estes dois ficheiros têm de concordar, senão o canonical e o `JSON-LD`
apontam para o sítio errado. O `site.url` alimenta o `canonical`, a etiqueta
Open Graph e o `JSON-LD` — o único sítio onde o endereço completo é preciso.

Os blocos de números de clientes, anos de mercado, projectos entregues e
empresas em acompanhamento foram **removidos** — não se anuncia um histórico
que ainda não existe. O testemunho de cliente também foi retirado. Quando
houver números verificáveis e um cliente que autorize a citação, ambos podem
voltar em `src/components/`.

---

## O formulário de contacto

Por omissão **não tem backend**: ao enviar, abre o cliente de email do visitante
com o pedido pré-preenchido. Funciona sem nada de infraestrutura, mas obriga o
visitante a ter email configurado.

Para receber pedidos no servidor, edite `FORM_ENDPOINT` em
`src/components/Contact.astro` e ponha o URL do serviço (Formspree, Basin, ou um
endpoint próprio):

```js
const FORM_ENDPOINT = "https://formspree.io/f/SEU_ID";
```

O formulário envia `nome`, `email`, `telefone`, `empresa` e `mensagem` via POST.

---

## Estrutura

```
src/
  data/site.ts              dados da empresa, serviços, processo, helper do WhatsApp
  layouts/BaseLayout.astro  <head>, meta, JSON-LD
  styles/global.css         tokens de design, reset, primitivas
  components/
    SiteHeader.astro        navegação fixa + menu mobile
    Hero.astro              título, CTA e o grafo de nós animado
    Problem.astro           "onde o tempo se perde"
    Services.astro          explorador dos 5 serviços
    Process.astro           os 5 passos, com rasto
    About.astro             faixa-manifesto
    Contact.astro           dados, WhatsApp e formulário
    SiteFooter.astro        rodapé
    WhatsAppButton.astro    botão flutuante de WhatsApp
    WhatsAppIcon.astro      ícone (partilhado)
public/brand/               recorte do logótipo (ver brand-source/)
brand-source/               ficheiros originais de marca — não vão para produção
```

`brand-source/` guarda o logo e a folha de identidade originais, mais as
ferramentas usadas para recortar os PNG com fundo transparente. Não é publicado.

---

## Identidade visual

Cores e tipografia vêm da folha de identidade e **não devem ser alteradas**:

| Token | Hex |
| --- | --- |
| `--navy` | `#0B1F44` |
| `--blue` | `#2563EB` |
| `--cyan` | `#06B6D4` |
| `--grey` | `#E5E7EB` |
| `--mist` | `#F8FAFC` |
| `--ink-body` | `#44577A` (derivado, para contraste do corpo de texto) |
| `--blue-ink` | `#1D4ED8` (derivado; `#2563EB` não chega a 4.5:1 para texto pequeno) |

Tipografia: **Manrope**, via Google Fonts, pesos 300–800.

O logótipo é a imagem original recortada em `public/brand/mark.png`; a palavra
"DEV" é Manrope ao vivo, para escalar sem perder nitidez. Para uma versão
completamente vectorial é preciso o ficheiro original do designer.

---

## Acessibilidade e robustez

Verificado no browser:

- Navegação por teclado em todo o lado; separadores de serviço com
  `setas` / `Home` / `End` (padrão `tablist`).
- **Sem JavaScript**, os cinco serviços continuam legíveis — o `<noscript>`
  transforma o explorador numa lista simples. Nada de conteúdo preso atrás de
  script.
- O serviço seleccionado fica no URL (`#solucao-automacao`), por isso é
  ligável directamente.
- Erros do formulário são mostrados junto ao campo, com o foco no primeiro erro;
  a região de estado é `aria-live="polite"`.
- `prefers-reduced-motion` desliga o grafo do hero e todas as transições.
- Contraste medido: todas as combinações de texto passam 4.5:1 (o pior caso é
  o botão branco sobre azul, a 5.17:1). Os marcadores de nó não seleccionado
  passam o mínimo de 3:1 para gráficos com significado.

---

## Publicar

`npm run build` gera `dist/` — ficheiros estáticos, sem servidor de aplicação.

- **Netlify** — confirmar que `dist` é a pasta de publicação e o comando de
  build é `npm run build`.
- **Vercel** —>importar o repositório; o preset Astro detecta o resto.
- **Cloudflare Pages** — comando `npm run build`, output `dist`.

Antes do primeiro deploy, confirmar `site.url` em `src/data/site.ts` e
`site` em `astro.config.mjs` — ambos usam `www.dev.co.mz`.
