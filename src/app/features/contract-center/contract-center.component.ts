import { Component, OnInit, signal, WritableSignal } from '@angular/core';
import { PoModule, PoPageAction, PoPageModule, PoTableColumn } from '@po-ui/ng-components';
import { SharedModule } from '../../shared/shared.module';

@Component({
  selector: 'app-contract-center',
  imports: [PoPageModule, PoModule, SharedModule],
  templateUrl: './contract-center.component.html',
  styleUrl: './contract-center.component.scss'
})
export class ContractCenterComponent implements OnInit {
    public contractsJuriItems: WritableSignal<Array<any>> = signal([]);

    readonly contractsJuriColumns: PoTableColumn[] = [
      { property: 'date', label: 'Data', type: 'date' },
      { property: 'requester', label: 'Solicitante' },
      { property: 'responsibleManager', label: 'Gestor Responsável' },
      { property: 'corporateName', label: 'Razão Social' },
      { property: 'validity', label: 'Vigência' },
      { property: 'value', label: 'Valor' },
      { property: 'purchaseOrder', label: 'Pedido de compra' },
      // { property: 'actions', label: 'Ação', type: 'cellTemplate', fixed: true, sortable: false}
    ];

    constructor() {}

    ngOnInit() {
      this.getContractsJuri();
    }

    public onSearchContractJuri = (search?: string) => {
      console.warn('search', search);
    }

    private getContractsJuri() {
      const contractsJuri = [
        {
          date: '2021-01-01',
          requester: 'João da Silva',
          responsibleManager: 'Maria de Souza',
          corporateName: 'Empresa A',
          validity: '2022-01-01',
          value: 'R$ 100.000,00',
          purchaseOrder: '123456'
        },
        {
          date: '2021-01-01',
          requester: 'João da Silva',
          responsibleManager: 'Maria de Souza',
          corporateName: 'Empresa B',
          validity: '2022-01-01',
          value: 'R$ 100.000,00',
          purchaseOrder: '123456'
        }
      ];

      this.contractsJuriItems.set(contractsJuri);
    }

    readonly tableActions: Array<PoPageAction> = [
      { icon: 'po-icon-eye', action: () => {}, label: 'Visualizar' },
      { icon: 'po-icon-ok', action: () => {}, label: 'Aprovar' },
      { icon: 'po-icon-close', action: () => {}, label: 'Reprovar' },
    ]
}
