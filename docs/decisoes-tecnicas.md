# Biblioteca de Invocable Actions: decisões técnicas

> Escrito para: desenvolvedores Salesforce que vão manter ou revisar esta biblioteca.

## 1. Padrão das ações

Cada ação é uma classe com `@InvocableMethod` que recebe uma lista de requisições (`@InvocableVariable`) e devolve uma lista de respostas, na mesma ordem.

- **Por que lista:** o Flow pode chamar a ação com muitos registros de uma vez. A ação precisa processar o lote inteiro, não um registro por vez.
- **Por que resposta com "Sucesso?" e "Mensagem":** o administrador consegue tratar a falha no Flow sem que a transação quebre. Um erro de entrada vira uma resposta, não uma exceção.

## 2. Bulkificação

- **Feriados lidos uma vez por lote** (`BusinessDaysAction`): a ação consulta os feriados para o intervalo que cobre o lote inteiro, em uma única consulta.
- **Um provider injetável** (`IHolidayProvider`): o cálculo recebe o conjunto de feriados, e não consulta o banco por conta própria. Isso permite testar sem depender dos registros da org.
- **Consultas medidas nos testes:** `ReadRelatedFieldActionTest` usa `Limits.getQueries()` para provar que um lote de 200 contatos faz uma consulta, não 200.

## 3. Decisões por ação

| Ação | Decisão | Motivo |
|---|---|---|
| Validar CPF/CNPJ | Verificação pelos dígitos verificadores, sem consulta externa | Não depende de serviço de terceiros e é determinística |
| Formatar telefone | Sem verificação de existência da linha | Não há serviço público confiável sem custo; o formato cobre o caso de cadastro |
| Dias úteis | Início excluído e fim incluído | Convenção que evita contar o mesmo dia duas vezes em intervalos encadeados |
| Gerar slug | Remove acentos por tabela de caracteres, sem depender de locale | Resultado igual em qualquer org |
| Dividir texto | Separador literal, sem regex | Um separador como `.` ou `|` não pode virar expressão regular por engano |
| Ler campo relacionado | Valida o caminho contra o describe e usa `WITH USER_MODE` | Campo inexistente vira mensagem, e a leitura respeita a permissão de quem roda o Flow |

## 4. Segurança

- `ReadRelatedFieldAction` consulta em `WITH USER_MODE`: o usuário só lê o que já pode ver.
- As demais ações não fazem consulta ao banco, exceto a de dias úteis, que lê apenas `Feriado__mdt` (metadado público da org).

## 5. Cobertura

A meta do projeto é acima de 90% em todas as classes. **Essa meta ainda não foi atingida** em três ações: `GenerateSlugAction` (78%), `FormatPhoneAction` (83%) e `SplitStringAction` (85%). Os caminhos não cobertos são os de erro de entrada e de borda de texto. O próximo passo é adicionar testes para esses caminhos.

## 6. Lições registradas durante o desenvolvimento

Estas lições vieram de problemas reais encontrados na construção da biblioteca:

- **Apex é case-insensitive.** Uma variável local chamada `contact` faz `Contact.SObjectType` ser lido como acesso a campo da variável. Use `Schema.getGlobalDescribe().get('Contact')`.
- **`Account.OwnerId` não é polimórfico:** aponta só para `User`. Para testar polimorfismo, use `Case.OwnerId`.
- **Classe só com constantes tem 0% de cobertura.** Um construtor `private` vazio que não é executado também pode derrubar a cobertura (chegou a 66% em um caso).
- **Flow não tem tipo `Integer`:** use `Number` nas entradas e saídas.
- **Custom Metadata XML precisa declarar `xmlns:xsd`** para usar `xsi:type="xsd:date"`.
- **Validação com testes específicos:** o parâmetro é `--tests` seguido dos nomes separados por espaço, não por vírgula.
- **Muitos `--source-dir` estouram o limite de linha de comando do Windows.** Use `--manifest` com um `package.xml`.
- **Não use `sf org display` para checar a conexão:** ele expõe credenciais. Para validar a conexão, use `sf org list` ou uma consulta simples.
- **Metadados em sessões paralelas podem mudar em disco.** Confira o estado atual de um arquivo antes de editá-lo.
