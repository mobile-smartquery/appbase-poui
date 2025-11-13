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

import { Router, RouterOutlet } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { BranchesService } from '../../core/services/branches.service';
import { isEmpty, split } from 'lodash';
import { MenuService } from '../../core/services/menu.service';

@Component({
  selector: 'app-main-layout',
  imports: [
    CommonModule,
    PoToolbarModule,
    PoMenuModule,
    PoPageModule,
    PoModule,
    RouterOutlet,
    FormsModule,
  ],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.scss',
})
export class MainLayoutComponent implements OnInit {
  menus: Array<PoMenuItem> = [];

  actions: Array<PoToolbarAction> = [
    { label: 'IGNORE', icon: 'an an-gear', action: () => {}, visible: false },
  ];

  firstBranch: string = '';
  branchesOptions: any = [];

  constructor(
    private router: Router,
    private branchesService: BranchesService,
    private menuService: MenuService
  ) {}

  ngOnInit(): void {
    this.loadMenu();
    this.onLoadBranches();
  }

  private loadMenu(): void {
    this.menuService.getMenu().subscribe({
      next: (data) => {
        console.log('MENU CARREGADO:', data);

        //  GARANTE que o PO-UI receba exatamente o formato PoMenuItem
        this.menus = data.map((item: any) => ({
          label: item.label,
          link: item.link,
          icon: item.icon,
          shortLabel: item.shortLabel,
        }));
      },
      error: (err) => {
        console.error('Erro ao carregar menu:', err);
      },
    });
  }

  private onLoadBranches() {}

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

  isMainScreen() {
    return this.router.url.split('/').length > 2;
  }
}
