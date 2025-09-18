import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ContractCenterComponent } from './contract-center.component';

describe('ContractCenterComponent', () => {
  let component: ContractCenterComponent;
  let fixture: ComponentFixture<ContractCenterComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ContractCenterComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ContractCenterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
