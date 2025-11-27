import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

import { PoPageLoginModule } from '@po-ui/ng-templates';
import { PoNotificationService } from '@po-ui/ng-components';

import { StorageService } from '../../core/services/storage.service';
import { environment } from '../../../environments/environment';

@Component({
  standalone: true,
  selector: 'app-login',
  imports: [CommonModule, PoPageLoginModule],
  styleUrls: ['./login.component.scss'],
  template: `
    <div class="custom-login-logo">
      <img
        src="assets/images/short-logo-conceitho-black.png"
        alt="Conceitho Tecnologia"
      />
    </div>
    <po-page-login
      p-title="Portal de Contratos"
      p-subtitle="Acesso restrito a usuários autorizados"
      p-hide-logo="true"
      [p-literals]="literals"
      (p-login-submit)="onLogin($event)"
    ></po-page-login>
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
      const url = environment.oauthTokenUrl;

      // Enviar credenciais no corpo como application/x-www-form-urlencoded
      const body = new URLSearchParams({
        grant_type: 'password',
        username: form.login,
        password: form.password,
      }).toString();

      console.log('➡️ Enviando POST para:', url, 'body length:', body.length);

      const resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body,
      });

      if (!resp.ok) throw new Error(`Falha ao autenticar (${resp.status})`);

      const data = await resp.json();
      const token = data?.access_token;

      if (!token) throw new Error('Token não retornado');

      this.storage.setToken(token);
      this.poNotification.success('Login realizado com sucesso!');

      this.router.navigateByUrl('/dashboard');
    } catch (err: any) {
      console.error(err);
      this.poNotification.error(err?.message ?? 'Erro no login');
    }
  }
}
