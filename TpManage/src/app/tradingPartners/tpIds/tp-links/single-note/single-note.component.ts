import { Component, EventEmitter, Input, Output } from '@angular/core';
import { KVP } from '../add-edit.component';
import { tpLinks } from '../tp-links';

@Component({
  selector: 'app-single-note',
  templateUrl: './single-note.component.html',
  styleUrls: ['./single-note.component.css']
})
export class SingleNoteComponent {
  @Input() customProp: KVP[];
  @Input() singleNote: KVP;

  constructor()
  {
    console.info("SingleNoteComponent");

  }

  @Output('customPropChange') customPropChange: EventEmitter<
    KVP[]
  > = new EventEmitter();

  deleteNote(singleNote: KVP) {
    this.customProp = this.customProp.filter(e => e !== singleNote);
    this.customPropChange.emit(this.customProp);
  }
}
