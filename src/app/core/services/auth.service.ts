import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { tap } from 'rxjs/operators';

export interface TokenResponse {
  access_token: string;
  token_type?: string;
  expires_in?: number;
  [k: string]: any;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private storageKey = 'auth_token';

  constructor(private http: HttpClient) {}

  login(username: string, password: string) {
    const url = '/rest/api/oauth2/v1/token';

    const params = new HttpParams()
      .set('grant_type', 'password')
      .set('username', username)
      .set('password', password);

    return this.http.post<TokenResponse>(url, null, { params }).pipe(
      tap((res) => {
        if (res?.access_token) {
          localStorage.setItem(this.storageKey, res.access_token);
          console.log('✅ Token salvo no localStorage:', res.access_token);
        }
      })
    );
  }

  get token(): string | null {
    return localStorage.getItem(this.storageKey);
  }

  logout() {
    localStorage.removeItem(this.storageKey);
  }
}
