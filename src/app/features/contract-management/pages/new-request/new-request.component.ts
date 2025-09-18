import { AfterContentInit, Component, OnInit, viewChild, ViewChild } from '@angular/core';
import { SharedModule } from '../../../../shared/shared.module';
import { PoStepperComponent, PoStepperItem, PoStepperStatus } from '@po-ui/ng-components';

@Component({
  selector: 'app-new-request',
  imports: [SharedModule],
  templateUrl: './new-request.component.html',
  styleUrl: './new-request.component.scss'
})
export class NewRequestComponent implements OnInit, AfterContentInit {

  @ViewChild('requesterData', {static: true}) requesterData: any;

  currentStep!: number;
  stepsWithStatus: Array<PoStepperItem> = [
    { label: 'Step 1', status: PoStepperStatus.Active },
    { label: 'Step 2', status: PoStepperStatus.Default },
    { label: 'Step 3', status: PoStepperStatus.Default },
    { label: 'Step 4', status: PoStepperStatus.Default }
  ];

  constructor() { }

  ngOnInit(): void {

  }

  ngAfterContentInit() {
    this.requesterData.expand();
  }

}
