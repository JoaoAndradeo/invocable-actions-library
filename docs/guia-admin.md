# Guia do administrador: Invocable Actions para Flow

> Escrito para: administradores Salesforce que vão montar Flows com estas ações.

## Antes de começar

1. Atribua a permission set **Invocable_Actions_User** aos usuários que vão rodar os Flows.
2. Confira os feriados em **Setup → Custom Metadata Types → Feriado → Manage Records**. A ação de dias úteis usa esses registros. O padrão são os nove feriados nacionais de 2026.

## As ações, uma por uma

Em um Flow, adicione o elemento **Action** e escolha a ação pelo rótulo.

### 1. Validar CPF ou CNPJ

| Entrada | Obrigatória | Descrição |
|---|---|---|
| CPF ou CNPJ | Sim | Com ou sem máscara |

| Saída | Descrição |
|---|---|
| É válido? | Verdadeiro se os dígitos verificadores conferem |
| Tipo (CPF ou CNPJ) | Tipo identificado |
| Número normalizado (só dígitos) | Use este valor para gravar no campo |
| Mensagem | Explicação em texto, útil para mostrar ao usuário |

**Exemplo de uso:** antes de salvar um cadastro, valide o documento e exiba a mensagem se "É válido?" for falso.

### 2. Formatar telefone brasileiro

| Entrada | Obrigatória | Descrição |
|---|---|---|
| Telefone | Sim | Aceita com ou sem DDI 55, DDD e máscara |

| Saída | Descrição |
|---|---|
| É válido? | Verdadeiro se o formato for reconhecido |
| Telefone E.164 (+5511912345678) | Formato para integrações |
| Telefone com máscara ((11) 91234-5678) | Formato para exibição |
| Tipo (FIXO ou CELULAR) | Tipo da linha |
| Mensagem | Explicação em texto |

### 3. Calcular dias úteis

| Entrada | Obrigatória | Descrição |
|---|---|---|
| Data inicial | Sim | Esta data **não entra** na contagem |
| Data final | Sim | Esta data **entra** na contagem |

| Saída | Descrição |
|---|---|
| Sucesso? | Verdadeiro se o cálculo foi feito |
| Dias úteis | Quantidade de dias úteis no intervalo |
| Mensagem | Explicação em texto |

Sábados, domingos e feriados cadastrados em `Feriado__mdt` são descontados.

### 4. Gerar slug

| Entrada | Obrigatória | Descrição |
|---|---|---|
| Texto | Sim | Texto de origem |
| Separador | Não | Padrão: hífen (`-`). Vazio junta as palavras sem separador |

| Saída | Descrição |
|---|---|
| Sucesso? | Verdadeiro se gerou o slug |
| Slug | Texto sem acentos e símbolos |
| Mensagem | Explicação em texto |

**Exemplo:** `Configuração Avançada!` vira `configuracao-avancada`.

### 5. Dividir texto em lista

| Entrada | Obrigatória | Descrição |
|---|---|---|
| Texto | Sim | Texto a dividir |
| Separador | Não | Padrão: vírgula (`,`). Tratado como texto literal, não como expressão regular |
| Remover itens vazios? | Não | Padrão: sim |
| Aparar espaços? | Não | Padrão: sim |

| Saída | Descrição |
|---|---|
| Sucesso? | Verdadeiro se dividiu o texto |
| Itens | Lista com os itens |
| Quantidade de itens | Número de itens |
| Mensagem | Explicação em texto |

### 6. Ler campo de registro relacionado

| Entrada | Obrigatória | Descrição |
|---|---|---|
| Registro de origem | Sim | Ex.: o Contact cujo campo da Account será lido |
| Caminho do campo | Sim | Ex.: `Account.Industry`. Até 5 níveis de relacionamento |

| Saída | Descrição |
|---|---|
| Sucesso? | Verdadeiro se a leitura funcionou |
| Valor encontrado? | Verdadeiro se o campo tem valor |
| Valor (texto) | Valor como texto |
| Mensagem | Explicação em texto |

**Atenção:** o caminho é validado contra a estrutura do objeto. Um campo que não existe devolve uma mensagem de erro, e não quebra o Flow.

## Como adicionar feriados

1. Em **Setup → Custom Metadata Types → Feriado → Manage Records**, clique em **New**.
2. Preencha o **Label** e a **Data** do feriado.
3. Salve. A ação de dias úteis passa a considerar o novo feriado na próxima execução.

## Perguntas frequentes

- **O Flow de demonstração não aparece como ativo.** Ele fica em rascunho de propósito. Ative-o ou copie-o como modelo.
- **A ação devolveu "Sucesso? = falso".** Leia a mensagem: ela explica se o problema é o formato da entrada ou um campo inexistente.
