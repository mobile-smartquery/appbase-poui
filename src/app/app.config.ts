import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { provideRouter } from '@angular/router';
import { APP_ROUTES } from './app.routes';
import {
  ApplicationConfig,
  importProvidersFrom,
  provideZoneChangeDetection,
} from '@angular/core';
import {
  HTTP_INTERCEPTORS,
  provideHttpClient,
  withInterceptorsFromDi,
} from '@angular/common/http';
import { PoHttpRequestModule } from '@po-ui/ng-components';
import { provideAnimations } from '@angular/platform-browser/animations';
import { TokenHttpInterceptor } from './core/interceptors/token-http.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    // Roteamento principal da aplicação
    provideRouter(APP_ROUTES),

    // Configuração HTTP
    provideHttpClient(),
    provideHttpClient(withInterceptorsFromDi()),

    //  Importa os módulos necessários pro Angular reconhecer ngModel, *ngIf, router-outlet etc.
    importProvidersFrom([PoHttpRequestModule, FormsModule, CommonModule]),

    // Animações e desempenho
    provideAnimations(),
    provideZoneChangeDetection({ eventCoalescing: true }),

    // Interceptor de autenticação
    {
      provide: HTTP_INTERCEPTORS,
      useClass: TokenHttpInterceptor,
      multi: true,
    },
  ],
};
