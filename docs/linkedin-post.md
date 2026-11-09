# Rascunho do post para o LinkedIn

> Escrito para: pessoas da rede no LinkedIn (recrutadores e devs Salesforce), em tom de portfólio.

---

Construí uma biblioteca de Invocable Actions para Flow, com seis ações que resolvem tarefas que aparecem em quase todo processo de cadastro no Brasil.

🔹 **Validar CPF e CNPJ** com os dígitos verificadores
🔹 **Formatar telefone** no padrão E.164 e com máscara
🔹 **Calcular dias úteis**, descontando feriados cadastrados em Custom Metadata
🔹 **Gerar slug**, sem acentos nem símbolos
🔹 **Dividir texto** em lista, com separador literal
🔹 **Ler campo de registro relacionado**, respeitando a permissão de quem roda o Flow

Alguns pontos que eu quis demonstrar:

✔️ Todas as ações recebem listas, para funcionar em lote, e não um registro por vez.
✔️ Os testes medem o número de consultas com `Limits.getQueries()`, em lotes de 200 registros.
✔️ Erros de entrada viram uma resposta com mensagem, e não uma exceção que quebra o Flow.
✔️ Documentação para administradores, em português, separada da documentação técnica.

Também sou honesto sobre o que ainda falta: três ações estão com cobertura abaixo da meta de 90%, e eu vou documentar isso e fechar essa lacuna.

Código e documentação: [link do repositório]

#Salesforce #Flow #Apex #SalesforceDeveloper #LWC
