import { Component, Input, OnInit, signal, WritableSignal } from '@angular/core';
import { first, lastValueFrom, Observable } from 'rxjs';
import { CoreService } from '../../../core/services/core.service';
import { Utils } from '../../utils/utils';
import { FormBuilder, FormControl, FormGroup, ValidatorFn, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PoDynamicFormField, PoNotificationService } from '@po-ui/ng-components';
import { IFieldsSheetsColumns } from '../../interfaces/IDictionary';

@Component({
  selector: 'app-dynamic-form',
  templateUrl: './dynamic-form.component.html',
  styleUrl: './dynamic-form.component.scss',
  standalone: false
})
export class DynamicFormComponent implements OnInit {
  @Input({ required: true }) alias!: string;
  @Input({ required: true }) mode: 'edit' | 'view' | 'new' = 'view';
  @Input() fieldsFilter: Array<string> = [];

  /**
   * Indica se a estrutura do formulário é dinâmica.
   * Se for true, o componente buscará a estrutura correspondente ao alias.
   * Se for false, utilizará a estrutura fornecida via metodo.
   */
  @Input() isDynamicStruct: boolean = true

  struct!: IFieldsSheetsColumns;
  loading: WritableSignal<boolean> = signal(false);

  // Único formsMap para todos os formulários dinâmicos
  formsMap: Map<string, { formGroup: FormGroup; fields: any[] }> = new Map();

  formStruct: { fields: any[]; sheets: any[]; columns: any[] } = {
    fields: [],
    sheets: [],
    columns: []
  };

  private onGetFormData: Observable<any> | null = null;
  private responseData: any = null;

  private _callbackAfterFormLoad: ((formStruct: any) => void) | null = null;

  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute,
    private coreService: CoreService,
    private poNotification: PoNotificationService,
    private fb: FormBuilder
  ) {}

  ngOnInit(): void {
    if (this.isDynamicStruct) {
      this._initializeStructure();
    }
  }

  setFormDataCallback(callback: () => Observable<any>): void {
    this.onGetFormData = callback();
  }

  // callback chamado após o carregamento da estrutura do formulário
  setCallbackAfterFormLoad(callback: () => void): void {
    this._callbackAfterFormLoad = callback;
  }

  setStruct(struct: IFieldsSheetsColumns): void {
    if (struct && struct.fields && struct.sheets && struct.columns) {
      this.struct = struct;
      this._initializeStructure();
    } else {
      this.poNotification.error(`Estrutura inválida fornecida para o formulário`);
    }
  }

  private async _initializeStructure() {
    try {
      this.loading.set(true);
      let formViewDef;
      if (this.struct) {
        // console.warn('STRUCT informado via @Input:', this.struct);

        // Se struct foi informado via @Input, utiliza ele
        this.formStruct.fields = this.struct.fields || [];
        this.formStruct.sheets = this.struct.sheets || [];
        this.formStruct.columns = this.struct.columns || [];

        // console.warn('this.struct.fields:', this.struct.fields);
        // console.warn('STRUCT formStruct:', this.formStruct);
      } else {
        // Caso contrário, busca a estrutura normalmente
        const response: any = await lastValueFrom(this.coreService.getStructAlias(this.alias));
        formViewDef = Utils.mapViewDef(response, this.coreService, true);

        this.formStruct.fields = formViewDef.fields || [];
        this.formStruct.sheets = formViewDef.sheets || [];
        this.formStruct.columns = formViewDef.columns || [];

        if (this._callbackAfterFormLoad) {
          // Chama o callback após carregar a estrutura do formulário
          this._callbackAfterFormLoad(Object.assign({}, this.formStruct));
        }

        // Caso foi informado o fieldsFilter, filtra os campos para incluir apenas os especificados
        if (this.fieldsFilter && this.fieldsFilter.length > 0) {
          this.formStruct.fields = formViewDef.fields.filter(field => this.fieldsFilter.includes(field.property));
        }
      }

      // console.warn('CRIA FORM:', this.formStruct.fields);

      // Sempre adiciona ao único formsMap
      this._addFormToMap('FORM' + this.alias, this.formStruct.fields);

      // Verifica qual o modo do formulário
      if (this.mode === 'new') {
        // Chama o inicializador dos campos do formulário
        await this._initializeFields();
      } else if (this.mode === 'edit' || this.mode === 'view') {
        // Verifica se existe callback para obter os dados do formulário
        if (this.onGetFormData) {
          await this._initializeData();
        } else {
          // console.warn(`Nenhum callback definido para obter os dados do formulário`);
        }
      }

      this.loading.set(false);
    } catch (error: any) {
      this.router.navigate(['..'], { relativeTo: this.activatedRoute });
      console.error('Erro ao carregar a estrutura do formulário:', error);
      this.poNotification.error(`Ocorreu um erro ao carregar a estrutura do formulário`);
      this.loading.set(false);
    }
  }

  private async _initializeData() {
    try {
      if (!this.onGetFormData) {
        throw new Error('onGetFormData is null');
      }
      const response: any = await lastValueFrom(this.onGetFormData);
      // console.warn('Response do _initializeData:', response);
      this.responseData = response; // Armazena a resposta para uso posterior
      this._setFormValues('FORM' + this.alias, response);
      this.responseData = null; // Armazena a resposta para uso posterior
    } catch (error) {
      console.error('Erro ao inicializar os campos do formulário:', error);
      this.poNotification.warning(`Ocorreu um erro ao inicializar os campos do formulário`);
    }
  }

  private async _initializeFields() {
    try {
      const response: any = await lastValueFrom(this.coreService.getDictionaryInitializer(this.alias));
      // console.warn('Response do initializer:', response);

      this._setFormValues('FORM' + this.alias, response);
    } catch (error) {
      console.error('Erro ao inicializar os campos do formulário:', error);
      this.poNotification.warning(`Ocorreu um erro ao inicializar os campos do formulário`);
    }
  }

  private _addFormToMap(formId: string, fields: any[]): void {
    // Remove o form antigo se já existir
    if (this.formsMap.has(formId)) {
      this.formsMap.delete(formId);
    }

    const formGroup = new FormGroup({});
    fields.forEach(field => {
      formGroup.addControl(field.property, new FormControl(field.defaultValue || '', this._getValidators(field)));
    });

    this.formsMap.set(formId, { formGroup, fields });
    // console.log(`Formulário com ID ${formId} adicionado ao Map`, this.formsMap.get(formId));
  }

  private _getValidators(field: any): ValidatorFn[] {
    const validators = [];
    if (field.required) validators.push(Validators.required);

    // Só aplica minLength/maxLength se não for campo do tipo 'date'
    if (field.type !== 'date') {
      if (field.minLength) validators.push(Validators.minLength(field.minLength));
      if (field.maxLength) validators.push(Validators.maxLength(field.maxLength));
    }

    if (field.pattern) validators.push(Validators.pattern(field.pattern));
    return validators;
  }

  setFormValues(values: any): void {
    this._setFormValues('FORM' + this.alias, values);
  }

  // etodo que atribui no form correspondente os valores
  private _setFormValues(formId: string, values: any): void {
    const formData = this.formsMap.get(formId);
    if (formData) {
      const formGroup = formData.formGroup;
      if (formGroup) {
      // Atualiza os valores do FormGroup campo a campo, apenas se o valor não estiver vazio
      Object.keys(values).forEach(key => {
        let value = values[key];

        // Ignora campos que contenham '_FILIAL'
        if (key.includes('_FILIAL')) {
        return;
        }

        // Verifica se o campo é do tipo 'date' para formatar
        const field = formData.fields.find(f => f.property === key);
        if (field && field.type === 'date' && typeof value === 'string' && /^\d{8}$/.test(value)) {
        // Converte de YYYYMMDD para YYYY-MM-DD
        value = `${value.substring(0, 4)}-${value.substring(4, 6)}-${value.substring(6, 8)}`;
        }

        // Só altera se o valor for diferente do atual
        if (formGroup.controls[key] && value !== formGroup.controls[key].value) {
        formGroup.controls[key].setValue(value);
        }
      });
      }
    }
  }

  getFormGroup(formId: string): FormGroup | null {
    const formData = this.formsMap.get(formId);
    return formData ? formData.formGroup : null;
  }

  /**
   * Retorna true se todos os formulários estiverem válidos, false caso contrário.
   */
  isFormValid() {
    this.formsMap.forEach((formData, formId) => {
      const formGroup = formData.formGroup;
      if (formGroup) {
        console.log(`Valores do formulário ${formId}:`, formGroup.value);
      }
    });

    return this._validateAllForms();
  }

  /**
   * Retorna um objeto com os valores de todos os formulários.
   */
  getFormData(): { [formId: string]: any } {
    const data: { [formId: string]: any } = {};
    this.formsMap.forEach((formData, formId) => {
      const formValues = { ...formData.formGroup.value };
      Object.keys(formValues).forEach(key => {
      const field = formData.fields.find(f => f.property === key);
      if (field && field.type === 'date' && typeof formValues[key] === 'string') {
        formValues[key] = formValues[key].replace(/-/g, '');
      }
      });
      data[formId] = formValues;
    });
    return data;
  }

  private _validateAllForms(): boolean {
    let allValid = true;
    let focused = false;

    this.formsMap.forEach((formData) => {
      const formGroup = formData.formGroup;

      if (formGroup) {
        formGroup.markAllAsTouched();

        if (!formGroup.valid) {
          allValid = false;

          Object.entries(formGroup.controls).forEach(([controlName, control]) => {
            control.markAsDirty();

            if (control.invalid) {
              control.setErrors({ ...control.errors, invalid: true });

              // Foca apenas no primeiro campo inválido encontrado
              if (!focused) {
                const invalidControlElement = document.querySelector(
                  `[formControlName="${controlName}"]`
                ) as HTMLElement;
                if (invalidControlElement) {
                  invalidControlElement.focus();
                  focused = true;
                }
              }
            }
          });
        }
      }
    });

    return allValid;
  }

  onChangeField = (field: any) => {

    const value = this.getFormGroup('FORM' + this.alias)?.get(field.property)?.value;
    // console.log(value);

    // Pega os erros do campo
    const errors = this.getFormGroup('FORM' + this.alias)?.get(field.property)?.errors;

    if (errors) {
      console.warn(`Erros do campo ${field.property}:`, errors);
    }

    // Verifica se o campo possui gatilho
    if (field.existTrigger) {
      console.warn('Campo com gatilho:', field.property, 'Valor:', value);

      this._executeTrigger(field, value);
    }
  };

  private _executeTrigger(field: PoDynamicFormField, value: any) {
    // Pega os dados do formulário
    const formId = 'FORM' + this.alias;
    const formGroup = this.getFormGroup(formId);
    const formData = this.responseData || this.getFormData()[formId];

    // Verifica se o campo é válido antes de executar o gatilho
    const control = formGroup?.get(field.property);
    if (control && control.invalid) {
      control.markAsTouched();
      control.markAsDirty();
      console.warn('Campo inválido, não executando gatilho:', field.property);
      return;
    }

    // Desabilita o campo enquanto executa o gatilho
    control?.disable();

    this.coreService
      .executeTrigger(field.property, formData)
      .pipe(first())
      .subscribe({
        next: (response: any) => {
          console.warn(`Trigger executado para o campo ${field.property}`, response);
          this._setFormValues(formId, response);
          if (this.mode !== 'view') {
            control?.enable();
          }
        },
        error: () => {
          // Em caso de erro, reabilita o campo se não for modo 'view'
          if (this.mode !== 'view') {
            control?.enable();
          }
        },
        complete: () => {
          // Reabilita o campo após a execução do gatilho
          if (this.mode !== 'view') {
            control?.enable();
          }
        }
      });
  }

  clearFormData(): void {
    this.formsMap.forEach((formData, formId) => {
      const formGroup = formData.formGroup;
      if (formGroup) {
        formGroup.reset();
        formGroup.markAsPristine();
        formGroup.markAsUntouched();
      }
    });
  }
}
