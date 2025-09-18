import { Component, HostListener, Input, OnInit, signal, ViewChild, WritableSignal } from '@angular/core';
import { PoBreadcrumb, PoPageAction, PoTableAction, PoTableComponent } from '@po-ui/ng-components';
import { finalize, map } from 'rxjs';
import { PoPageDynamicSearchFilters } from '@po-ui/ng-templates';
import { Utils } from '../../utils/utils';
import { ActivatedRoute, Router } from '@angular/router';
import { CoreService } from '../../../core/services/core.service';

@Component({
  selector: 'app-browse',
  templateUrl: './browse.component.html',
  styleUrl: './browse.component.scss',
  standalone: false
})
export class BrowseComponent implements OnInit {
  @ViewChild('table', { static: true }) table!: PoTableComponent;

  @Input() description: string = '';
  @Input() breadcrumb!: PoBreadcrumb;
  @Input() actions: Array<PoPageAction> = [];
  @Input({ required: true }) alias: string = '';

  @Input() order: string = '';
  @Input() hideColumnsManager: boolean = false;
  @Input() customNavigateView!: string[];
  @Input() showAdvancedPagination: boolean = false;

  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    this.updateHeight(400);
  }

  public loading: WritableSignal<boolean> = signal(false);

  height: WritableSignal<number> = signal(400);

  page: number = 1;
  pageSize: number = 10;
  remainingRecords: number = 0;
  totalPages: number = 0;
  showTotalPageIndicator: string = 'Mostrando de ?-? de ?';
  private showTotalPageIndicatorDefault: string = 'Mostrando de ?-? de ?';

  public columns: Array<any> = [];
  public items: WritableSignal<Array<any>> = signal([]);
  public filters: Array<PoPageDynamicSearchFilters> = [];
  public hasNext: WritableSignal<boolean> = signal(false);
  public actionsTable: Array<PoTableAction> = [];

  constructor(
    private coreService: CoreService,
    private activatedRoute: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.updateHeight(this.height());
    if (this.alias) {
      this._initializeBrowse();
    }
  }

  private _initializeBrowse(): void {
    this.loading.set(true);

    this.actionsTable.push({
      label: '',
      action: (item: any) => {
        if (this.customNavigateView && this.customNavigateView.length > 0) {
          console.warn('navigate to custom view', this.customNavigateView, item);

          this.router.navigate(this.customNavigateView, {
            queryParams: { item: JSON.stringify(item) },
          });
        } else {
          this.router.navigate(['view'], {
            queryParams: { item: JSON.stringify(item) },
            relativeTo: this.activatedRoute
          });
        }
      },
      icon: 'an an-arrow-up-right'
    });

    // Tenta carregar do localStorage antes de buscar do serviço
    const localStorageKey = `browse_columns_${this.alias}`;
    const cachedColumns = localStorage.getItem(localStorageKey);
    if (cachedColumns) {
      try {
        const parsedColumns = JSON.parse(cachedColumns);
        this.columns = parsedColumns;
        this.filters = parsedColumns.filter((col: any) => !col.virtual);
      } catch (e) {
        // Se falhar ao fazer parse, ignora e busca do serviço
      }
    }

    this.coreService
      .getBrowseColumns(this.alias)
      .pipe(map(item => Utils.mapBrowseData(item, this.coreService)))
      .subscribe({
        next: (response: any) => {
          this.columns = response;
          this.filters = response.filter((col: any) => !col.virtual);
          // Salva no localStorage para uso futuro
          localStorage.setItem(localStorageKey, JSON.stringify(response));
          this._getBrowseItems();
        },
        error: (error: any) => {
          this.loading.set(false);
        }
      });
  }

  private _getBrowseItems(filter: string = '', advanced: string = ''): void {
    this.loading.set(true);

    const params = this._buildParams(filter, advanced);

    this.coreService
      .getBrowseItems(this.alias, params)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response: any) => this._handleBrowseItemsResponse(response)
      });
  }

  protected onLoadFields(): any {
    return {
      filters: this.filters,
      keepFilters: true
    };
  }

  onOpenColumnManager() {
    this.table.onOpenColumnManager();
  }

  onSearch(value: string): void {
    this._resetPagination();
    this._getBrowseItems(value);
  }

  onAdvancedSearch(filter: any): void {
    // verifica se o filtro que é um objeto possui chaves
    if (Object.keys(filter).length > 0) {
      const filterString = Object.entries(filter as Record<string, any>)
        .map(([key, value]) => {
          if (typeof value === 'boolean') {
            return `(${key.toLowerCase()} eq ${value ? 'true' : 'false'})`;
          }
          if (typeof value === 'string') {
            const lowerKey = key.toLowerCase();
            const lowerValue = value.toLowerCase();

            // %valor%
            if (lowerValue.startsWith('%') && lowerValue.endsWith('%') && lowerValue.length > 2) {
              const innerValue = lowerValue.slice(1, -1);
              return `contains(tolower(${lowerKey}), '${innerValue}')`;
            }
            // %valor
            if (lowerValue.startsWith('%')) {
              const innerValue = lowerValue.slice(1);
              return `endswith(tolower(${lowerKey}), '${innerValue}')`;
            }
            // valor%
            if (lowerValue.endsWith('%')) {
              const innerValue = lowerValue.slice(0, -1);
              return `startswith(tolower(${lowerKey}), '${innerValue}')`;
            }
            // valor exato
            return `tolower(${lowerKey}) eq '${lowerValue}'`;
          }
          return '';
        })
        .filter(Boolean)
        .join(' and ');

      this._resetPagination();
      this._getBrowseItems('', filterString);
    }
  }

  protected nextPage(): void {
    this.loading.set(true);
    this._incrementPage();
    const params = this._buildParams('');

    this.coreService
      .getBrowseItems(this.alias, params)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response: any) => {
          this._appendBrowseItemsResponse(response);
        }
      });
  }

  protected previousPage(): void {
    if (this.page > 1) {
      this.loading.set(true);
      this.page -= 1;
      const params = this._buildParams('');

      this.coreService
        .getBrowseItems(this.alias, params)
        .pipe(finalize(() => this.loading.set(false)))
        .subscribe({
          next: (response: any) => {
            this._appendBrowseItemsResponse(response);
          }
        });
    }
  }

  private updateHeight(height: number): void {
    // Calcula a altura baseada no tamanho da janela, garantindo no mínimo 400
    const windowHeight = Math.max(window.innerHeight - 390, 400);

    // Ajuste dinâmico baseado na altura informada
    let adjustHeight = 0;
    if (height <= 640) {
      adjustHeight = 200;
    } else if (height < 720) {
      adjustHeight = 300;
    } else if (height < 1040) {
      adjustHeight = 350;
    } else if (height < 1152) {
      adjustHeight = 450;
    } else {
      adjustHeight = 650;
    }

    // Usa o maior valor entre o calculado pela janela, o parâmetro e o ajuste
    const newHeight = Math.max(height, adjustHeight, windowHeight);
    this.height.set(newHeight);

    console.warn(`Ajustando altura do componente Browse para: ${newHeight}px`);

  }

  changePageSize() {
    this._resetPagination();
    this.loading.set(true);
    const params = this._buildParams('');

    this.coreService
      .getBrowseItems(this.alias, params)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response: any) => {
          this._handleBrowseItemsResponse(response);
        }
      });
  }

  changePage() {
    this.loading.set(true);
    const params = this._buildParams('');

    this.coreService
      .getBrowseItems(this.alias, params)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe({
        next: (response: any) => {
          this._handleBrowseItemsResponse(response);
        }
      });
  }

  private _resetPagination(): void {
    this.page = 1;
  }

  private _incrementPage(): void {
    this.page += 1;
  }

  private _buildParams(filter: string, advanced: string = ''): any {
    return {
      filter,
      page: this.page,
      pageSize: this.pageSize,
      $advanced: advanced,
      $order: this.order
      // idx: JSON.stringify(this.columns.map((col: any) => col.property))
    };
  }

  private _handleBrowseItemsResponse(response: any): void {
    const transformedItems = this._transformItems(response?.items || []);

    // pega o remainingRecords
    this.remainingRecords = response?.remainingRecords || 0;
    this.items.set(transformedItems);
    this.hasNext.set(response.hasNext);

    this._setPaginationDetails(transformedItems);

    // Ajuste: remainingRecords representa registros restantes além da página atual
  }

  private _setPaginationDetails(transformedItems: any) {
    const page = this.page;
    const pageSize = this.pageSize;
    const currentCount = transformedItems.length;
    const total = (page - 1) * pageSize + currentCount + this.remainingRecords;

    const start = (page - 1) * pageSize + 1;
    const end = start + currentCount - 1;
    this.totalPages = Math.ceil(total / pageSize);
    this.showTotalPageIndicator = `Mostrando ${start}-${end} de ${total}`
  }

  private _appendBrowseItemsResponse(lookupRes: any): void {
    const transformedItems = this._transformItems(lookupRes.items);
    this.items.set(transformedItems);
    this.hasNext.set(lookupRes.hasNext);
    this._setPaginationDetails(this.items());
  }

  private _transformItems(items: Array<any>): Array<any> {
    return items.map((item: any) => {
      const newItem: any = {};
      Object.keys(item).forEach(key => {
        newItem[key.toUpperCase()] = item[key];
      });
      return newItem;
    });
  }

  /**
   * Atualiza os dados da página reiniciando a paginação e recarregando as informações.
   *
   * @remarks
   * Este método chama `_resetPagination` para reiniciar a paginação e, em seguida,
   * executa `onLoadData` para carregar os dados novamente.
   */
  refresh(): void {
    if (this.columns.length === 0) {
      this.loading.set(true);
      this._initializeBrowse();
      return;
    }

    this._resetPagination();
    this._getBrowseItems();
  }

  showmore(): void {
    this._incrementPage();
    this._getBrowseItems();
  }
}
