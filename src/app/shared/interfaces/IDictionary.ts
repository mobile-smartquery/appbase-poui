export interface IStruct {
  from_sx3: boolean;
  required: boolean;
  order: string;
  virtual: boolean;
  mask: string;
  dynamic_mask: string;
  options: any[];
  title: string;
  validation: string;
  level: number;
  enabled: boolean;
  id: string;
  agrup_title: string;
  type: string;
  size: number;
  decimals: number;
  description: string;
  standard_query: string;
  default: string;
}

export interface IDictionaryResponse {
  struct: IStruct[];
}

export interface IBrowserColumns {
  field: string;
  title: string;
  type: string;
}

export interface IFieldsSheetsColumns {
  fields: any[];
  sheets?: any[];
  columns?: any[];
}
