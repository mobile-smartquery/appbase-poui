import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { PoPageLoginModule } from '@po-ui/ng-templates';
import { PoNotificationService } from '@po-ui/ng-components';

import { StorageService } from '../../core/services/storage.service';

@Component({
  standalone: true,
  selector: 'app-login',
  imports: [CommonModule, PoPageLoginModule],
  template: `
    <po-page-login
      p-title="Portal de Contratos"
      p-subtitle="Acesso restrito a usuários autorizados"
      p-hide-logo="true"
      [p-literals]="literals"
      (p-login-submit)="onLogin($event)"
    >
    </po-page-login>
  `,
})
export class LoginComponent {
  private router = inject(Router);
  private storage = inject(StorageService);
  private poNotification = inject(PoNotificationService);

  literals = {
    welcome: 'Bem-vindo',
    loginPlaceholder: 'Usuário',
    passwordPlaceholder: 'Senha',
    submitLabel: 'Entrar',
  };

  async onLogin(form: any) {
    console.log('EVENTO RECEBIDO:', form);

    try {
      const base =
        location.hostname === 'localhost' || location.hostname === '127.0.0.1'
          ? ''
          : 'http://protheusawsmobile.ddns.net:8080';

      const url = `${base}/rest/api/oauth2/v1/token?grant_type=password&username=${encodeURIComponent(
        form.login
      )}&password=${encodeURIComponent(form.password)}`;

      const resp = await fetch(url, { method: 'POST' });
      const raw = await resp.text();

      if (!resp.ok) throw new Error(`Falha ao autenticar (${resp.status})`);

      const data = JSON.parse(raw);
      const token = data?.access_token ?? '';

      if (!token) throw new Error('Token não retornado');

      this.storage.setToken(token);
      this.poNotification.success('Login realizado com sucesso!');

      this.router.navigateByUrl('/dashboard');
    } catch (err: any) {
      console.error(err);
      this.poNotification.error(err?.message || 'Erro no login');
    }
  }
}
