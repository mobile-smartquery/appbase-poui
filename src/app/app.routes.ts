import { Routes } from '@angular/router';
import { CONTRACT_MANAGEMENT_ROUTES } from './features/contract-management/contract-management.routes';
import { MainLayoutComponent } from './layout/main-layout/main-layout.component';
import { authGuard } from './core/guards/auth.guard';
import { LoginComponent } from './features/login/login.component';

export const APP_ROUTES: Routes = [
     {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [],
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then(
            (m) => m.DashboardComponent
          ),
      },
      {
        path: 'contract-center',
        loadComponent: () =>
          import('./features/contract-center/contract-center.component').then(
            (m) => m.ContractCenterComponent
          ),
      },
      {
        path: 'contract-management',
        children: CONTRACT_MANAGEMENT_ROUTES,
      },
      {
        path: '',
        redirectTo: 'dashboard',
        pathMatch: 'full',
      },
    ],
  },
  { path: '**', redirectTo: '', pathMatch: 'full' },
];
