import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class HttpService {
  constructor(private http: HttpClient) {}

  get(endpoint: string, params?: any, headers?: any): Observable<any> {
    // Use relative paths to enable proxy interception in development
    const url = environment.production
      ? `${environment.apiEndpointPath}/${endpoint}`
      : `/rest/${endpoint}`;
    return this.http.get<any>(
      url,
      JSON.parse(JSON.stringify({ params, headers }))
    );
  }

  post(
    endpoint: string,
    body: any,
    params?: any,
    headers?: any
  ): Observable<any> {
    const url = environment.production
      ? `${environment.apiEndpointPath}/${endpoint}`
      : `/rest/${endpoint}`;
    const options = {
      params,
      headers: headers ? new HttpHeaders(headers) : undefined,
    };
    return this.http.post<any>(url, body, options);
  }

  put(
    endpoint: string,
    body: any,
    params?: any,
    headers?: any
  ): Observable<any> {
    const url = environment.production
      ? `${environment.apiEndpointPath}/${endpoint}`
      : `/rest/${endpoint}`;
    return this.http.put<any>(
      url,
      body,
      JSON.parse(JSON.stringify({ params, headers }))
    );
  }

  delete(endpoint: string, params?: any, headers?: any): Observable<any> {
    const url = environment.production
      ? `${environment.apiEndpointPath}/${endpoint}`
      : `/rest/${endpoint}`;
    return this.http.delete<any>(
      url,
      JSON.parse(JSON.stringify({ params, headers }))
    );
  }
}
