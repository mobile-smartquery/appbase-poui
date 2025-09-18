import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PoModule, PoPageModule } from '@po-ui/ng-components';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { PoTemplatesModule } from '@po-ui/ng-templates';
import { DynamicFormComponent } from './dynamic-form.component';
import { GridFormModule } from '../grid-form/grid-form.module';
import { InputFieldModule } from "../input-field/input-field.module";

@NgModule({
  declarations: [DynamicFormComponent],
  imports: [
    CommonModule,
    PoModule,
    FormsModule,
    PoPageModule,
    ReactiveFormsModule,
    FormsModule,
    PoTemplatesModule,
    InputFieldModule,
],
  exports: [DynamicFormComponent]
})
export class DynamicFormModule {}
