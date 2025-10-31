import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PoPageLoginModule, PoPageLogin } from '@po-ui/ng-templates';
import { PoNotificationService } from '@po-ui/ng-components';

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
  literals = {
    welcome: 'Bem-vindo',
    loginPlaceholder: 'Usuário',
    passwordPlaceholder: 'Senha',
    submitLabel: 'Entrar',
  };

  constructor(private poNotification: PoNotificationService) {}

  async onLogin(form: PoPageLogin) {
    console.log('🔹 Evento p-send disparado!', form);

    try {
      const url = `/rest/api/oauth2/v1/token?grant_type=password&username=${encodeURIComponent(
        form.login
      )}&password=${encodeURIComponent(form.password)}`;

      const resp = await fetch(url, { method: 'POST' });
      const raw = await resp.text();

      console.log('🔹 Resposta da API:', raw);

      if (!resp.ok) throw new Error(`Falha ao autenticar (${resp.status})`);

      const data = JSON.parse(raw);
      const token = data?.access_token ?? '';

      if (!token) throw new Error('Token não retornado pela API');

      this.poNotification.success('Login realizado com sucesso!');
      console.log('✅ Token:', token);
    } catch (err: any) {
      console.error('❌ Erro no login:', err);
      this.poNotification.error(err?.message || 'Falha ao autenticar');
    }
  }
}
