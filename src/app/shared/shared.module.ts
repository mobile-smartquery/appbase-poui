import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SearchTableComponent } from './components/search-table/search-table.component';
import { PoModule } from '@po-ui/ng-components';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { IndicatorCardComponent } from './components/indicator-card/indicator-card.component';
import { ToolbarComponent } from './components/toolbar/toolbar.component';
import { CollapseComponent } from './components/collapse/collapse.component';
import { BrowseComponent } from './components/browse/browse.component';
import { PoTemplatesModule } from '@po-ui/ng-templates';
import { DynamicFormModule } from './components/dynamic-form/dynamic-form.module';
import { GridFormModule } from './components/grid-form/grid-form.module';

@NgModule({
  declarations: [
    SearchTableComponent,
    IndicatorCardComponent,
    ToolbarComponent,
    CollapseComponent,
    BrowseComponent,
  ],
  imports: [
    CommonModule,
    PoModule,
    PoTemplatesModule,
    FormsModule,
    ReactiveFormsModule,
    DynamicFormModule,
    GridFormModule,
  ],
  exports: [
    CommonModule,
    SearchTableComponent,
    IndicatorCardComponent,
    ToolbarComponent,
    CollapseComponent,
    PoModule,
    BrowseComponent,
    DynamicFormModule,
    GridFormModule,
  ],
})
export class SharedModule {}
