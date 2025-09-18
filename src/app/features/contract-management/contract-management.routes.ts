import { Routes } from '@angular/router';
import { NewRequestComponent } from './pages/new-request/new-request.component';
import { ContractItemComponent } from './pages/contract-item/contract-item.component';

export const CONTRACT_MANAGEMENT_ROUTES: Routes = [
  {
    path: '',
    children: [
      {
        path: 'new-request',
        component: NewRequestComponent,
        title: 'Nova Solicitação',
      },
      {
        path: 'contract-item/:action',
        component: ContractItemComponent,
        title: 'Novo Contrato',
      },
      {
        path: 'contract-item/:action/:code',
        component: ContractItemComponent,
      },
      // {
      //   path: '',
      //   redirectTo: 'add',
      //   pathMatch: 'full'
      // }
    ]
  }
]
