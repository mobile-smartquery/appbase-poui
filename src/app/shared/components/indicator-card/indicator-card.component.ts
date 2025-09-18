import { Component, Input } from '@angular/core';

@Component({
  standalone: false,
  selector: 'app-indicator-card',
  templateUrl: './indicator-card.component.html',
  styleUrl: './indicator-card.component.scss'
})
export class IndicatorCardComponent {
  @Input() title!: string;
  @Input() valueCount!: string;
  @Input() value!: string;
  @Input() classSize: string = ''

}
