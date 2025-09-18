import { Injectable } from '@angular/core';
import { find, forEach, get } from 'lodash';
import { tap } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { HttpService } from './http.service';

@Injectable({
  providedIn: 'root',
})
export class BranchesService {
  selBranch: string = '';
  branches: any = {};

  constructor(private http: HttpService) {}

  getUserBranches(): Observable<any> {
    return this.http
      .get('f3/branches', { params: { pagesize: '9999' } })
      .pipe(
        tap((response: any) => {
          const branches = response.items || [];
          if (branches.length > 0) {
            this.selBranch = branches[0].code;
            this.branches = branches || [];
          }
        })
      );
  }

  getNameBranchLogged(): string {
    return get(
      find(this.branches, (branch: any) => {
        return this.selBranch === get(branch, 'Code', '');
      }),
      'Description',
      ''
    );
  }
}
