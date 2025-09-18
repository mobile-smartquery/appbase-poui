import { AfterContentInit, Component, Input, ViewChild } from '@angular/core';

@Component({
  standalone: false,
  selector: 'app-collapse',
  templateUrl: './collapse.component.html',
  styleUrl: './collapse.component.scss'
})
export class CollapseComponent implements AfterContentInit {

  @Input() title: string = '';
  @ViewChild('requesterData', {static: true}) requesterData: any;

  constructor() { }

  ngAfterContentInit() {
    this.requesterData.expand();
  }
}
