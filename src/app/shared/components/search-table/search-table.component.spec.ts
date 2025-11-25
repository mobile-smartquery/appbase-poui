import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';

import { SearchTableComponent } from './search-table.component';
import { PoI18nModule, PoModule } from '@po-ui/ng-components';
import { CommonModule } from '@angular/common';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { i18nConfig } from '../../../core/services/literals.service';
import { ComponentsModule } from '../components.module';
import { Subject, of } from 'rxjs';
import { NG_VALUE_ACCESSOR } from '@angular/forms';

describe('SearchTableComponent', () => {
  let component: SearchTableComponent;
  let fixture: ComponentFixture<SearchTableComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [
        PoModule,
        CommonModule,
        PoI18nModule.config(i18nConfig),
        HttpClientTestingModule,
        ComponentsModule
      ],
      declarations: [SearchTableComponent],
      providers: [
        {
          provide: NG_VALUE_ACCESSOR,
          useExisting: SearchTableComponent,
          multi: true
        }
      ]
    });
    fixture = TestBed.createComponent(SearchTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();

    component.search = (search?: string) => {
      return of([]);
    };
  });

  it('deve ser criado', () => {
    expect(component).toBeTruthy();
  });

  it('deve ter tamanho de classe padrão', () => {
    expect(component.classSize).toEqual('po-md-3');
  });

  it('deve ter NG_VALUE_ACCESSOR configurado corretamente', () => {
    const providers = fixture.debugElement.injector.get(NG_VALUE_ACCESSOR);
    expect(providers).toBeTruthy();
    expect(providers.some(provider => provider === component)).toBeTrue();
  });

  it('deve ter placeholder padrão', () => {
    expect(component.placeholder).toEqual('placeholder');
  });

  it('deve chamar o método search quando o searchText mudar', () => {
    const searchSpy = spyOn(component, 'search').and.callThrough();
    component.searchText = 'test';
    component.onChange();
    component.search('test');
    expect(searchSpy).toHaveBeenCalledWith('test');
  });

  it('deve emitir o termo de pesquisa na mudança', () => {
    const searchTerm = 'RATEIO 01';
    const searchTerms = new Subject<string>();
    component['searchTerms'] = searchTerms;
    component.searchText = searchTerm;
    spyOn<any>(component['searchTerms'], 'next').and.callThrough();
    component.onChange();
    expect(component['searchTerms'].next).toHaveBeenCalledWith(searchTerm);
  });

  it('deve limpar o searchText e chamar o método search quando clearSearch for chamado', () => {
    const searchSpy = spyOn(component, 'search').and.callThrough();
    component.searchText = 'test';
    component.clearSearch();
    component.search('');
    expect(component.searchText).toEqual('');
    expect(searchSpy).toHaveBeenCalledWith('');
  });

  it('deve atualizar searchText no writeValue', () => {
    component.writeValue('teste');
    expect(component.searchText).toBe('teste');

    component.writeValue('');
    expect(component.searchText).toBe('');
  });

  it('deve registrar onChangeCallback no registerOnChange', () => {
    const fn = jasmine.createSpy('onChangeCallback');
    component.registerOnChange(fn);
    expect(component['onChangeCallback']).toBe(fn);
  });

  it('deve registrar onTouchedCallback no registerOnTouched', () => {
    const fn = jasmine.createSpy('onTouchedCallback');
    component.registerOnTouched(fn);
    expect(component['onTouchedCallback']).toBe(fn);
  });
});
