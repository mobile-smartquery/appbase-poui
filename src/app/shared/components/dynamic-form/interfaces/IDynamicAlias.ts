
export interface iDynamicFormAlias {
  alias: string;
  format: 'form'| 'formWithGrid' | 'grid'; // tipo de formulário
  gridAlias?: string; // alias do grid, se o tipo for 'formWithGrid'
  title?: string; // título do formulário
}
