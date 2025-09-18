import { Component, forwardRef, Input, OnDestroy, OnInit } from '@angular/core';
import {
  ControlValueAccessor,
  FormControl,
  NG_VALUE_ACCESSOR,
  ReactiveFormsModule,
} from '@angular/forms';
import { PoDynamicFormField, PoModule } from '@po-ui/ng-components';
import { InputFieldBaseDirective } from './input-field-base.directive';
import { TitleCasePipe } from '@angular/common';
import { CoreService } from '../../../core/services/core.service';

@Component({
  selector: 'app-input-field',
  templateUrl: './input-field.component.html',
  styleUrl: './input-field.component.scss',
  standalone: false,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => InputFieldComponent),
      multi: true,
    },
  ],
})
export class InputFieldComponent
  extends InputFieldBaseDirective
  implements OnInit, ControlValueAccessor, OnDestroy
{
  @Input('field') field: any;
  @Input({ required: false }) onChange!: (value: any) => void;
  @Input({ required: false }) valueField: string = '';
  @Input({ required: false }) disabled: boolean = false;
  @Input() control!: FormControl | any;
  @Input({ required: true }) onChangeField!: (field: any) => void;
  @Input() validateOnInput!: boolean;

  get disabledString(): string {
    return this.disabled.toString();
  }

  constructor(titleCase: TitleCasePipe, private coreService: CoreService) {
    super(titleCase);
  }

  ngOnInit(): void {
    const field = this.createField(this.field);
    this.field = field;
  }

  ngOnDestroy(): void {
    // Cleanup logic here
  }

  lookupChange(event: any, field: any) {
    // Compara o valor antigo com o novo, só executa se for diferente
    const oldValue = this.control.value;
    if (oldValue !== event) {
      this.control.setValue(event);
    }
    if (!this.isDisabled(field)) {
      this.onChangeField(field);
    }
  }

  // Funções de callback
  private onTouched!: () => void;

  // Métodos da interface ControlValueAccessor
  writeValue(value: any): void {
    console.warn('writeValue=>', value);

    this.valueField = value;
  }

  registerOnChange(fn: (value: any) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState?(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  // Método para atualizar o valor e notificar o Angular Forms
  updateValue(value: any): void {
    this.valueField = value;

    if (this.onChange) {
      this.onChange(value);
    }
    if (this.onTouched) {
      this.onTouched();
    }
  }

  isDisabled(field: PoDynamicFormField): any {
    return field.disabled || this.disabled;
  }

  onChangeFieldModel(visibleField: PoDynamicFormField) {
    if (this.validateOnInput) {
      const { property } = visibleField;
      const { changedFieldIndex } = this.getField(property);
      this.triggerValidationOnForm(changedFieldIndex);
    }
  }

  private triggerValidationOnForm(changedFieldIndex: number) {
    console.warn('triggerValidationOnForm=>', changedFieldIndex);

    // const isValidatableField = this.validateFields?.length
    //   ? this.validateFieldsChecker(this.validateFields, this.fields[changedFieldIndex].property)
    //   : true;
    // const hasValidationForm = this.validate && isValidatableField && this.formValidate.observers.length;

    // if (hasValidationForm) {
    //   const updatedField = this.fields[changedFieldIndex];
    //   this.formValidate.emit(updatedField);
    // }
  }

   private getField(property: string) {
    const changedFieldIndex = this.field.findIndex((field: { property: string; }) => field.property === property);
    const changedField = this.field[changedFieldIndex];

    return { changedField, changedFieldIndex };
  }
}
