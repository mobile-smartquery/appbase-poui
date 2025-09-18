import { CommonModule } from '@angular/common';
import {
  Component,
  computed,
  OnInit,
  signal,
  ViewChild,
  WritableSignal,
} from '@angular/core';
import {
  PoModule,
  PoNotificationService,
  PoPageAction,
  PoPageModule,
  PoTableAction,
  PoTableColumn,
} from '@po-ui/ng-components';
import { SharedModule } from '../../shared/shared.module';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import { Utils } from '../../shared/utils/utils';
import { BrowseComponent } from '../../shared/components/browse/browse.component';

@Component({
  selector: 'app-dashboard',
  imports: [PoPageModule, PoModule, SharedModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  @ViewChild('browse', { static: true }) browse!: BrowseComponent;

  loading: WritableSignal<boolean> = signal(false);

  public readonly actions: Array<PoPageAction> = [
    {
      label: 'Atualizar',
      action: () => this.browse.refresh(),
      icon: 'an an-arrows-clockwise',
      disabled: false
    }
  ];

  constructor(
    private router: Router,
  ) {}

  ngOnInit(): void {
  }


  onSearchContract = (search?: any) => {
    this.browse.onSearch(search);
  };

  openColumnManager() {
    this.browse.onOpenColumnManager()
  }
  navigateToAddContract() {
    this.router.navigate(['contract-management/contract-item', 'new']);
  }
}
