import { ComponentFixture, TestBed } from '@angular/core/testing';

import { IndicatorCardComponent } from './indicator-card.component';

describe('IndicatorCardComponent', () => {
  let component: IndicatorCardComponent;
  let fixture: ComponentFixture<IndicatorCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [IndicatorCardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(IndicatorCardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
