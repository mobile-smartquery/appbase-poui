import { Injectable } from '@angular/core';
import {
  HttpEvent,
  HttpInterceptor,
  HttpHandler,
  HttpRequest,
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable()
export class TokenHttpInterceptor implements HttpInterceptor {
  constructor() {}

  intercept(
    req: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    // Obtém o token de autenticação do AuthService
    // const authToken = "token";

    // // Se o token existir, clona a requisição e adiciona o token no cabeçalho
    // if (authToken) {
    //   const authReq = req.clone({
    //     headers: req.headers.set('Authorization', `Bearer ${authToken}`)
    //   });
    //   return next.handle(authReq);
    // }

    const username =  environment.username;
    const password = environment.password;
    
    const authString = `${username}:${password}`;
    const token = window.btoa(authString);
    const authReq = req.clone({
      setHeaders: {
        Authorization: `Basic ${token}`,
      },
    });

    // Caso não tenha token, processa a requisição normalmente
    return next.handle(authReq);
  }
}
