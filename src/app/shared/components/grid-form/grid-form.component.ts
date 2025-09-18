import { Component, OnInit, signal, WritableSignal, HostListener, ViewChild, ElementRef, Input } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, ValidatorFn, Validators } from '@angular/forms';
import {
  PoButtonComponent,
  PoDialogService,
  PoModalAction,
  PoModalComponent,
  PoNotificationService,
  PoTableAction,
  PoTableColumn
} from '@po-ui/ng-components';
import { GridFormBaseDirective } from './grid-form-base.directive';
import { CoreService } from '../../../core/services/core.service';
import { CustomDynamicFormField } from '../../utils/utils';
import { IFieldsSheetsColumns } from '../../interfaces/IDictionary';

interface CustomTableColumn extends PoTableColumn {
  fieldType?: 'string' | 'number' | 'boolean' | 'date';
  columns?: any;
  searchService?: string;
  fieldLabel?: string;
  fieldValue?: string;
  editField?: boolean;
}

@Component({
  selector: 'app-grid-form',
  templateUrl: './grid-form.component.html',
  styleUrls: ['./grid-form.component.scss'],
  standalone: false
})
export class GridFormComponent extends GridFormBaseDirective implements OnInit {
  @ViewChild('EditionMode', { read: ElementRef, static: true }) editionMode!: any;
  @ViewChild('EditRowModal', { static: true }) editRowModal!: PoModalComponent;

  editedCell: { rowId?: number; columnProperty: string | null } = { columnProperty: null };
  editedRow: any = null;
  loading: WritableSignal<boolean> = signal(false);

  columns: Array<CustomTableColumn> = [
    // { property: "id", label: "ID", type: "cellTemplate" },
    // { property: "name", label: "Nome", type: "cellTemplate" },
    // { property: "description", label: "Descrição", type: "cellTemplate" }
  ];

  _items: WritableSignal<Array<any>> = signal([]);

  editCellFormMode: 'row' | 'cell' = 'row';
  editCellModel: 'new' | 'edit' = 'new';

  cellFormGroup!: FormGroup;

  public actions: Array<PoTableAction> = [
    {
      label: '',
      action: (row: any) => this.deleteRow(row),
      icon: 'an an-x-circle',
      type: 'danger'
    }
  ];

  constructor(
    private fb: FormBuilder,
    private readonly coreService: CoreService,
    private readonly poNotification: PoNotificationService,
    private readonly poDialog: PoDialogService
  ) {
    super();
  }

  ngOnInit(): void {
    if (this.struct?.fields && this.struct?.fields.length > 0) {
      const fields = this.struct?.fields || [];
      this.fields = fields;
      this.columns = this.loadColumns(fields);
      this._addCellForm(fields);
    }
  }

  setStruct(struct: IFieldsSheetsColumns): void {
    this.struct = struct;
    const fields = this.struct?.fields || [];
    this.fields = fields;
    this.columns = this.loadColumns(fields);
    this._addCellForm(fields);
    this.formAlias.setStruct(struct);
  }


  // metodo que seta os itens no grid
  setItems(items: Array<any>): void {
    // Adiciona como se fosse linha a linha
    this._items.set(items.map((item: any) => {
      // Adiciona os campos _id, _delete e _edit
      return {
        ...item,
        _id: item._id || Math.floor(Math.random() * 1000000), // Gera um ID único se não existir
        _delete: item._delete || false,
        _edit: item._edit || false
      };
    }));
  }

  getItems(): Array<any> {
    return this._items();
  }

  private loadColumns(fields: CustomDynamicFormField[]) {
    // console.warn('fields', fields);

    return fields.map((field: CustomDynamicFormField) => {
      const column: CustomTableColumn = {
        property: field.property,
        label: field.label,
        type: 'cellTemplate',
        visible: field.visible
        // visible: field.enabl
        // fieldType: field.fieldType || 'string',
        // columns: field.columns || [],
        // searchService: field.searchService || null,
        // fieldLabel: field.fieldLabel || null,
        // fieldValue: field.fieldValue || null,
        // editField: field.editField || false
      };
      return column;
    });
  }

  // Pega o field pelo property
  getFieldByProperty(property: string): CustomDynamicFormField | undefined {
    const field = this.fields.find((field: CustomDynamicFormField) => field.property === property);
    field.gridColumns = 12;
    field.gridColumnsSm = 12;
    return field;
  }

  onCellClick(row: any, columnProperty: string): void {
    console.warn(row, columnProperty);

    if (row._delete) {
      return;
    }

    this.editCellModel = 'edit';
    if (this.editCellFormMode !== 'cell') {
      // realiza o carregamento do dynamicFormRef com os dados do row
      console.warn('aqui onCellClick', row, columnProperty);

      this.openEditRowModal(row, columnProperty);
      // this.editRowModal.open();
      return;
    }

    if (row._delete || this.editedCell.columnProperty === columnProperty) return;

    console.warn('TROCANDO', row, columnProperty);

    this.closeAllEditors();
    row._edit = true;
    this.editedCell = { rowId: row._id, columnProperty };
    // this.setGridFormValuesFromRow(row);
  }

  // Função que seta os valores do gridForm com os dados do row das cellFormGroup
  setGridFormValuesFromRow(row: any): void {
    console.warn('SETANDO VALORES NO GRID');

    if (!row || !this.cellFormGroup) return;
    Object.keys(this.cellFormGroup.controls).forEach(key => {
      if (row.hasOwnProperty(key)) {
        this.cellFormGroup.get(key)?.setValue(row[key]);
      } else {
        this.cellFormGroup.get(key)?.reset();
      }
    });
  }

  openEditRowModal(row: any, columnProperty: string): void {
    this.editedCell = { rowId: row._id, columnProperty };
    this.editCellModel = 'edit';
    this.editedRow = row;

    this.editRowModal.open();

    console.warn('row', row);
    console.warn('columnProperty', columnProperty);

    this.setFormValuesFromRow(row);
  }

  // função que seta os valores do formulario com os dados do row
  setFormValuesFromRow(row: any): void {
    console.warn('setFormValuesFromRow', row);
    this.formAlias.setFormValues(row);
  }

  onInputKeydown(event: KeyboardEvent, row: any, columnProperty: string): void {
    if (event.key === 'Escape') {
      this._confirmExitCellForm(
        () => {
          this._resetCellForm();
          this.closeEditor(row);
        },
        () => {
          this._resetCellForm();
          this.deleteRow(row);
          this.closeEditor(row);
        }
      );
    } else if (event.key === 'Delete') {
      this._resetCellForm();
      this.deleteRow(row);
    } else if (event.key === 'Tab') {
      console.warn('Tab pressed', row, columnProperty);

      // event.preventDefault();
      const currentIndex = this.columns.findIndex(column => column.property === columnProperty);
      if (currentIndex !== -1) {
        const nextColumn = this.columns[currentIndex + 1];
        if (nextColumn) {
          this.onCellClick(row, nextColumn.property ?? '');
        } else {
          this.closeEditor(row); // Close editor if no next column
        }
      }
    } else if (event.key === 'Enter') {
      if (!this._isCellFormValid()) {
        return;
      }

      // Verifica se esta no final do formulário excluindo os campos que começam com _
      const lastColumn = this.columns[this.columns.length - 1];
      if (columnProperty === lastColumn.property) {
        this.closeEditor(row); // Fecha o editor se estiver no final
        this._resetCellForm(); // Reseta o formulário
      } else {
        const nextColumn = this.columns.find(column => column.property === columnProperty);
        if (nextColumn) {
          this.onCellClick(row, nextColumn.property ?? '');
        }
      }
    } else if (event.key === 'ArrowUp') {
      this._confirmExitCellForm(
        () => {
          // Navega para a célula acima, fecha a edição da célula atual e se caso não tenha mais linhas para cima faz nada
          const currentIndex = this._items().indexOf(row);
          this.closeAllEditors();
          this._resetCellForm();
          if (currentIndex > 0) {
            const previousRow = this._items()[currentIndex - 1];
            this.closeAllEditors();
            this.onCellClick(previousRow, columnProperty);
          }
        },
        () => {
          // Navega para a célula acima, fecha a edição da célula atual e se caso não tenha mais linhas para cima faz nada
          const currentIndex = this._items().indexOf(row);
          this.closeAllEditors();
          this._resetCellForm();
          this.deleteRow(row);
          if (currentIndex > 0) {
            const previousRow = this._items()[currentIndex - 1];
            this.closeAllEditors();
            this.onCellClick(previousRow, columnProperty);
          }
        }
      );
    } else if (event.key === 'ArrowDown') {
      this._confirmExitCellForm(() => {
        // Navega para a célula abaixo e caso não tenha mais linhas chama a função de adicionar nova linha
        this.closeAllEditors();
        const currentIndex = this._items().indexOf(row);
        if (currentIndex < this._items().length - 1) {
          const nextRow = this._items()[currentIndex + 1];
          this.onCellClick(nextRow, columnProperty);
        } else {
          // Se for a última linha, adiciona uma nova linha e fecha a edição da célula atual
          this.addNewItem();
        }
      });
    }
  }
  deleteRow(row: any): void {
    // Verifica se todos os campos (exceto os que começam com _) estão vazios
    const hasValues = Object.keys(row).some(
      key => !key.startsWith('_') && row[key] !== '' && row[key] !== null && row[key] !== undefined
    );

    if (!hasValues) {
      // Remove a linha do array (remoção lógica) usando _id para identificar o item
      this._items.update(items => items.filter(item => item._id !== row._id));
    } else {
      // Alterna entre deletado e restaurado
      row._delete = !row._delete;
    }
    this.closeEditor(row);
    // Adicione aqui a lógica para remoção permanente ou restauração se necessário
  }

  // validGrid(): boolean {
  //   return this.formGroups.every(formGroup => formGroup.valid);
  // }

  private _addCellForm(fields: any[]): void {
    const formGroup = new FormGroup({});
    fields.forEach(field => {
      formGroup.addControl(field.property, new FormControl(field.defaultValue || '', this._getValidators(field)));
    });

    // console.warn('formGroup', formGroup);

    this.cellFormGroup = formGroup;
  }

  onChangeField = (field: any) => {
    console.warn('lorem', this.editedCell);
  };

  private _getValidators(field: any): ValidatorFn[] {
    const validators = [];
    if (field.required) validators.push(Validators.required);
    if (field.minLength) validators.push(Validators.minLength(field.minLength));
    if (field.maxLength) validators.push(Validators.maxLength(field.maxLength));
    if (field.pattern) validators.push(Validators.pattern(field.pattern));
    return validators;
  }

  private closeAllEditors(): void {
    this._items().forEach((row: any) => (row._edit = false));
    this.editedCell = { columnProperty: null };
  }

  private closeEditor(row?: any): void {
    if (row) {
      row._edit = false;
    }
    this.editedCell = { columnProperty: null };
  }

  onEditCellMode(event: any): void {
    if (this.editedCell.columnProperty !== null) {
      // Não permite mudar o modo de edição enquanto estiver editando uma célula
      return;
    }

    this.editCellFormMode = event;
    this.closeAllEditors();
  }

  addNewItem() {
    this.editCellModel = 'new';
    // verifica o tipo se for row abre o modal se for cell da mensagem no console
    if (this.editCellFormMode === 'row') {
      this.editedCell = { rowId: undefined, columnProperty: null };
      this.editedRow = null;
      this.editRowModal.open();
    } else {
      // Adiciona uma nova linha ao grid usando a struct também pois são as colunas do grid
      const newRow: any = {};
      let firstProperty = ''; // Pega o primeiro campo da struct para usar como ID
      this.struct?.fields.forEach((field: CustomDynamicFormField, index: number) => {
        if (index === 0) {
          firstProperty = field.property; // Guarda o primeiro campo para usar como ID
        }
        newRow[field.property] = '';
      });

      newRow._id = Math.floor(Math.random() * 1000000); // Gera um ID único para o novo item
      newRow._delete = false;
      newRow._edit = true; // Marca como editável
      this._items.update((items: any[]) => [...items, newRow]);

      // Adiciona o primeiro
      this.editedCell = { rowId: newRow._id, columnProperty: firstProperty };
    }
  }

  // Listener global para tecla ESC
  // @HostListener('document:keydown.escape', ['$event'])
  // handleEscapeKey(event: KeyboardEvent): void {
  //   this.closeAllEditors();
  // }

  // Detecta clique fora do grid quando está editando uma célula
  // @HostListener('document:click', ['$event'])
  // onDocumentClick(event: MouseEvent): void {
  //   if (this.editedCell.columnProperty !== null && this.gridContainer) {
  //     const clickedInside = this.gridContainer.nativeElement.contains(event.target);

  //     console.warn('event.target', event.target);

  //     if (!clickedInside) {
  //       console.warn('s');

  //       this.poDialog.confirm({
  //         title: 'Exclusão dos dados inseridos',
  //         message: 'Você deixou campos obrigatórios em branco. Deseja continuar e apagar o que já foi preenchido?',
  //         confirm: () => {
  //           this.removeRowById(this.editedCell.rowId!);
  //           this.closeAllEditors();
  //           this.closeModal();
  //         },
  //         close: () => {
  //           event.preventDefault();
  //         }
  //       });
  //     }
  //   }
  // }

  private _confirmExitCellForm(validFormCallBack?: () => void, invalidFormCallBack?: () => void): boolean {
    console.warn('_confirmExitEditing');

    if (!this._isCellFormValid()) {
      this.poDialog.confirm({
        title: 'Exclusão dos dados inseridos',
        message: 'Você deixou campos obrigatórios em branco. Deseja continuar e apagar o que já foi preenchido?',
        confirm: () => {
          if (invalidFormCallBack) {
            invalidFormCallBack();
          }
        }
      });
      return false; // Impede a ação de fechar o modal
    } else {
      console.warn('aqui');

      // Se o formulário for válido, chama o callback de confirmação se existir
      if (validFormCallBack) {
        validFormCallBack();
      }
      return true; // Permite a ação de fechar o modal
    }
  }

  private _resetCellForm(): void {
    this.cellFormGroup.reset();
    this.cellFormGroup.markAsPristine();
    this.cellFormGroup.markAsUntouched();
    this.editedCell = { columnProperty: null };
    this.editedRow = null;
  }

  private _isCellFormValid() {
    const formGroup = this.cellFormGroup;
    if (formGroup) {
      console.log(`Valores do formulário:`, formGroup.value);
    }

    return this._validateAllForms();
  }

  private _validateAllForms(): boolean {
    let allValid = true;
    let focused = false;

    const formGroup = this.cellFormGroup;

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
              const invalidControlElement = document.querySelector(`[formControlName="${controlName}"]`) as HTMLElement;
              if (invalidControlElement) {
                invalidControlElement.focus();
                focused = true;
              }
            }
          }
        });
      }
    }

    return allValid;
  }

  private removeRowById(rowId: number): void {
    this._items.update((items: any[]) => items.filter(item => item._id !== rowId));
  }

  private closeModal(): void {
    this.editRowModal.close();
    this.editedCell = { columnProperty: null };
    this.formAlias.clearFormData();
  }


  onCloseModal() {
    this.closeModal();
  }

  onConfirmModal() {
    if (this.editCellModel === 'edit' || this.editCellModel === 'new') {
      this.addNewItemModal();
    }
  }


  private addNewItemModal(): void {
    this.formAlias.isFormValid();

    if (this.formAlias.isFormValid()) {
      const formValue = this.formAlias.getFormData()['FORM' + this.alias];
      console.warn('Form Value:', formValue);
      if (this.editCellModel === 'new') {
        this.addNewItemToSignal(formValue);
      } else if (this.editCellModel === 'edit') {
        this.updateExistingItemInSignal(formValue);
      }
    } else {
      this.poNotification.warning('Preencha todos os campos obrigatórios.');
    }
  }

  private addNewItemToSignal(item: any): void {
    // gera um id randomico unico para o novo item
    const _id = Math.floor(Math.random() * 1000000);
    const newItem = { ...item, _id, _delete: false, _edit: false };
    this._items.update((items: any[]) => [...items, newItem]);
    console.warn(newItem);
    this.closeModal();
  }

  private updateExistingItemInSignal(item: any): void {
    // concatena o item com o editedRow para manter os dados do row

    const updatedItem = { ...this.editedRow, ...item };

    console.warn('updatedItem', updatedItem);

    this._items.update((items: any[]) => {
      const index = items.findIndex(i => i._id === this.editedRow._id); // Use editedRow._id instead of editedCell.rowId
      if (index !== -1) {
        items[index] = { ...items[index], ...updatedItem }; // Merge the updated item with the existing one
      } else {
        console.error('Row not found for update');
      }
      return [...items];
    });
    console.warn('UPDATE', updatedItem);
    this.closeModal();
  }
}
