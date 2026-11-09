# Biblioteca de Invocable Actions para Flow

Seis ações prontas para usar em Flow no Salesforce, com testes em lote de 200 registros e documentação para administradores.

> Para administradores: [guia de uso no Flow](docs/guia-admin.md).
> Para desenvolvedores: [decisões técnicas](docs/decisoes-tecnicas.md).

## As ações

| Ação (rótulo no Flow) | O que faz | Exemplo |
|---|---|---|
| **Validar CPF ou CNPJ** | Confere os dígitos verificadores, com ou sem máscara | `529.982.247-25` → válido, CPF |
| **Formatar telefone brasileiro** | Gera o formato E.164 e a máscara, e informa se é fixo ou celular | `(11) 91234-5678` → `+5511912345678` |
| **Calcular dias úteis** | Conta dias úteis entre duas datas, descontando os feriados cadastrados | 2 datas → 10 dias úteis |
| **Gerar slug** | Remove acentos e símbolos, com separador configurável | `Configuração Avançada!` → `configuracao-avancada` |
| **Dividir texto em lista** | Divide por um separador literal, sem regex | `a, b,, c` → `a`, `b`, `c` |
| **Ler campo de registro relacionado** | Lê um campo pelo caminho de relacionamento | `Contact` → `Account.Industry` |

## Instalação

**Pré-requisitos:** Salesforce CLI e uma org Developer Edition ou sandbox.

```bash
sf org login web --alias MinhaOrg --set-default --instance-url https://login.salesforce.com
sf project deploy start --source-dir force-app --target-org MinhaOrg --test-level RunLocalTests
sf org assign permset --name Invocable_Actions_User --target-org MinhaOrg
```

Depois de publicar, o Flow de demonstração (`Demo_Invocable_Actions`) fica em rascunho. Ative-o ou use-o como modelo.

## Testes

- **14 classes de teste**, com `Assert` e sem `SeeAllData`.
- **Testes de lote:** quatro ações têm teste com 200 registros. Em `ReadRelatedFieldAction`, o teste mede o número de consultas com `Limits.getQueries()`.
- **Cobertura por classe**, medida na DevEd:

| Classe | Cobertura |
|---|---|
| ActionMessages, BusinessDaysCalculator, CustomMetadataHolidayProvider, PhoneFormatter, SlugGenerator, StringSplitter | 100% |
| CpfCnpjValidator | 98% |
| RelatedFieldReader | 96% |
| BusinessDaysAction | 89% |
| ReadRelatedFieldAction, ValidateDocumentAction | 87% |
| SplitStringAction | 85% |
| FormatPhoneAction | 83% |
| GenerateSlugAction | 78% |

**A meta de 90% em todas as classes ainda não foi atingida.** Três ações ficam abaixo disso (`GenerateSlugAction`, `FormatPhoneAction` e `SplitStringAction`). Os números acima são os medidos na org, não estimados.

## Estrutura

```
force-app/main/default/
├── classes/          Ações, helpers, provider de feriados e testes
├── customMetadata/   Nove feriados nacionais de 2026 (Feriado__mdt)
├── flows/            Demo_Invocable_Actions (rascunho)
├── objects/          Feriado__mdt, com o campo Data__c
└── permissionsets/   Invocable_Actions_User
docs/
├── guia-admin.md
├── decisoes-tecnicas.md
└── linkedin-post.md
```

## Limitações conhecidas

- **Feriados de 2026 apenas.** Para outros anos, cadastre os registros de `Feriado__mdt`.
- **Cobertura abaixo de 90% em três ações**, como descrito acima.
- **Validação de CEP e telefone sem consulta externa.** O telefone é checado pelo formato; não há verificação de existência da linha.
- **Sem análise estática registrada neste repositório.**
