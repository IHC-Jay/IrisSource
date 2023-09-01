import { Component, EventEmitter, Input, Output } from '@angular/core';
import { INotesData } from '../add-edit.component';
import { tpLinks } from '../tp-links';

@Component({
  selector: 'app-single-note',
  templateUrl: './single-note.component.html',
  styleUrls: ['./single-note.component.css']
})
export class SingleNoteComponent {
  @Input() allNotes: INotesData[];
  @Input() singleNote: INotesData;

  constructor()
  {
    console.info("SingleNoteComponent");

  }

  @Output('allNotesChange') allNotesChange: EventEmitter<
    INotesData[]
  > = new EventEmitter();

  deleteNote(singleNote: INotesData) {
    this.allNotes = this.allNotes.filter(e => e !== singleNote);
    this.allNotesChange.emit(this.allNotes);
  }
}
