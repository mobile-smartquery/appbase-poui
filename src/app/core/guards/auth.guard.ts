import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { StorageService } from '../services/storage.service';
import { BranchesService } from '../services/branches.service';
import { catchError, of } from "rxjs";
import { first } from "rxjs/operators";
import { isEmpty } from 'lodash';
import { PoNotificationService } from '@po-ui/ng-components';

export const authGuard: CanActivateFn = (route) => {
  const storageService = inject(StorageService);
  const branchesService = inject(BranchesService);
  const poNotification = inject(PoNotificationService);
  const router = inject(Router);

  const isLoggedIn = !!storageService.getToken();

  let isBranchDefined = false;

  // return true; // Permite o acesso à rota
  return branchesService.getUserBranches()
    .pipe(
      first(),
      catchError(() => of(false))
    )
    .toPromise()
    .then((branches: any) => {
      const isBranchDefined = !isEmpty(branches);
      if (!isBranchDefined) {
        poNotification.warning('Nenhuma filial encontrada para o usuário logado.');
        router.navigate(['/login']);
        storageService.removeToken();
      }
      return isBranchDefined;
    })
    .catch(() => {
      router.navigate(['/login']);
      return false;
    });
};
