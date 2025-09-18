import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { GridFormComponent } from './grid-form.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { PoModule } from '@po-ui/ng-components';
import { DynamicFormModule } from '../dynamic-form/dynamic-form.module';
import { InputFieldModule } from '../input-field/input-field.module';



@NgModule({
  declarations: [GridFormComponent],
  imports: [
    CommonModule,
    FormsModule,
    PoModule,
    ReactiveFormsModule,
    DynamicFormModule,
    InputFieldModule
  ],
  exports: [GridFormComponent],
})
export class GridFormModule { }
