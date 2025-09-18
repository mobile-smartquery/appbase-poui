import {
  Component,
  OnInit,
  signal,
  ViewChild,
  WritableSignal,
} from '@angular/core';
import { SharedModule } from '../../../../shared/shared.module';
import {
  PoBreadcrumb,
  PoDialogService,
  PoDynamicFormComponent,
  PoDynamicFormField,
  PoModalAction,
  PoModalComponent,
  PoNotificationService,
  PoPageAction,
  PoTableColumn,
} from '@po-ui/ng-components';
import {
  PoPageDynamicEditActions,
  PoPageDynamicEditComponent,
  PoPageDynamicEditLiterals,
  PoPageDynamicEditModule,
} from '@po-ui/ng-templates';
// import { DictionaryService } from '../../../../core/services/dictionary.service';
import { Utils } from '../../../../shared/utils/utils';
import { finalize, first, lastValueFrom, Observable } from 'rxjs';
import { ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup } from '@angular/forms';
// import { ContractService } from '../../../../core/services/contract.service';
import { IStruct } from '../../../../shared/interfaces/IDictionary';
import { CoreService } from '../../../../core/services/core.service';
import { DynamicFormComponent } from '../../../../shared/components/dynamic-form/dynamic-form.component';
import { GridFormComponent } from '../../../../shared/components/grid-form/grid-form.component';
import { filter } from 'lodash';

@Component({
  selector: 'app-contract-item',
  imports: [SharedModule, PoPageDynamicEditModule],
  templateUrl: './contract-item.component.html',
  styleUrl: './contract-item.component.scss',
})
export class ContractItemComponent implements OnInit {
  @ViewChild('formPX2', { static: true }) formPX2!: DynamicFormComponent;
  @ViewChild('gridPB9', { static: true }) gridPB9!: GridFormComponent;
  @ViewChild('gridPX7', { static: true }) gridPX7!: GridFormComponent;
  @ViewChild('gridPX3', { static: true }) gridPX3!: GridFormComponent;
  @ViewChild('gridPX4', { static: true }) gridPX4!: GridFormComponent;
  @ViewChild('gridPX6', { static: true }) gridPX6!: GridFormComponent;

  breadcrumb: PoBreadcrumb = {
    items: [
      { label: 'Tela Inicial', link: '/' },
      { label: 'Central de Contratos', link: '/contract-center' },
    ],
  };

  actions: PoPageAction[] = [];

  modeTitle: string = '';

  loading: WritableSignal<boolean> = signal(false);
  actionsViewDef: Array<any> = [];
  formMode: 'edit' | 'view' | 'new' = 'view';

  posiItem: any = {};

  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private coreService: CoreService,
    private poNotification: PoNotificationService,
    private fb: FormBuilder,
    private poDialog: PoDialogService
  ) {}

  ngOnInit(): void {
    this._initializeForms();
  }

  private async _initializeStructure() {
    await this._loadStruct('PB9', this.gridPB9, 'PB9_CONTRA');
    await this._loadStruct('PX7', this.gridPX7, 'PX7_CONTRA');
    await this._loadStruct('PX3', this.gridPX3, 'PX3_CONTRA');
    await this._loadStruct('PX4', this.gridPX4, 'PX4_CONTRA');
    await this._loadStruct('PX6', this.gridPX6, 'PX6_CONTRA');
    await this._loadGridData();
  }

  private async _loadStruct(
    alias: string,
    gridComponent: GridFormComponent,
    excludeProperty: string
  ) {
    try {
      this.loading.set(true);
      const response: any = await lastValueFrom(
        this.coreService.getStructAlias(alias)
      );
      const formViewDef = Utils.mapViewDef(response, this.coreService);

      formViewDef.fields = formViewDef.fields.filter(
        (field: any) => field.property !== excludeProperty
      );

      const formStruct = {
        fields: formViewDef.fields || [],
        sheets: formViewDef.sheets || [],
        columns: formViewDef.columns || [],
      };

      gridComponent.setStruct(formStruct);
    } catch (error) {
      console.error(`Erro ao inicializar a estrutura (${alias}):`, error);
      this.poNotification.error('Erro ao carregar a estrutura do formulário.');
    } finally {
      this.loading.set(false);
    }
  }

  private async _loadGridData() {
    this.loading.set(true);

    const paramsPX3 = {
      page: 1,
      pageSize: 10,
      filter: `PX3_CONTRA eq '${this.posiItem.PX2_CONTRA || ''}'`,
    };

    const paramsPX4 = {
      page: 1,
      pageSize: 10,
      filter: `PX4_CONTRA eq '${this.posiItem.PX2_CONTRA || ''}'`,
    };

    const paramsPB9 = {
      page: 1,
      pageSize: 10,
      filter: `PB9_CONTRA eq '${this.posiItem.PX2_CONTRA || ''}'`,
    };

    const paramsPX7 = {
      page: 1,
      pageSize: 10,
      filter: `PX7_CONTRA eq '${this.posiItem.PX2_CONTRA || ''}'`,
    };

    const paramsPX6 = {
      page: 1,
      pageSize: 10,
      filter: `PX6_CONTRA eq '${this.posiItem.PX2_CONTRA || ''}'`,
    };

    try {
      await Promise.all([
        this.coreService.getContractItems(paramsPX3).toPromise().then((response: any) => {
          const items = response?.items || [];
          if (items.length > 0) {
            const transformedItems = JSON.stringify(items).toLocaleUpperCase();
            const itemsObj = JSON.parse(transformedItems);
            console.warn('=================> ITENS DO GRID PX3:', itemsObj);
            this.gridPX3.setItems(itemsObj);
          }
        }),
        this.coreService.getContractCompanies(paramsPX4).toPromise().then((response: any) => {
          const items = response?.items || [];
          if (items.length > 0) {
            const transformedItems = JSON.stringify(items).toLocaleUpperCase();
            const itemsObj = JSON.parse(transformedItems);
            console.warn('=================> ITENS DO GRID PX4:', itemsObj);
            this.gridPX4.setItems(itemsObj);
          }
        }),
        this.coreService.getContractAccounting(paramsPB9).toPromise().then((response: any) => {
          const items = response?.items || [];
          if (items.length > 0) {
            const transformedItems = JSON.stringify(items).toLocaleUpperCase();
            const itemsObj = JSON.parse(transformedItems);
            console.warn('=================> ITENS DO GRID PB9:', itemsObj);
            this.gridPB9.setItems(itemsObj);
          }
        }),
        this.coreService.getContractSuppliers(paramsPX7).toPromise().then((response: any) => {
          const items = response?.items || [];
          if (items.length > 0) {
            const transformedItems = JSON.stringify(items).toLocaleUpperCase();
            const itemsObj = JSON.parse(transformedItems);
            console.warn('=================> ITENS DO GRID PX7:', itemsObj);
            this.gridPX7.setItems(itemsObj);
          }
        }),
        this.coreService.getContractUsers(paramsPX6).toPromise().then((response: any) => {
          const items = response?.items || [];
          if (items.length > 0) {
            const transformedItems = JSON.stringify(items).toLocaleUpperCase();
            const itemsObj = JSON.parse(transformedItems);
            console.warn('=================> ITENS DO GRID PX6:', itemsObj);
            this.gridPX6.setItems(itemsObj);
          }
        }),
      ]);
    } catch (error) {
      console.error('Erro ao carregar os dados do grid Z03:', error);
      this.poNotification.error('Erro ao carregar os dados do grid.');
    } finally {
      this.loading.set(false);
    }
  }

  private _initializeForms(): void {
    this._setPosiItem();
    this._setModeTitle();
    this._addCurrentBreadcrumbItem();
    this._getActions();
    this._initializeStructure();
    this.formPX2.setFormDataCallback(this._getFormData);
  }

  private _setPosiItem() {
    const item = this.activatedRoute.snapshot.queryParamMap.get('item');
    this.posiItem = item ? JSON.parse(item) : {};
  }

  private _getFormData = (): Observable<any> => {
    const item = { item: this.posiItem };
    const itemJson = JSON.stringify(item);
    return this.coreService.getDictionaryData('PX2', itemJson).pipe(first());
  };

  private _setModeTitle(): void {
    const action = this.activatedRoute.snapshot.paramMap?.get('action') || '';
    this.modeTitle = this._getModeTitle(action);
    this.formMode = action as 'edit' | 'view' | 'new';
  }

  private _clearComponents(): void {
    this.breadcrumb.items.pop();
    this.actions = [];
    this.modeTitle = '';
    this.formMode = 'view';
    this.posiItem = {};
  }

  private _addCurrentBreadcrumbItem(): void {
    this.breadcrumb?.items.push({
      label: this.modeTitle,
      link: this.router.url,
    });
  }
  private _getActions(): void {
    if (this.formMode === 'edit' || this.formMode === 'new') {
      this.actions = [
        {
          label: 'Salvar',
          action: () => this._saveForm(),
        },
        {
          label: 'Salvar e continuar',
          action: () => this._saveForm(false),
        },
        {
          label: 'Voltar',
          action: this._goBack.bind(this),
        },
      ];
    } else if (this.formMode === 'view') {
      this.actions = [
        {
          label: 'Editar',
          action: () => {
            this.formMode = 'edit';
            this.router
              .navigate(['..', 'edit'], {
                relativeTo: this.activatedRoute,
                queryParams: {
                  item: this.posiItem ? JSON.stringify(this.posiItem) : '',
                },
                queryParamsHandling: 'merge',
              })
              .then(() => {
                this._clearComponents();
                this._initializeForms();
              });
          },
        },
        {
          label: 'Excluir',
          action: () => {
            this.poDialog.confirm({
              title: 'Confirmação',
              message:
                'Tem certeza de que deseja excluir esse registro? Você não poderá desfazer essa ação.',
              confirm: () => {
                this.loading.set(true);
                const id = this.posiItem.Z00_COD;
                // this.coreService
                //   .deleteMarketplacesAccounts(id)
                //   .pipe(
                //     first(),
                //     finalize(() => this.loading.set(false))
                //   )
                //   .subscribe({
                //     next: () => {
                //       this.poNotification.success('Item excluído com sucesso.');
                //       this.router.navigate(['../'], { relativeTo: this.activatedRoute });
                //     },
                //     error: (error: any) => {
                //       console.error('Erro ao excluir o item:', error);
                //       this.poNotification.error('Erro ao excluir o item.');
                //     }
                //   });
              },
            });
          },
        },
        {
          label: 'Voltar',
          action: this._goBack.bind(this),
        },
      ];
    }
  }

  private _getModeTitle(action: string): string {
    switch (action) {
      case 'edit':
        return 'Editar';
      case 'view':
        return 'Visualizar';
      case 'delete':
        return 'Excluir';
      default:
        return 'Incluir';
    }
  }

  _goBack(): void {
    this.router.navigate(['../'], { relativeTo: this.activatedRoute });
  }

  private _getPayload(): any {
    // Utilitário para transformar um array de objetos em array de arrays de campos
    const mapItemsToFields = (items: any[]): any[] =>
      items.map((item) =>
        Object.entries(item).map(([key, value]) => ({
          field: key.toLowerCase(),
          value,
        }))
      );

    // Utilitário para montar a seção (array de objetos com propriedade 'item')
    const buildSection = (items: any[]): any[] => [
      { item: mapItemsToFields(items) },
    ];

    // Dados do formulário principal (PX2)
    const dataPX2 = this.formPX2.getFormData()['FORMPX2'] || {};
    const PX2 = Object.entries(dataPX2).map(([key, value]) => ({
      field: key.toLowerCase(),
      value,
    }));

    // Grids
    const PB9 = buildSection(this.gridPB9.getItems());
    const PX7 = buildSection(this.gridPX7.getItems());
    const PX3 = buildSection(this.gridPX3.getItems());
    const PX4 = buildSection(this.gridPX4.getItems());
    const PX6 = buildSection(this.gridPX6.getItems());

    return {
      operation: 3,
      key: '',
      PX2,
      PB9,
      PX7,
      PX3,
      PX4,
      PX6,
    };
  }

  private _saveForm(navigateToHome: boolean = true): void {
    const payload = this._getPayload();

    console.warn('=================> DADOS QUE SERÂO ENVIADOS:', payload);
    console.warn('=================> KEY:', this.posiItem.PX2_CONTRA);

    const dataPB9 = this.gridPB9.getItems();
    const dataPX7 = this.gridPX7.getItems();
    const dataPX3 = this.gridPX3.getItems();
    const dataPX4 = this.gridPX4.getItems();
    const dataPX6 = this.gridPX6.getItems();

    if (this.formPX2.isFormValid()) {
      if (this.formMode === 'new') {
        this.loading.set(true);

        // Verifica se possui pelo menos um item no grid PX7, PX3, PX4, PX6
        // if (
        //   dataPX7.length === 0 ||
        //   dataPX3.length === 0 ||
        //   dataPX4.length === 0 ||
        //   dataPX6.length === 0
        // ) {
        //   this.poNotification.warning(
        //     'É necessário preencher pelo menos um item em cada grid (Fornecedores, Itens, Empresas Pagadoras e Usuários).'
        //   );
        //   this.loading.set(false);
        //   return;
        // }

        this.coreService
          .postContract(payload)
          .pipe(
            first(),
            finalize(() => this.loading.set(false))
          )
          .subscribe({
            next: (response: any) => {
              this.poNotification.success('Dados salvos com sucesso.');
              if (navigateToHome) {
                this.router.navigate(['../'], {
                  relativeTo: this.activatedRoute,
                });
              }
            },
            error: (error: any) => {
              console.error('Erro ao salvar os dados:', error);
            },
          });
      } else if (this.formMode === 'edit') {
        this.loading.set(true);
        const key = this.posiItem.PX2_CONTRA;
        payload.key = key;
        payload.operation = 4;

        this.coreService
          .putContract(payload)
          .pipe(
            first(),
            finalize(() => this.loading.set(false))
          )
          .subscribe({
            next: (response: any) => {
              this.poNotification.success('Dados atualizados com sucesso.');
              if (navigateToHome) {
                this.router.navigate(['../'], {
                  relativeTo: this.activatedRoute,
                });
              }
            },
            error: (error: any) => {
              console.error('Erro ao atualizar os dados:', error);
            },
          });
      }
    } else {
      this.poNotification.warning('Preencha todos os campos obrigatórios.');
    }
  }
}
