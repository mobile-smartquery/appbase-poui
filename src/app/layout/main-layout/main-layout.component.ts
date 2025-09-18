import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import {
  PoMenuItem,
  PoMenuModule,
  PoModule,
  PoPageModule,
  PoToolbarAction,
  PoToolbarModule,
} from '@po-ui/ng-components';
import { SharedModule } from '../../shared/shared.module';
import { isEmpty } from 'lodash';
import { Router, RouterOutlet } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { BranchesService } from '../../core/services/branches.service';
import { split } from 'lodash';
import { CoreService } from '../../core/services/core.service';
import { finalize, first } from 'rxjs';

@Component({
  selector: 'app-main-layout',
  imports: [
    CommonModule,
    PoToolbarModule,
    PoMenuModule,
    PoPageModule,
    PoModule,
    RouterOutlet,
    SharedModule,
    FormsModule,
  ],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.scss',
})
export class MainLayoutComponent implements OnInit {
  readonly menus: Array<PoMenuItem> = [
    {
      label: 'Dashboard',
      link: '/dashboard',
      icon: 'an an-squares-four',
      shortLabel: 'Dashboard',
    },
    {
      label: 'Nova Solicitação',
      link: '/contract-management/new-request',
      icon: 'an an-git-pull-request',
      shortLabel: 'Novo Contrato',
    },
    // {
    //   label: 'Novo Contrato',
    //   link: '/contract-management/contract-item/add',
    //   icon: 'an an-plus',
    //   shortLabel: 'Novo Contrato',
    // },
    {
      label: 'Central de Contratos',
      link: '/contract-center',
      icon: 'an an-archive',
      shortLabel: 'Central de Contratos',
    },
  ];

  actions: Array<PoToolbarAction> = [
    { label: 'IGNORE', icon: 'an an-gear', action: () => {}, visible: false },
  ];

  firstBranch: string = '';
  branchesOptions: any = [];

  constructor(
    private router: Router,
    private branchesService: BranchesService
  ) {}

  ngOnInit(): void {
    this.onLoadBranches();
  }

  private onLoadBranches() {
    // this.branchesOptions = this.branchesService.branches.map((branch: any) => (
    //   {
    //   label: branch.cgc,
    //   value: branch.code,
    // }));

    // this.firstBranch = this.branchesService.selBranch;
  }

  onChangeBranch(branch: string): void {
    this.branchesService.selBranch = branch;
    this.firstBranch = branch;
    if (!isEmpty(split(this.router.url, '?')[1])) {
      this.router.navigate([split(this.router.url, '?')[0]]);
    } else {
      this.router.navigate([this.router.url], {
        queryParams: { refresh: new Date().getTime() },
      });
    }
  }

  // Se esta na tela principal
  isMainScreen() {
    return this.router.url.split('/').length > 2;
  }
}
