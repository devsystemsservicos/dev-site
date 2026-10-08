/**
 * Single source of truth for company details.
 * Swap the placeholder values here and the whole site updates.
 */

export const site = {
  name: "DEV Systems & Serviços",
  shortName: "DEV",
  tagline: "Conectando processos. Simplificando negócios.",
  url: "https://www.dev.co.mz",
  description:
    "Desenvolvemos, integramos e automatizamos a tecnologia do seu negócio em Maputo. Sistemas ligados, processos simples.",
  locale: "pt_MZ",
} as const;

/**
 * The +258 86 239 3272 number is the WhatsApp line as well, so the display
 * form, the JSON-LD telephone and every wa.me link all resolve to one person.
 */
export const contact = {
  phoneDisplay: "+258 86 239 3272",
  whatsappNumber: "258862393272",
  email: "devsystemsservicos@gmail.com",
  address: "Maputo, Moçambique",
} as const;

/** wa.me needs the number without +, with an optional prefilled message. */
export const whatsappLink = (message?: string) =>
  `https://wa.me/${contact.whatsappNumber}${
    message ? `?text=${encodeURIComponent(message)}` : ""
  }`;

export const services = [
  {
    id: "desenvolvimento",
    name: "Desenvolvimento",
    summary: "Sistemas, aplicativos e plataformas web.",
    icon: "code",
    includes: [
      "Sites e plataformas web",
      "Aplicativos internos da empresa",
      "Sistemas de gestão à medida",
    ],
  },
  {
    id: "automacao",
    name: "Automação",
    summary: "Processos mais rápidos e eficientes.",
    icon: "gear",
    includes: [
      "Fluxos de trabalho automáticos",
      "Relatórios que se geram sozinhos",
      "Tarefas repetitivas transferidas para o sistema",
    ],
  },
  {
    id: "integracao",
    name: "Integração",
    summary: "Conectando sistemas e equipas.",
    icon: "cloud",
    includes: [
      "ERP, CRM e contabilidade ligados entre si",
      "Bases de dados reunidas num só lugar",
      "APIs e serviços de terceiros",
    ],
  },
  {
    id: "solucoes",
    name: "Soluções Empresariais",
    summary: "Tecnologia para crescer o seu negócio.",
    icon: "chart",
    includes: [
      "Diagnóstico da situação actual",
      "Arquitectura e planeamento por fases",
      "Critérios de prioridade e investimento",
    ],
  },
  {
    id: "suporte",
    name: "Suporte & Serviços",
    summary: "Acompanhamento contínuo.",
    icon: "support",
    includes: [
      "Manutenção e actualizações",
      "Monitorização e avisos antecipados",
      "Formação das suas equipas",
    ],
  },
] as const;

/** A genuine sequence, so numbered steps are meaningful here. */
export const process = [
  {
    title: "Conversar",
    body: "Perceber o processo como está hoje, quem o executa e o que trava.",
  },
  {
    title: "Desenhar",
    body: "Definir o que muda, o que fica intacto e em que ordem acontece.",
  },
  {
    title: "Construir",
    body: "Desenvolver por fases, com algo a funcionar a cada entrega.",
  },
  {
    title: "Entregar",
    body: "Fazer a transição, formar as equipas e deixar tudo documentado.",
  },
  {
    title: "Acompanhar",
    body: "Suporte contínuo, monitorização e ajustes à medida que cresces.",
  },
] as const;
