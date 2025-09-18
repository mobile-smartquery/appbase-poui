import { of } from "rxjs";
import { CoreService } from "../../core/services/core.service";
import { PoDatepickerIsoFormat, PoDynamicFormField } from "@po-ui/ng-components";

export interface CustomDynamicFormField extends PoDynamicFormField {
  existTrigger?: boolean;
  agrup?: string;
  alias: string;
}

export class Utils {

  static getType(type: string): string {
    const types = {
      C: 'string',
      N: 'number',
      D: 'date',
      L: 'boolean',
    };

    return types[type as keyof typeof types] || 'string';
  }

  static mapBrowseData(response: any, coreService: CoreService, validLook = false): Array<any> {
    return this.mapGridColumns(response, coreService, validLook);
  }

  /**
   * Mapeia as colunas da grade com base na resposta e no serviço fornecido.
   * @param response Resposta contendo a estrutura das colunas.
   * @param coreService Serviço base para interações.
   * @returns Array de colunas mapeadas.
   */
  static mapGridColumns(response: any, coreService: CoreService, validLook = false): Array<any> {
    let currentRowWidth = 0;

    let fields = response.struct
      .filter((col: any) => !col.field.includes('_FILIAL'))
      .map((col: any) => {
        const { gridColumns, gridSmColumns } = this.calculateGridSizes(col, currentRowWidth);

        if (currentRowWidth + gridColumns > 12) {
          currentRowWidth = 0;
        }
        currentRowWidth += gridColumns;

        const map = this.createColumnMap(col, gridColumns, gridSmColumns, coreService, validLook);

        return map;
      })

    // verifica se foi passando o response.agrups
    if (response.agrups && response.agrups.length > 0) {
      // Adiciona o agrupador divider
      fields = this.addDivider(fields, response.agrups);
    }

    return fields;
  }


  // metodo statico privado para adicionar o agrupador divider
  static addDivider(fields: any[], agrups: any){
    const dividers: Map<string, string> = new Map();

    // Ordena os fields de acordo com o order do agrupador correspondente
    fields.sort((a: any, b: any) => {
      const agrupA = agrups.find((agrup: any) => agrup.id === a.agrup_id);
      const agrupB = agrups.find((agrup: any) => agrup.id === b.agrup_id);

      const orderA = agrupA ? agrupA.order : Number.MAX_SAFE_INTEGER;
      const orderB = agrupB ? agrupB.order : Number.MAX_SAFE_INTEGER;

      return orderA - orderB;
    });

    // Pecorre os fields dando um map para adicionar o agrupador divider
    return fields.map((item: any) => {
      const struct: any = {
        ...item,
        divider: '',
      };

      // Adiciona o agrupador divider, não pode estar nos dividers
      if (item.agrup_id && !dividers.has(item.agrup_id)) {
        // Pega o titulo correspondente ao item.agrup_id
        const agrupTitle = agrups.find((agrup: any) => agrup.id === item.agrup_id)?.title;
        struct.divider = agrupTitle;
        dividers.set(item.agrup_id, agrupTitle);
      } else if (!item.agrup_id && !dividers.has('Outros')) {
        struct.divider = 'Outros';
        dividers.set('Outros', 'Outros');
      }
      return struct;
    });

  }


  /**
   * Calcula os tamanhos das colunas da grade com base no tamanho e nas opções.
   * @param col Coluna a ser avaliada.
   * @param currentRowWidth Largura atual da linha.
   * @returns Tamanhos calculados para gridColumns e gridSmColumns.
   */
  private static calculateGridSizes(col: any, currentRowWidth: number): { gridColumns: number; gridSmColumns: number } {
    let gridColumns = 3;
    let gridSmColumns = 6;

    if (col.size > 120) {
      gridColumns = 6;
      gridSmColumns = 12;
    } else if (col.options.length > 0) {
      gridColumns = Math.min(12, Math.max(3, Math.ceil(col.options.length / 10)));
      gridSmColumns = Math.min(12, Math.max(6, Math.ceil(col.options.length / 10)));
    } else if (col.size > 20) {
      gridColumns = Math.min(12, Math.max(3, Math.ceil(col.size / 10)));
      gridSmColumns = Math.min(12, Math.max(6, Math.ceil(col.size / 10)));
    }

    // if (col.options.length > 0) {
    //   gridColumns = 3
    //   gridSmColumns = Math.min(12, Math.max(6, Math.ceil(col.options.length / 10)));
    // }

    return { gridColumns, gridSmColumns };
  }

  /**
   * Cria o mapeamento de uma coluna com base nos dados fornecidos.
   * @param col Coluna a ser mapeada.
   * @param gridColumns Tamanho da coluna na grade.
   * @param gridSmColumns Tamanho da coluna na grade para telas menores.
   * @param coreService Serviço base para interações.
   * @returns Objeto mapeado da coluna.
   */
  private static createColumnMap(col: any, gridColumns: number, gridSmColumns: number, coreService: CoreService, validLook = false): any {
    const map: any = {
      property: col.field || 'defaultField',
      label: col.title || 'Default Title',
      type: Utils.getType(col.type || 'C'),
      required: !!col.required,
      showRequired: !!col.required,
      alias: col.alias || undefined,
      minLength: 1,
      virtual: !!col.virtual,
      maxLength: col.size || 50,
      decimalsLength: col.decimals || 0,
      gridColumns,
      // isoFormat: PoDatepickerIsoFormat.Basic,
      gridSmColumns,
      additionalHelpTooltip: col.help || 'UVA',
      existTrigger: !!col.exist_trigger,
      visible: col.enabled !== undefined ? col.enabled : true,
      disabled: col.editable !== undefined ? !col.editable : false,
      divider: '',
      sx3_order: col.order || 999,
      folder: col.folder || undefined,
      agrup_id: col.agrup || '',
    };

    // Se possui col.decimals > 0, adiciona o formato de moeda
    if (col.decimals && col.decimals > 0) {
      map.type = 'decimal';
      map.decimalsLength = col.decimals;
    }

    if (col.type === 'M') {
      map.rows = 5;
    }

    if (col.standard_query) {
      Utils.addStandardQueryDetails(map, col, coreService, validLook);
    }

    if (col.options.length > 0) {
      map.options = col.options;
    }

    return map;
  }

  /**
   * Adiciona detalhes de consulta padrão ao mapeamento da coluna.
   * @param map Objeto de mapeamento da coluna.
   * @param col Coluna com detalhes de consulta padrão.
   * @param coreService Serviço base para interações.
   */
  private static addStandardQueryDetails(map: any, col: any, coreService: CoreService, validLook = false): void {


    if (col.standard_query_detail) {
      const indexes: Array<string> = col.standard_query_detail.columns.map((col: any) => col.field);

      map.columns = col.standard_query_detail.columns.map((col: any) => ({
        property: String(col.field).toLowerCase(),
        label: col.title,
      }));

      const fieldValue = String(col.standard_query_detail.get_column_value).toLowerCase();
      map.fieldLabel = fieldValue;
      map.fieldValue = fieldValue;

      map.searchService = {
        getObjectByValue(value: string) {
          return of({ [fieldValue]: value });
        },
        getFilteredItems: (filter: any) => {
          return coreService.getLookup(
            col.standard_query_detail.lookup,
            { ...filter, idx: JSON.stringify(indexes) }
          );
        },
      };

      // se o validLook for true, adiciona o getObjectByValue
      if (validLook) {
        map.searchService.getObjectByValue = (value: string) => {
          return coreService.getLookupById(
            col.standard_query_detail.lookup,
            value,
            col.standard_query_detail.get_column_value
          );
        };
      }

    } else {
      console.log('=====================>CONSULTA COMPOSTA SEM DETALHES', col);
    }
  }

  /**
   * Mapeia os campos fornecidos para o formato esperado.
   * @param struct Estrutura a ser mapeada.
   * @param coreService Serviço base para interações.
   * @returns Array de campos mapeados.
   */
  static mapFields(struct: any, coreService: CoreService, validLook = false): Array<any> {
    return Utils.mapGridColumns(struct, coreService, validLook);
  }

  /**
   * Mapeia as pastas com base na resposta e no serviço fornecido.
   * @param response Resposta contendo as pastas e estrutura.
   * @param coreService Serviço base para interações.
   * @returns Array de pastas mapeadas.
   */
  static mapFolders(response: any, coreService: CoreService, validLook = false): Array<any> {
    const folders = response.folders.map((folder: any) => {
      const folderFields = response.struct.filter((field: any) => field.folder === folder.id && !field.field.includes('_FILIAL'));
      return {
        id: folder.id,
        title: folder.title,
        fields: Utils.mapFields({...response, struct: folderFields}, coreService, validLook),
      };
    });

    const otherFields = response.struct.filter((field: any) => !field.folder && !field.field.includes('_FILIAL'));
    if (otherFields.length > 0 && response.folders.length > 0) {
      folders.push({
        id: 'outros',
        title: 'Outros',
        fields: Utils.mapFields({...response, struct: otherFields}, coreService, validLook),
      });
    }

    return folders;
  }

  /**
   * Mapeia a definição de visualização com base na resposta e no serviço fornecido.
   * @param response Resposta contendo a estrutura e pastas.
   * @param coreService Serviço base para interações.
   * @returns Objeto contendo campos, pastas e colunas mapeadas.
   */
  static mapViewDef(response: any, coreService: CoreService, validLook = false): { fields: any[], sheets: any[], columns: any[] } {

    // Remove o campo filial
    response.struct = response.struct.filter((col: any) => !col.field.includes('_FILIAL'));

    const fields = this.mapFields(response, coreService, validLook);
    const sheets = this.mapFolders(response, coreService, validLook);
    const columns = fields

    return { fields, sheets, columns };
  }

}

// função que recebe o evento do keydown e formata o campo do tipo time para o formato HH:mm:ss
export function formatTimeInput(event: KeyboardEvent, input: HTMLInputElement): void {
  const value = input.value.replace(/[^0-9]/g, ''); // Remove caracteres não numéricos
  let formattedValue = '';

  if (value.length >= 2) {
    formattedValue += value.slice(0, 2) + ':'; // Adiciona os primeiros dois dígitos como horas
  }
  if (value.length >= 4) {
    formattedValue += value.slice(2, 4) + ':'; // Adiciona os próximos dois dígitos como minutos
  }
  if (value.length >= 6) {
    formattedValue += value.slice(4, 6); // Adiciona os últimos dois dígitos como segundos
  }

  input.value = formattedValue;
}

// Permite apenas números
export function allowOnlyNumbers(event: KeyboardEvent): boolean {
  const key = event.key;
  // Permite teclas de controle como Backspace, Delete, Arrow keys, etc.
  if (['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab'].includes(key)) {
    return true;
  }
  // Permite números e ponto decimal
  if (/^\d$/.test(key) || key === '.') {
    return true;
  }
  // Impede a entrada de outros caracteres
  event.preventDefault();
  return false;
}

export function isTypeof(object: any, type: string): boolean {
  return typeof object === type;
}
