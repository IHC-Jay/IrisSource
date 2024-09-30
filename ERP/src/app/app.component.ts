import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  public clickedEvent: String;

  title = 'Intermountain ERP Trading Partner Management';
  menuFeature: string = 'tradingpartners';

}
