import { Injectable } from '@angular/core';
import { catchError, Observable, of, tap, map } from 'rxjs';
import { PoNotificationService } from '@po-ui/ng-components';
import { HttpService } from './http.service';

@Injectable({
  providedIn: 'root',
})
export class CoreService {
  constructor(
    private readonly http: HttpService,
    private readonly poNotification: PoNotificationService
  ) {}

  getBrowseColumns(alias: string): Observable<any[]> {
    // Mock locally when running on localhost to avoid 404 from remote backend
    try {
      if (
        typeof window !== 'undefined' &&
        (window.location.hostname === 'localhost' ||
          window.location.hostname.startsWith('127.'))
      ) {
        const mockColumns: any = {
          PX2: [
            { property: 'code', label: 'C�digo', type: 'C', virtual: false },
            {
              property: 'description',
              label: 'Descri��o',
              type: 'C',
              virtual: false,
            },
            { property: 'active', label: 'Ativo', type: 'L', virtual: false },
          ],
        };

        if (mockColumns[alias]) {
          return of(mockColumns[alias]);
        }
      }
    } catch (e) {
      // ignore any window access errors in non-browser environments
    }

    return this.http.get(`browse/columns/${alias}`).pipe(
      catchError((error) => {
        console.error('Erro ao buscar colunas do browse:', error);
        this.poNotification.error('Erro ao buscar colunas do browse.');
        return of([]); // fallback para o componente n�o quebrar
      })
    );
  }

  getBrowseItems(alias: string, params: any): Observable<any[]> {
    return this.http.get(`browse/items/${alias}`, { ...params }).pipe(
      catchError((error) => {
        console.error('Erro ao buscar itens do browse:', error);
        this.poNotification.error('Erro ao buscar itens do browse.');
        return of([]); // fallback para o componente não quebrar
      })
    );
  }

  getStructAlias(alias: string): Observable<any> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of({ struct: this.getMockStruct(alias), folders: [], agrups: [] });
    }

    return this.http.get(`dictionary/struct/${alias}`).pipe(
      // Ensure shape for consumers
      map((resp: any) => {
        if (Array.isArray(resp)) {
          return { struct: resp, folders: [], agrups: [] };
        }
        return {
          struct: resp?.struct ?? [],
          folders: resp?.folders ?? [],
          agrups: resp?.agrups ?? [],
        };
      }),
      catchError((error) => {
        console.error('Erro ao buscar estrutura:', error);
        this.poNotification.warning(
          'Estrutura não disponível. Usando fallback.'
        );
        return of({
          struct: this.getMockStruct(alias),
          folders: [],
          agrups: [],
        }); // fallback to mock
      })
    );
  }

  getDictionaryData(alias: string, item: string): Observable<any> {
    return this.http
      .get(`dictionary/data/${alias}/${encodeURIComponent(item)}`)
      .pipe(
        catchError((error) => {
          console.error('Erro ao buscar dados do dicionário:', error);
          this.poNotification.error('Erro ao buscar dados do dicionário.');
          throw error; // fallback para o componente não quebrar
        })
      );
  }

  getDictionaryInitializer(calias: string): Observable<any> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of(this.getMockInitializer(calias));
    }

    return this.http.get(`dictionary/initializer/${calias}`).pipe(
      catchError((error) => {
        console.error(
          'Erro ao buscar dados do initializer do dicionário:',
          error
        );
        this.poNotification.warning(
          'Initializer não disponível. Usando fallback.'
        );
        return of(this.getMockInitializer(calias)); // fallback to mock
      })
    );
  }

  getLookup(ctabela: string, params: any): Observable<any> {
    return this.http.get(`lookup/${ctabela}`, { ...params }).pipe(
      catchError((error) => {
        console.error('Erro ao buscar dados do lookup:', error);
        this.poNotification.error('Erro ao buscar dados do lookup.');
        return of([]); // fallback para o componente não quebrar
      })
    );
  }

  getLookupById(
    ctabela: string,
    id: string,
    idColumn: string
  ): Observable<any> {
    const encodedId = encodeURIComponent(id); // Encode the ID to handle special characters like '/'
    return this.http
      .get(`lookup/${ctabela}/${encodedId}`, {
        idx: JSON.stringify([idColumn]),
      })
      .pipe(
        catchError((error) => {
          console.error('Erro ao buscar dados do lookup por ID:', error);
          this.poNotification.error('Erro ao buscar dados do lookup por ID.');
          return of([]); // fallback para o componente não quebrar
        })
      );
  }

  executeTrigger(campo: string, body: any): Observable<any> {
    return this.http.post(`dictionary/trigger/${campo}`, body).pipe(
      catchError((error) => {
        console.error('Erro ao executar o trigger:', error);
        this.poNotification.error('Erro ao executar o trigger.');
        return of(null); // fallback para o componente não quebrar
      })
    );
  }

  postContract(body: any): Observable<any> {
    // Use local mock in localhost
    if (this.isLocalhost()) {
      // Simulate success response with mock data
      return of({
        id: 'CT' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'success',
        message: 'Contrato criado com sucesso',
        data: body,
      });
    }

    return this.http.post('contract', body).pipe(
      catchError((error) => {
        console.error('Erro ao criar contrato:', error);
        this.poNotification.error('Erro ao criar contrato.');
        throw error;
      })
    );
  }

  putContract(body: any): Observable<any> {
    // Use local mock in localhost
    if (this.isLocalhost()) {
      // Simulate success response with mock data
      return of({
        id:
          body.id ||
          'CT' + Math.random().toString(36).substr(2, 9).toUpperCase(),
        status: 'success',
        message: 'Contrato atualizado com sucesso',
        data: body,
      });
    }

    return this.http.put(`contract`, body).pipe(
      catchError((error) => {
        console.error('Erro ao atualizar contrato:', error);
        this.poNotification.error('Erro ao atualizar contrato.');
        throw error;
      })
    );
  }

  getContractItems(params?: any): Observable<any[]> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of(this.getMockItems());
    }

    return this.http.get('items', params ? { ...params } : undefined).pipe(
      catchError((error) => {
        console.error('Erro ao buscar itens do contrato:', error);
        this.poNotification.warning('Itens do contrato não disponíveis.');
        return of(this.getMockItems()); // fallback to mock
      })
    );
  }

  getContractCompanies(params?: any): Observable<any[]> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of(this.getMockCompanies());
    }

    return this.http.get('companies', params ? { ...params } : undefined).pipe(
      catchError((error) => {
        console.error('Erro ao buscar empresas do contrato:', error);
        this.poNotification.warning('Empresas do contrato não disponíveis.');
        return of(this.getMockCompanies()); // fallback to mock
      })
    );
  }

  getContractAccounting(params?: any): Observable<any[]> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of(this.getMockAccounting());
    }

    return this.http.get('accounting', params ? { ...params } : undefined).pipe(
      catchError((error) => {
        console.error('Erro ao buscar dados contábeis do contrato:', error);
        this.poNotification.warning('Dados contábeis não disponíveis.');
        return of(this.getMockAccounting()); // fallback to mock
      })
    );
  }

  getContractUsers(params?: any): Observable<any[]> {
    return this.http.get('users', params ? { ...params } : undefined).pipe(
      catchError((error) => {
        console.error('Erro ao buscar usuários do contrato:', error);
        this.poNotification.error('Erro ao buscar usuários do contrato.');
        throw error;
      })
    );
  }

  getContractSuppliers(params?: any): Observable<any[]> {
    // Use local mocks in localhost
    if (this.isLocalhost()) {
      return of(this.getMockSuppliers());
    }

    return this.http.get('suppliers', params ? { ...params } : undefined).pipe(
      catchError((error) => {
        console.error('Erro ao buscar fornecedores do contrato:', error);
        this.poNotification.warning('Fornecedores não disponíveis.');
        return of(this.getMockSuppliers()); // fallback to mock
      })
    );
  }

  // Helper methods for mocking
  private isLocalhost(): boolean {
    if (typeof window === 'undefined') return false;
    const hostname = window.location.hostname;
    return hostname === 'localhost' || hostname.startsWith('127.');
  }

  private getMockStruct(alias: string): any[] {
    const mockStructures: any = {
      PX2: [
        {
          field: 'PX2_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PX2_DESCRI',
          label: 'Descrição',
          type: 'C',
          size: 60,
          required: true,
        },
        {
          field: 'PX2_DTINIC',
          label: 'Data Início',
          type: 'D',
          size: 8,
          required: true,
        },
        {
          field: 'PX2_DTFIM',
          label: 'Data Fim',
          type: 'D',
          size: 8,
          required: true,
        },
        {
          field: 'PX2_VALOR',
          label: 'Valor',
          type: 'N',
          size: 15,
          decimal: 2,
          required: true,
        },
        {
          field: 'PX2_STATUS',
          label: 'Status',
          type: 'C',
          size: 1,
          required: false,
        },
      ],
      PB9: [
        {
          field: 'PB9_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PB9_ITEM',
          label: 'Item',
          type: 'C',
          size: 4,
          required: true,
        },
        {
          field: 'PB9_CONTA',
          label: 'Conta',
          type: 'C',
          size: 20,
          required: true,
        },
        {
          field: 'PB9_CC',
          label: 'C. Custo',
          type: 'C',
          size: 9,
          required: false,
        },
        {
          field: 'PB9_VALOR',
          label: 'Valor',
          type: 'N',
          size: 15,
          decimal: 2,
          required: true,
        },
      ],
      PX7: [
        {
          field: 'PX7_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PX7_ITEM',
          label: 'Item',
          type: 'C',
          size: 4,
          required: true,
        },
        {
          field: 'PX7_FORNEC',
          label: 'Fornecedor',
          type: 'C',
          size: 6,
          required: true,
        },
        {
          field: 'PX7_LOJA',
          label: 'Loja',
          type: 'C',
          size: 2,
          required: true,
        },
        {
          field: 'PX7_NOME',
          label: 'Nome',
          type: 'C',
          size: 40,
          required: false,
        },
      ],
      PX3: [
        {
          field: 'PX3_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PX3_ITEM',
          label: 'Item',
          type: 'C',
          size: 4,
          required: true,
        },
        {
          field: 'PX3_PRODUT',
          label: 'Produto',
          type: 'C',
          size: 15,
          required: true,
        },
        {
          field: 'PX3_DESCRI',
          label: 'Descrição',
          type: 'C',
          size: 60,
          required: true,
        },
        {
          field: 'PX3_QUANT',
          label: 'Quantidade',
          type: 'N',
          size: 12,
          decimal: 2,
          required: true,
        },
        {
          field: 'PX3_PRECO',
          label: 'Preço Unit.',
          type: 'N',
          size: 15,
          decimal: 2,
          required: true,
        },
        {
          field: 'PX3_TOTAL',
          label: 'Total',
          type: 'N',
          size: 15,
          decimal: 2,
          required: false,
        },
      ],
      PX4: [
        {
          field: 'PX4_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PX4_ITEM',
          label: 'Item',
          type: 'C',
          size: 4,
          required: true,
        },
        {
          field: 'PX4_EMPRES',
          label: 'Empresa',
          type: 'C',
          size: 2,
          required: true,
        },
        {
          field: 'PX4_FILIAL',
          label: 'Filial',
          type: 'C',
          size: 2,
          required: true,
        },
        {
          field: 'PX4_NOME',
          label: 'Nome',
          type: 'C',
          size: 40,
          required: false,
        },
      ],
      PX6: [
        {
          field: 'PX6_CONTRA',
          label: 'Contrato',
          type: 'C',
          size: 10,
          required: true,
        },
        {
          field: 'PX6_ITEM',
          label: 'Item',
          type: 'C',
          size: 4,
          required: true,
        },
        {
          field: 'PX6_USER',
          label: 'Usuário',
          type: 'C',
          size: 15,
          required: true,
        },
        {
          field: 'PX6_NOME',
          label: 'Nome',
          type: 'C',
          size: 40,
          required: true,
        },
        {
          field: 'PX6_PERFIL',
          label: 'Perfil',
          type: 'C',
          size: 20,
          required: false,
        },
      ],
    };

    const base = mockStructures[alias] || [];
    // Normalize to include properties expected by Utils
    return base.map((col: any) => ({
      ...col,
      title: col.label,
      decimals: col.decimal ?? 0,
      options: [],
      enabled: true,
      editable: true,
      order: 0,
    }));
  }

  private getMockItems(): any[] {
    return [
      {
        PX3_CONTRA: 'CT0001',
        PX3_ITEM: '0001',
        PX3_PRODUT: 'PROD001',
        PX3_DESCRI: 'Produto Teste 1',
        PX3_QUANT: 100,
        PX3_PRECO: 50.0,
        PX3_TOTAL: 5000.0,
      },
      {
        PX3_CONTRA: 'CT0001',
        PX3_ITEM: '0002',
        PX3_PRODUT: 'PROD002',
        PX3_DESCRI: 'Produto Teste 2',
        PX3_QUANT: 50,
        PX3_PRECO: 75.0,
        PX3_TOTAL: 3750.0,
      },
      {
        PX3_CONTRA: 'CT0001',
        PX3_ITEM: '0003',
        PX3_PRODUT: 'PROD003',
        PX3_DESCRI: 'Produto Teste 3',
        PX3_QUANT: 200,
        PX3_PRECO: 25.0,
        PX3_TOTAL: 5000.0,
      },
    ];
  }

  private getMockCompanies(): any[] {
    return [
      {
        PX4_CONTRA: 'CT0001',
        PX4_ITEM: '0001',
        PX4_EMPRES: '01',
        PX4_FILIAL: '01',
        PX4_NOME: 'Matriz São Paulo',
      },
      {
        PX4_CONTRA: 'CT0001',
        PX4_ITEM: '0002',
        PX4_EMPRES: '01',
        PX4_FILIAL: '02',
        PX4_NOME: 'Filial Rio de Janeiro',
      },
      {
        PX4_CONTRA: 'CT0001',
        PX4_ITEM: '0003',
        PX4_EMPRES: '02',
        PX4_FILIAL: '01',
        PX4_NOME: 'Empresa 2 - Filial 1',
      },
    ];
  }

  private getMockAccounting(): any[] {
    return [
      {
        PB9_CONTRA: 'CT0001',
        PB9_ITEM: '0001',
        PB9_CONTA: '1.01.01.001',
        PB9_CC: 'CC001',
        PB9_VALOR: 5000.0,
      },
      {
        PB9_CONTRA: 'CT0001',
        PB9_ITEM: '0002',
        PB9_CONTA: '1.01.01.002',
        PB9_CC: 'CC002',
        PB9_VALOR: 3750.0,
      },
      {
        PB9_CONTRA: 'CT0001',
        PB9_ITEM: '0003',
        PB9_CONTA: '1.01.01.003',
        PB9_CC: 'CC003',
        PB9_VALOR: 5000.0,
      },
    ];
  }

  private getMockSuppliers(): any[] {
    return [
      {
        PX7_CONTRA: 'CT0001',
        PX7_ITEM: '0001',
        PX7_FORNEC: '000001',
        PX7_LOJA: '01',
        PX7_NOME: 'Fornecedor ABC Ltda',
      },
      {
        PX7_CONTRA: 'CT0001',
        PX7_ITEM: '0002',
        PX7_FORNEC: '000002',
        PX7_LOJA: '01',
        PX7_NOME: 'Fornecedor XYZ S/A',
      },
      {
        PX7_CONTRA: 'CT0001',
        PX7_ITEM: '0003',
        PX7_FORNEC: '000003',
        PX7_LOJA: '01',
        PX7_NOME: 'Fornecedor 123 Eireli',
      },
    ];
  }

  private getMockInitializer(alias: string): any {
    // Return default initializer mock for all aliases
    // Initializers typically contain default values, settings, or metadata
    const defaultInitializer = {
      PX2: {
        PX2_CONTRA: '',
        PX2_DESCRI: '',
        PX2_DTINIC: new Date().toISOString().split('T')[0],
        PX2_DTFIM: new Date().toISOString().split('T')[0],
        PX2_VALOR: 0,
        PX2_STATUS: 'A',
      },
      PB9: {
        PB9_CONTRA: '',
        PB9_ITEM: '',
        PB9_CONTA: '',
        PB9_CC: '',
        PB9_VALOR: 0,
      },
      PX7: {
        PX7_CONTRA: '',
        PX7_ITEM: '',
        PX7_FORNEC: '',
        PX7_LOJA: '01',
        PX7_NOME: '',
      },
      PX3: {
        PX3_CONTRA: '',
        PX3_ITEM: '',
        PX3_PRODUT: '',
        PX3_DESCRI: '',
        PX3_QUANT: 0,
        PX3_PRECO: 0,
        PX3_TOTAL: 0,
      },
      PX4: {
        PX4_CONTRA: '',
        PX4_ITEM: '',
        PX4_EMPRES: '01',
        PX4_FILIAL: '01',
        PX4_NOME: '',
      },
      PX6: {
        PX6_CONTRA: '',
        PX6_ITEM: '',
        PX6_USER: '',
        PX6_NOME: '',
        PX6_PERFIL: 'USER',
      },
    };

    return defaultInitializer[alias as keyof typeof defaultInitializer] || {};
  }
}
