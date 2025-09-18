import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class StorageService {

  constructor() { }

  // Método para salvar dados no localStorage
  setItem(key: string, value: any): void {
    const jsonValue = JSON.stringify(value);
    localStorage.setItem(key, jsonValue);
  }

  // Método para recuperar dados do localStorage
  getItem(key: string): any {
    const value = localStorage.getItem(key);
    if (value) {
      return JSON.parse(value);
    }
    return null;
  }

  // Método para remover um item do localStorage
  removeItem(key: string): void {
    localStorage.removeItem(key);
  }

  // Método para limpar todos os dados do localStorage
  clear(): void {
    localStorage.clear();
  }

  // Método para salvar dados no sessionStorage
  setSessionItem(key: string, value: any): void {
    const jsonValue = JSON.stringify(value);
    sessionStorage.setItem(key, jsonValue);
  }

  // Método para recuperar dados do sessionStorage
  getSessionItem(key: string): any {
    const value = sessionStorage.getItem(key);
    if (value) {
      return JSON.parse(value);
    }
    return null;
  }

  setToken(token: string): void {
    this.setItem('thirdPartyContratToken', token);
  }

  getToken(): string {
    return this.getItem('thirdPartyContratToken');
  }

  removeToken(): void {
    this.removeItem('thirdPartyContratToken');
  }

  // Método para remover um item do sessionStorage
  removeSessionItem(key: string): void {
    sessionStorage.removeItem(key);
  }

  // Método para limpar todos os dados do sessionStorage
  clearSession(): void {
    sessionStorage.clear();
  }
}
