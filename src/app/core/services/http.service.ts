import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../../environments/environment';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class HttpService {

  constructor(private http: HttpClient) { }

  get(endpoint: string, params?: any, headers?: any): Observable<any> {
    return this.http.get<any>(`${environment.apiEndpointPath}/${endpoint}`, JSON.parse(JSON.stringify({params, headers})));
  }

  post(endpoint: string, body: any, params?: any, headers?: any): Observable<any> {
    const options = {
      params,
      headers: headers ? new HttpHeaders(headers) : undefined
    };
    return this.http.post<any>(`${environment.apiEndpointPath}/${endpoint}`, body, options);
  }

  put(endpoint: string, body: any, params?: any, headers?: any): Observable<any> {
    return this.http.put<any>(`${environment.apiEndpointPath}/${endpoint}`, body, JSON.parse(JSON.stringify({params, headers})));
  }

  delete(endpoint: string, params?: any, headers?: any): Observable<any> {
    return this.http.delete<any>(`${environment.apiEndpointPath}/${endpoint}`, JSON.parse(JSON.stringify({params, headers})));
  }
}
