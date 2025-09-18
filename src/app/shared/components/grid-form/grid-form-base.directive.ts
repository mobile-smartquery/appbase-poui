import { Directive, ElementRef, Input, QueryList, ViewChild, ViewChildren } from '@angular/core';
import { PoDynamicFormComponent } from '@po-ui/ng-components';
import { CoreService } from '../../../core/services/core.service';
import { IFieldsSheetsColumns } from '../../interfaces/IDictionary';
import { DynamicFormComponent } from '../dynamic-form/dynamic-form.component';

@Directive()
export class GridFormBaseDirective {

  @ViewChild('formAlias', {static: true}) formAlias!: DynamicFormComponent;
  @ViewChild('gridContainer', { static: true }) gridContainer!: ElementRef;

  @Input({ required: true }) mode: 'edit' | 'view' | 'new' = 'view';
  @Input({required: true}) alias!: any;

  @Input({required: false}) label: string = 'Itens';

  struct: IFieldsSheetsColumns = {
    columns: [],
    fields: [],
    sheets: [],
  }
  fields: any;

  constructor() { }

  // ngOnInit(): void {
  //   // Initialization logic here
  // }

}
