import { Injectable } from '@angular/core';
import { catchError, Observable, of, tap } from 'rxjs';
import { PoNotificationService } from '@po-ui/ng-components';
import { HttpService } from './http.service';

@Injectable({
  providedIn: 'root'
})
export class CoreService {

  constructor(private readonly http: HttpService, private readonly poNotification: PoNotificationService) {}

  getBrowseColumns(alias: string): Observable<any[]> {
    return this.http.get(`dictionary/browse/columns/${alias}`).pipe(
      catchError(error => {
      console.error('Erro ao buscar colunas do browse:', error);
      this.poNotification.error('Erro ao buscar colunas do browse.');
      return of([]); // fallback para o componente não quebrar
      })
    );
  }

  getBrowseItems(alias: string, params: any): Observable<any[]> {
    return this.http.get(`dictionary/browse/items/${alias}`, { ...params }).pipe(
      catchError(error => {
        console.error('Erro ao buscar itens do browse:', error);
        this.poNotification.error('Erro ao buscar itens do browse.');
        return of([]); // fallback para o componente não quebrar
      })
    );
  }

  getStructAlias(alias: string): Observable<any[]> {
    return this.http.get(`dictionary/struct/${alias}`).pipe(
      catchError(error => {
      console.error('Erro ao buscar estrutura:', error);
      this.poNotification.error('Erro ao buscar estrutura.');
      throw error; // rethrow the error to be handled by the caller
      })
    );
  }

  getDictionaryData(alias: string, item: string): Observable<any> {
    return this.http.get(`dictionary/data/${alias}/${encodeURIComponent(item)}`).pipe(
      catchError(error => {
        console.error('Erro ao buscar dados do dicionário:', error);
        this.poNotification.error('Erro ao buscar dados do dicionário.');
        throw error; // fallback para o componente não quebrar
      })
    );
  }

  getDictionaryInitializer(calias: string): Observable<any> {
    return this.http.get(`dictionary/initializer/${calias}`).pipe(
      catchError(error => {
        console.error('Erro ao buscar dados do initializer do dicionário:', error);
        this.poNotification.error('Erro ao buscar dados do initializer do dicionário.');
        return of(null); // fallback para o componente não quebrar
      })
    );
  }

  getLookup(ctabela: string, params: any): Observable<any> {
    return this.http.get(`lookup/${ctabela}`, { ...params }).pipe(
      catchError(error => {
        console.error('Erro ao buscar dados do lookup:', error);
        this.poNotification.error('Erro ao buscar dados do lookup.');
        return of([]); // fallback para o componente não quebrar
      })
    )
  }

  getLookupById(ctabela: string, id: string, idColumn: string): Observable<any> {
    const encodedId = encodeURIComponent(id); // Encode the ID to handle special characters like '/'
    return this.http.get(`lookup/${ctabela}/${encodedId}`, { idx: JSON.stringify([ idColumn ]) }).pipe(
      catchError(error => {
        console.error('Erro ao buscar dados do lookup por ID:', error);
        this.poNotification.error('Erro ao buscar dados do lookup por ID.');
        return of([]); // fallback para o componente não quebrar
      })
    );
  }

  executeTrigger(campo: string, body: any): Observable<any> {
    return this.http.post(`dictionary/trigger/${campo}`, body).pipe(
      catchError(error => {
      console.error('Erro ao executar o trigger:', error);
      this.poNotification.error('Erro ao executar o trigger.');
      return of(null); // fallback para o componente não quebrar
      })
    );
  }

  postContract(body: any): Observable<any> {
    return this.http.post('contract', body).pipe(
      catchError(error => {
        console.error('Erro ao criar contrato:', error);
        this.poNotification.error('Erro ao criar contrato.');
        throw error;
      })
    );
  }

  putContract(body: any): Observable<any> {
    return this.http.put(`contract`, body).pipe(
      catchError(error => {
        console.error('Erro ao atualizar contrato:', error);
        this.poNotification.error('Erro ao atualizar contrato.');
        throw error;
      })
    );
  }

  getContractItems(params?: any): Observable<any[]> {
    return this.http.get('items', params ? { ...params } : undefined).pipe(
      catchError(error => {
        console.error('Erro ao buscar itens do contrato:', error);
        this.poNotification.error('Erro ao buscar itens do contrato.');
        throw error;
      })
    );
  }


  getContractCompanies(params?: any): Observable<any[]> {
    return this.http.get('companies', params ? { ...params } : undefined).pipe(
      catchError(error => {
        console.error('Erro ao buscar empresas do contrato:', error);
        this.poNotification.error('Erro ao buscar empresas do contrato.');
        throw error;
      })
    );
  }

  getContractAccounting(params?: any): Observable<any[]> {
    return this.http.get('accounting', params ? { ...params } : undefined).pipe(
      catchError(error => {
        console.error('Erro ao buscar dados contábeis do contrato:', error);
        this.poNotification.error('Erro ao buscar dados contábeis do contrato.');
        throw error;
      })
    );
  }

  getContractUsers(params?: any): Observable<any[]> {
    return this.http.get('users', params ? { ...params } : undefined).pipe(
      catchError(error => {
        console.error('Erro ao buscar usuários do contrato:', error);
        this.poNotification.error('Erro ao buscar usuários do contrato.');
        throw error;
      })
    );
  }

  getContractSuppliers(params?: any): Observable<any[]> {
    return this.http.get('suppliers', params ? { ...params } : undefined).pipe(
      catchError(error => {
        console.error('Erro ao buscar fornecedores do contrato:', error);
        this.poNotification.error('Erro ao buscar fornecedores do contrato.');
        throw error;
      })
    );
  }
}
