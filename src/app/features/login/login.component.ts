import { Component } from '@angular/core';
import { SharedModule } from '../../shared/shared.module';
import { PoModule, PoPageModule } from '@po-ui/ng-components';
import { PoPageLoginAuthenticationType, PoPageLoginLiterals, PoPageLoginModule } from '@po-ui/ng-templates';
import { StorageService } from '../../core/services/storage.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  imports: [PoPageModule, PoModule, SharedModule, PoPageLoginModule ],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  readonly authenticationType = PoPageLoginAuthenticationType.Bearer;

  literals: PoPageLoginLiterals = {
    welcome: 'Bem-vindo ao Sistema de Gestão de Notas',
    registerUrl: 'Configurações Avançadas',
    rememberUser: 'Lembrar usuário',
    loginLabel: 'Usuário',
    loginPlaceholder: 'Insira seu usuário de acesso',
    passwordLabel: 'Senha',
    passwordPlaceholder: 'Insira sua senha de acesso',
  };
  

  constructor(private storageService: StorageService, private router: Router) { }

  login(event: any) {
    if (event.login === 'admin' && event.password === '123456') {
      const profile = { name: 'Joaquim Martins'};
      const profiBase64 = btoa(JSON.stringify(profile));
      this.storageService.setToken(profiBase64);
      this.router.navigate(['/dashboard']);
    }
  }
}
