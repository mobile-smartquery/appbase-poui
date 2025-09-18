import { Component, Input, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { Subject } from 'rxjs';
import { debounceTime } from 'rxjs/operators';

@Component({
  standalone: false,
  selector: 'app-search-table',
  templateUrl: './search-table.component.html',
  styleUrls: ['./search-table.component.css'],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => SearchTableComponent),
      multi: true
    }
  ]
})
export class SearchTableComponent implements ControlValueAccessor {
  @Input() classSize: string = "po-md-3";
  @Input() placeholder: string = "placeholder";
  @Input() label: string = "";
  @Input() search!: (search?: string) => void;

  searchText: string = "";

  private searchTerms = new Subject<string>();

  /* istanbul ignore next */
  constructor() {
    this.searchTerms.pipe(debounceTime(800)).subscribe((searchTerm) => {
      this.search(searchTerm);
    });
  }

  onChange() {
    this.searchTerms.next(this.searchText);
    this.onChangeCallback(this.searchText);
  }

  clearSearch() {
    this.searchText = '';
    this.searchTerms.next('');
    this.onChangeCallback(this.searchText);
  }

  // ControlValueAccessor interface methods
  private onChangeCallback: (_: any) => void = () => {};
  private onTouchedCallback: () => void = () => {};

  writeValue(value: any): void {
    this.searchText = value || '';
  }

  registerOnChange(fn: any): void {
    this.onChangeCallback = fn;
  }

  registerOnTouched(fn: any): void {
    this.onTouchedCallback = fn;
  }

  /* istanbul ignore next */
  setDisabledState(isDisabled: boolean): void {
    // not implemented
  }
}
