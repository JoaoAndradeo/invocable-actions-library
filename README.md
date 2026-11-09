# Biblioteca de Invocable Actions para Flow

Seis ações para Flow, com validação de documentos, telefone, dias úteis, slug, divisão de texto e leitura de campos relacionados. Os testes incluem lotes de 200 registros.

Para o uso no Flow, veja o [guia do administrador](docs/guia-admin.md). Para o código, veja as [notas de decisões](docs/decisoes-tecnicas.md).

## Ações

| Ação (rótulo no Flow) | O que faz | Exemplo |
|---|---|---|
| Validar CPF ou CNPJ | Confere os dígitos verificadores, com ou sem máscara | `529.982.247-25` é válido (CPF) |
| Formatar telefone brasileiro | Gera E.164 e máscara, e diz se é fixo ou celular | `(11) 91234-5678` vira `+5511912345678` |
| Calcular dias úteis | Conta dias úteis e desconta os feriados cadastrados | Feriados vêm de `Feriado__mdt` |
| Gerar slug | Remove acentos e símbolos | `Configuração Avançada!` vira `configuracao-avancada` |
| Dividir texto em lista | Divide por um separador literal, sem regex | `a, b,, c` vira `a`, `b`, `c` |
| Ler campo de registro relacionado | Lê um campo pelo caminho de relacionamento | `Contact` com `Account.Industry` |

Todas as ações recebem listas, então funcionam com vários registros de uma vez. Erros de entrada voltam como resposta com mensagem, sem quebrar o Flow.

## Instalação

Pré-requisitos: Salesforce CLI e uma Developer Edition.

```bash
sf org login web --alias DevEd --set-default --instance-url https://login.salesforce.com
sf project deploy start --source-dir force-app --target-org DevEd --test-level RunLocalTests
sf org assign permset --name Invocable_Actions_User --target-org DevEd
```

O Flow `Demo_Invocable_Actions` vem em rascunho. Ative-o ou use-o como modelo.

## Testes

- 14 classes de teste, sem `SeeAllData`. A org inteira roda 143 testes, todos passando.
- Lotes de 200 registros nas quatro ações que processam listas. A ação de campo relacionado confere o número de consultas com `Limits.getQueries()`.

Cobertura das classes da biblioteca, medida na DevEd:

- 100%: `ActionMessages`, `BusinessDaysCalculator`, `CustomMetadataHolidayProvider`, `PhoneFormatter`, `SlugGenerator`, `StringSplitter`
- 96% a 98%: `CpfCnpjValidator`, `RelatedFieldReader`
- 87% a 89%: `BusinessDaysAction`, `ReadRelatedFieldAction`, `ValidateDocumentAction`
- 78% a 85%: `SplitStringAction`, `FormatPhoneAction`, `GenerateSlugAction`

Três ações ficam abaixo de 90%: `GenerateSlugAction`, `FormatPhoneAction` e `SplitStringAction`. Esses são os próximos testes a escrever.

## Estrutura

```
force-app/main/default/
├── classes/          Ações, helpers, provider de feriados e testes
├── customMetadata/   Feriados nacionais de 2026 (Feriado__mdt)
├── flows/            Demo_Invocable_Actions (rascunho)
├── objects/          Feriado__mdt
└── permissionsets/   Invocable_Actions_User
docs/                 Guia do administrador, decisões técnicas e rascunho do post
```

## Limitações

- Os feriados cadastrados são de 2026. Para outros anos, é preciso cadastrar os registros em `Feriado__mdt`.
- O telefone é validado pelo formato. A biblioteca não verifica se a linha existe.
- Três ações estão abaixo de 90% de cobertura.
