/**
 * Ação de Flow: lê um campo de um registro relacionado, sem erro quando o registro não existe.
 *
 * As linhas são agrupadas por tipo de registro e caminho do campo. Cada grupo faz uma consulta,
 * então 200 linhas do mesmo tipo custam uma consulta. A ordem das respostas é a das requisições.
 */
public inherited sharing class ReadRelatedFieldAction {

    @InvocableMethod(
        label='Ler campo de registro relacionado'
        description='Retorna o valor de um campo de um registro relacionado (ex.: Account.Industry a partir de um Contact). Se o registro ou o relacionamento não existir, retorna found = false sem erro.'
        category='Utilidades'
    )
    public static List<Response> read(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null) {
            return responses;
        }

        Map<Integer, Response> responseByRow = new Map<Integer, Response>();
        Map<String, List<Integer>> rowsByGroup = new Map<String, List<Integer>>();
        Map<String, Schema.SObjectType> typeByGroup = new Map<String, Schema.SObjectType>();
        Map<String, String> pathByGroup = new Map<String, String>();

        for (Integer i = 0; i < requests.size(); i++) {
            Request request = requests[i];
            if (request == null || request.recordId == null) {
                responseByRow.put(i, nullEntryResponse());
                continue;
            }

            String path = String.isBlank(request.fieldPath) ? '' : request.fieldPath.trim();
            Schema.SObjectType recordType = request.recordId.getSObjectType();
            String groupKey = recordType.getDescribe().getName() + '|' + path.toLowerCase();

            if (!rowsByGroup.containsKey(groupKey)) {
                rowsByGroup.put(groupKey, new List<Integer>());
                typeByGroup.put(groupKey, recordType);
                pathByGroup.put(groupKey, path);
            }
            rowsByGroup.get(groupKey).add(i);
        }

        for (String groupKey : rowsByGroup.keySet()) {
            List<Integer> rows = rowsByGroup.get(groupKey);
            List<Id> ids = new List<Id>();
            for (Integer row : rows) {
                ids.add(requests[row].recordId);
            }

            List<RelatedFieldReader.Result> results;
            try {
                results = RelatedFieldReader.readAll(typeByGroup.get(groupKey), pathByGroup.get(groupKey), ids);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'ReadRelatedFieldAction: ' + e.getMessage());
                results = errorResults(ids.size());
            }

            for (Integer j = 0; j < rows.size(); j++) {
                responseByRow.put(rows[j], toResponse(results[j]));
            }
        }

        for (Integer i = 0; i < requests.size(); i++) {
            responses.add(responseByRow.get(i));
        }
        return responses;
    }

    private static Response toResponse(RelatedFieldReader.Result result) {
        Response response = new Response();
        response.isSuccess = result.isSuccess;
        response.found = result.found;
        response.value = result.value;
        response.message = result.message;
        return response;
    }

    private static Response nullEntryResponse() {
        Response response = new Response();
        response.isSuccess = false;
        response.found = false;
        response.message = ActionMessages.NULL_ENTRY;
        return response;
    }

    private static List<RelatedFieldReader.Result> errorResults(Integer size) {
        List<RelatedFieldReader.Result> results = new List<RelatedFieldReader.Result>();
        for (Integer i = 0; i < size; i++) {
            results.add(new RelatedFieldReader.Result(false, ActionMessages.GENERIC_ERROR));
        }
        return results;
    }

    public class Request {
        @InvocableVariable(label='Registro de origem' description='Ex.: o Contact cujo campo da Account será lido.' required=true)
        public Id recordId;

        @InvocableVariable(label='Caminho do campo' description='Ex.: Account.Industry. Até 5 níveis de relacionamento.' required=true)
        public String fieldPath;
    }

    public class Response {
        @InvocableVariable(label='Sucesso?')
        public Boolean isSuccess;

        @InvocableVariable(label='Valor encontrado?')
        public Boolean found;

        @InvocableVariable(label='Valor (texto)')
        public String value;

        @InvocableVariable(label='Mensagem')
        public String message;
    }
}
