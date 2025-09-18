import { Component } from '@angular/core';
import { StorageService } from '../../../core/services/storage.service';
import { Router } from '@angular/router';

@Component({
  standalone: false,
  selector: 'app-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrl: './toolbar.component.scss'
})
export class ToolbarComponent {

  constructor(private storageService: StorageService, private router: Router) { }

  logout() {
    this.storageService.removeToken();
    this.router.navigate(['/login']);
  }
}
