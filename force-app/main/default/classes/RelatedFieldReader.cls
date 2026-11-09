/**
 * Lê um campo de um registro relacionado, por exemplo Account.Industry a partir de um Contact.
 *
 * O caminho é checado contra o describe antes de montar a consulta, então só nomes do
 * schema entram no SOQL. A leitura usa WITH USER_MODE, respeitando FLS e compartilhamento.
 * Todos os IDs são lidos com uma única consulta.
 */
public with sharing class RelatedFieldReader {

    public static final Integer MAX_PATH_DEPTH = 5;

    public class Result {
        public Boolean isSuccess;
        public Boolean found;
        public String value;
        public String message;

        public Result(Boolean isSuccess, String message) {
            this(isSuccess, false, null, message);
        }

        public Result(Boolean isSuccess, Boolean found, String value, String message) {
            this.isSuccess = isSuccess;
            this.found = found;
            this.value = value;
            this.message = message;
        }
    }

    /** Um Result por ID, na mesma ordem. Todos os IDs devem ser do mesmo tipo de objeto. */
    public static List<Result> readAll(Schema.SObjectType rootType, String fieldPath, List<Id> recordIds) {
        List<Result> results = new List<Result>();
        if (recordIds == null || recordIds.isEmpty()) {
            return results;
        }

        Path path = null;
        String pathError = null;
        try {
            path = parsePath(rootType, fieldPath);
        } catch (IllegalArgumentException e) {
            pathError = e.getMessage();
        }

        Set<Id> ids = new Set<Id>();
        for (Id recordId : recordIds) {
            if (recordId != null) {
                ids.add(recordId);
            }
        }
        Map<Id, SObject> rowsById = (path == null) ? new Map<Id, SObject>() : queryRows(path, ids);

        for (Id recordId : recordIds) {
            if (recordId == null) {
                results.add(new Result(false, 'Informe o registro de origem.'));
            } else if (pathError != null) {
                results.add(new Result(false, pathError));
            } else if (!rowsById.containsKey(recordId)) {
                results.add(new Result(true, 'Registro não encontrado ou sem acesso.'));
            } else {
                results.add(readValue(rowsById.get(recordId), path));
            }
        }
        return results;
    }

    private static Map<Id, SObject> queryRows(Path path, Set<Id> ids) {
        if (ids.isEmpty()) {
            return new Map<Id, SObject>();
        }
        String soql = 'SELECT Id, ' + path.soqlField() + ' FROM ' + path.rootName
            + ' WHERE Id IN :ids WITH USER_MODE';
        return new Map<Id, SObject>(Database.query(soql));
    }

    private static Result readValue(SObject row, Path path) {
        SObject current = row;
        for (String relationship : path.relationships) {
            current = current.getSObject(relationship);
            if (current == null) {
                return new Result(true, 'Registro relacionado vazio.');
            }
        }

        Object raw = current.get(path.leafField);
        if (raw == null) {
            return new Result(true, 'Campo sem valor.');
        }
        return new Result(true, true, String.valueOf(raw), 'Valor encontrado.');
    }

    /** Valida o caminho e lança IllegalArgumentException com a mensagem para o usuário. */
    private static Path parsePath(Schema.SObjectType rootType, String fieldPath) {
        if (rootType == null) {
            throw new IllegalArgumentException('Objeto de origem inválido.');
        }
        String cleanPath = (fieldPath == null) ? '' : fieldPath.trim();
        if (String.isBlank(cleanPath)) {
            throw new IllegalArgumentException('Informe o caminho do campo, por exemplo Account.Industry.');
        }

        List<String> segments = cleanPath.split('\\.');
        if (segments.size() > MAX_PATH_DEPTH) {
            throw new IllegalArgumentException('Caminho muito longo: o máximo são ' + MAX_PATH_DEPTH + ' níveis.');
        }

        Path path = new Path();
        path.rootName = rootType.getDescribe().getName();
        Schema.SObjectType current = rootType;

        for (Integer i = 0; i < segments.size() - 1; i++) {
            String segment = segments[i].trim();
            Schema.DescribeFieldResult relationship = findRelationship(current, segment);
            if (relationship == null || !relationship.isAccessible()) {
                throw new IllegalArgumentException('Relacionamento "' + segment + '" não existe em '
                    + current.getDescribe().getName() + ' ou não está acessível.');
            }
            List<Schema.SObjectType> targets = relationship.getReferenceTo();
            if (targets.size() != 1) {
                throw new IllegalArgumentException('Relacionamento "' + segment + '" é polimórfico e não é suportado.');
            }
            path.relationships.add(relationship.getRelationshipName());
            current = targets[0];
        }

        String leafName = segments[segments.size() - 1].trim();
        Schema.SObjectField leaf = current.getDescribe().fields.getMap().get(leafName.toLowerCase());
        if (leaf == null || !leaf.getDescribe().isAccessible()) {
            throw new IllegalArgumentException('Campo "' + leafName + '" não existe em '
                + current.getDescribe().getName() + ' ou não está acessível.');
        }
        path.leafField = leaf.getDescribe().getName();
        return path;
    }

    private static Schema.DescribeFieldResult findRelationship(Schema.SObjectType objectType, String relationshipName) {
        for (Schema.SObjectField field : objectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult description = field.getDescribe();
            if (description.getType() == Schema.DisplayType.REFERENCE
                && String.isNotBlank(description.getRelationshipName())
                && description.getRelationshipName().equalsIgnoreCase(relationshipName)) {
                return description;
            }
        }
        return null;
    }

    /** Caminho já validado: objeto raiz, relacionamentos na ordem e campo final. */
    private class Path {
        String rootName;
        List<String> relationships = new List<String>();
        String leafField;

        String soqlField() {
            List<String> parts = new List<String>(relationships);
            parts.add(leafField);
            return String.join(parts, '.');
        }
    }
}
