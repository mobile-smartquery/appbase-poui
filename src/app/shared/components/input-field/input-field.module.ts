import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { InputFieldComponent } from './input-field.component';
import { PoModule, PoPageModule } from '@po-ui/ng-components';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { PoTemplatesModule } from '@po-ui/ng-templates';

@NgModule({
  declarations: [InputFieldComponent],
  imports: [CommonModule, PoModule, FormsModule, PoPageModule, ReactiveFormsModule, PoTemplatesModule],
  exports: [InputFieldComponent]
})
export class InputFieldModule {}
