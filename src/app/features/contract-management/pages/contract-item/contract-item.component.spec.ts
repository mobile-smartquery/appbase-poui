import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ContractItemComponent } from './contract-item.component';

describe('ContractItemComponent', () => {
  let component: ContractItemComponent;
  let fixture: ComponentFixture<ContractItemComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ContractItemComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ContractItemComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
