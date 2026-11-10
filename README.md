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

## Por que importa

Administradores precisam das mesmas validações e transformações em vários Flows: CPF, telefone, dias úteis, slug. Sem uma biblioteca, cada uma vira código novo ou lógica copiada em cada Flow, e a correção precisa ser feita em todos.

## Ganho

- O administrador resolve sem código: arrasta a ação para o Flow.
- A regra fica em um lugar só. Por exemplo, os feriados vêm de `Feriado__mdt`, e uma correção vale para todos os Flows.
- As ações aceitam listas, então um Flow processa vários registros sem fazer uma chamada por registro.
