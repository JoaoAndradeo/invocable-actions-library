import { LightningElement, api } from 'lwc';

const DEFAULT_FLOW = 'Demo_Validar_Documento';

/**
 * Embute o Screen Flow de demonstração em uma página Lightning.
 * O componente não tem regra própria: a validação é feita pela Invocable Action dentro do Flow.
 */
export default class DemoValidarDocumento extends LightningElement {
    @api flowApiName = DEFAULT_FLOW;

    status;

    handleStatusChange(event) {
        this.status = event.detail.status;
    }

    @api
    get flowStatus() {
        return this.status;
    }
}
