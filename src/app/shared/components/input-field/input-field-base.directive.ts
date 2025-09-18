import { TitleCasePipe } from '@angular/common';
import { Directive, Input } from '@angular/core';
import { PoComboFilter, PoDynamicFieldType, PoDynamicFormField, PoLookupFilter, PoMultiselectFilter } from '@po-ui/ng-components';
import { isTypeof } from '../../utils/utils';

@Directive({
  selector: '[appInputFieldBase]'
})
export class InputFieldBaseDirective {
  @Input() autoFocus: string = '';

  constructor(private titleCasePipe: TitleCasePipe) {
    // this.getVisibleFields();
  }

  // protected getVisibleFields() {
  //   console.warn(this.field);

  //   // const t = this.createField(this.field);
  //   // console.warn(t);
  // }

  // converte um array em string para um array de objetos que contem label e value.
  private convertOptions(options: Array<any>): Array<{ label: string; value: string }> {
    const everyOptionString = options.every(option => typeof option === 'string');

    if (everyOptionString) {
      return options.map(value => ({ label: value, value }));
    }

    return options;
  }

  private hasFocus(field: PoDynamicFormField) {
    return !!this.autoFocus && this.autoFocus === field.property;
  }

  // cria um novo objeto com as classes de grid system, com control (tipo do componente) e label default.
  protected createField(field: PoDynamicFormField): PoDynamicFormField {
    const control = this.getComponentControl(field);
    const options = !!field.options ? this.convertOptions(field.options) : undefined;
    const focus = this.hasFocus(field);
    const type = field && field.type ? field.type.toLocaleLowerCase() : 'string';

    const componentClass = getGridColumnsClasses(
      field.gridColumns,
      field.offsetColumns,
      {
        smGrid: field.gridSmColumns,
        mdGrid: field.gridMdColumns,
        lgGrid: field.gridLgColumns,
        xlGrid: field.gridXlColumns
      },
      {
        smOffset: field.offsetSmColumns,
        mdOffset: field.offsetMdColumns,
        lgOffset: field.offsetLgColumns,
        xlOffset: field.offsetXlColumns
      },
      {
        smPull: field.gridSmPull,
        mdPull: field.gridMdPull,
        lgPull: field.gridLgPull,
        xlPull: field.gridXlPull
      }
    );

    return {
      label: this.titleCasePipe.transform(field.property),
      maskFormatModel: this.compareTo(type, PoDynamicFieldType.Time),
      ...field,
      componentClass,
      control,
      errorMessage: `O campo é obrigatório.`,
      focus,
      options
    } as any;
  }

  private verifyForceOptionComponent(field: PoDynamicFormField) {
    const { optionsMulti, optionsService, forceOptionsComponentType } = field;

    if (forceOptionsComponentType && !optionsMulti && !optionsService) {
      return true;
    }
    return false;
  }

  private getComponentControl(field: PoDynamicFormField = <any>{}) {
    const type = field && field.type ? field.type.toLocaleLowerCase() : 'string';

    const { forceBooleanComponentType } = field;
    const forceOptionComponent = this.verifyForceOptionComponent(field);

    if (forceBooleanComponentType) {
      return forceBooleanComponentType;
    }

    if (forceOptionComponent) {
      const { forceOptionsComponentType } = field;
      return forceOptionsComponentType;
    }

    if (this.isNumberType(field, type)) {
      return 'number';
    } else if (this.isCurrencyType(field, type) || type === PoDynamicFieldType.Decimal) {
      return 'decimal';
    } else if (this.isSelect(field)) {
      return 'select';
    } else if (this.isRadioGroup(field)) {
      return 'radioGroup';
    } else if (this.isCheckboxGroup(field)) {
      return 'checkboxGroup';
    } else if (this.isMultiselect(field)) {
      return 'multiselect';
    } else if (this.compareTo(type, PoDynamicFieldType.Boolean)) {
      return 'switch';
    } else if (this.compareTo(type, PoDynamicFieldType.Date) || this.compareTo(type, PoDynamicFieldType.DateTime)) {
      return field.range ? 'datepickerrange' : 'datepicker';
    } else if (this.compareTo(type, PoDynamicFieldType.Time)) {
      field.mask = field.mask || '99:99';

      return 'input';
    } else if (this.isCombo(field)) {
      return 'combo';
    } else if (this.isLookup(field)) {
      return 'lookup';
    } else if (this.isTextarea(field)) {
      return 'textarea';
    } else if (this.isPassword(field)) {
      return 'password';
    } else if (this.isUpload(field)) {
      return 'upload';
    }

    return 'input';
  }

  private isSelect(field: PoDynamicFormField) {
    const { optionsMulti, options } = field;

    return !optionsMulti && !!options && options.length > 3;
  }

  compareTo(value: any, compareTo: any): boolean {
    return value === compareTo;
  }

  private isCheckboxGroup(field: PoDynamicFormField) {
    const { optionsService, optionsMulti, options } = field;

    return !optionsService && optionsMulti && !!options && options.length <= 3;
  }

  private isCombo(field: PoDynamicFormField) {
    const { optionsService } = field;

    return !!optionsService && (isTypeof(optionsService, 'string') || this.isComboFilter(optionsService));
  }

  private isCurrencyType(field: PoDynamicFormField, type: string) {
    const { mask, pattern } = field;

    return this.compareTo(type, PoDynamicFieldType.Currency) && !mask && !pattern;
  }

  private isLookupFilter(object: any): object is PoLookupFilter {
    return object && (<PoLookupFilter>object).getObjectByValue !== undefined;
  }

  private isComboFilter(object: any): object is PoComboFilter {
    return object && (<PoComboFilter>object).getFilteredData !== undefined;
  }

  private isLookup(field: PoDynamicFormField) {
    const { searchService } = field;

    return !!searchService && (isTypeof(searchService, 'string') || this.isLookupFilter(searchService));
  }

  private isMultiselect(field: PoDynamicFormField) {
    const { optionsService, optionsMulti, options } = field;

    return optionsMulti && (!!optionsService || (!!options && options.length > 3));
  }

  private isNumberType(field: PoDynamicFormField, type: string) {
    const { mask, pattern } = field;

    return this.compareTo(type, PoDynamicFieldType.Number) && !mask && !pattern;
  }

  private isPassword(field: PoDynamicFormField) {
    const { secret } = field;

    return secret;
  }

  private isTextarea(field: PoDynamicFormField) {
    const { rows } = field;

    return rows && rows >= 3;
  }

  private isRadioGroup(field: PoDynamicFormField) {
    const { optionsMulti, options } = field;

    return !optionsMulti && !!options && options.length <= 3;
  }

  private isUpload(field: PoDynamicFormField) {
    const { url, type } = field;

    return url && type === 'upload';
  }
}

export function getGridColumnsClasses(
  gridColumns: number | undefined,
  offsetColumns: number | undefined,
  grid: { smGrid?: number; mdGrid?: number; lgGrid?: number; xlGrid?: number } | undefined,
  offset: { smOffset?: number; mdOffset?: number; lgOffset?: number; xlOffset?: number } | undefined,
  pull: { smPull?: number; mdPull?: number; lgPull?: number; xlPull?: number } | undefined
) {
  const systemGrid = {
    gridSm: grid?.smGrid || gridColumns || 12,
    gridMd: grid?.mdGrid || gridColumns || 6,
    gridLg: grid?.lgGrid || gridColumns || 4,
    gridXl: grid?.xlGrid || gridColumns || 3,
    offsetSm: offset?.smOffset || offsetColumns || 0,
    offsetMd: offset?.mdOffset || offsetColumns || 0,
    offsetLg: offset?.lgOffset || offsetColumns || 0,
    offsetXl: offset?.xlOffset || offsetColumns || 0,
    pullSm: pull?.smPull || 0,
    pullMd: pull?.mdPull || 0,
    pullLg: pull?.lgPull || 0,
    pullXl: pull?.xlPull || 0
  };

  return (
    `po-sm-${systemGrid.gridSm} po-offset-sm-${systemGrid.offsetSm} po-pull-sm-${systemGrid.pullSm} ` +
    `po-md-${systemGrid.gridMd} po-offset-md-${systemGrid.offsetMd} po-pull-md-${systemGrid.pullMd} ` +
    `po-lg-${systemGrid.gridLg} po-offset-lg-${systemGrid.offsetLg} po-pull-lg-${systemGrid.pullLg} ` +
    `po-xl-${systemGrid.gridXl} po-offset-xl-${systemGrid.offsetXl} po-pull-xl-${systemGrid.pullXl}`
  );
}

