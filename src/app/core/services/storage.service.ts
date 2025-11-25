import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class StorageService {
  private TOKEN_KEY = 'auth_token';

  constructor() {}

  // LocalStorage -----------------------------

  setItem(key: string, value: any): void {
    localStorage.setItem(key, JSON.stringify(value));
  }

  getItem(key: string): any {
    const value = localStorage.getItem(key);
    return value ? JSON.parse(value) : null;
  }

  removeItem(key: string): void {
    localStorage.removeItem(key);
  }

  clear(): void {
    localStorage.clear();
  }

  // SessionStorage ---------------------------

  setSessionItem(key: string, value: any): void {
    sessionStorage.setItem(key, JSON.stringify(value));
  }

  getSessionItem(key: string): any {
    const value = sessionStorage.getItem(key);
    return value ? JSON.parse(value) : null;
  }

  removeSessionItem(key: string): void {
    sessionStorage.removeItem(key);
  }

  clearSession(): void {
    sessionStorage.clear();
  }

  // TOKEN ------------------------------------

  setToken(token: string): void {
    this.setItem(this.TOKEN_KEY, token);
  }

  getToken(): string {
    return this.getItem(this.TOKEN_KEY);
  }

  removeToken(): void {
    this.removeItem(this.TOKEN_KEY);
  }
}
