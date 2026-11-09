# Rascunho do post para o LinkedIn

> Escrito para: pessoas da rede no LinkedIn (desenvolvedores Salesforce).

---

Fiz uma biblioteca de Invocable Actions para Flow, com seis ações que ajudam em cadastros: validar CPF e CNPJ, formatar telefone, calcular dias úteis, gerar slug, dividir texto e ler um campo de um registro relacionado.

As ações:

- **Validar CPF ou CNPJ:** confere os dígitos verificadores, com ou sem máscara.
- **Formatar telefone:** gera o formato E.164 e a máscara, e informa se é fixo ou celular.
- **Calcular dias úteis:** desconta os feriados cadastrados em Custom Metadata.
- **Gerar slug:** remove acentos e símbolos.
- **Dividir texto:** divide por um separador literal, sem regex.
- **Ler campo relacionado:** lê um campo pelo caminho de relacionamento, como `Account.Industry`.

Cada ação recebe uma lista, então funciona com vários registros do Flow de uma vez. Um erro de entrada volta como resposta com mensagem, sem quebrar o Flow.

Os testes incluem lotes de 200 registros. A ação de campo relacionado tem um teste que confere o número de consultas.

A cobertura não atingiu a meta de 90% em todas as classes: três ações ficam entre 78% e 85%. Os números por classe estão no README.

Código e documentação: https://github.com/JoaoGuilherme777/invocable-actions-library

#Salesforce #Flow #Apex #SalesforceDeveloper
