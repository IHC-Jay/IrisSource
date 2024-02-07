import { Component, EventEmitter, Output } from '@angular/core';
import { KVP } from '../add-edit.component';

@Component({
  selector: 'app-create-note',
  templateUrl: './create-note.component.html',
  styleUrls: ['./create-note.component.css']
})
export class CreateNoteComponent {
  @Output() newNoteSender = new EventEmitter<KVP>();

  key: string = "";
  value: string = "";

  addNote() {
    const newNote: KVP = {
      id: 0,
      Key: this.key,
      Value: this.value
    };
    this.newNoteSender.emit(newNote);
    this.key = "";
    this.value = "";
  }
}
