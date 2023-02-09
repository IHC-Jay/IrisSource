import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';

import { FormsModule,  FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import {TradingPartner} from '../tradingPartners/TradingPartner';
import {TpId, TpIdColumns} from '../tradingPartners/tpIds/TpId';
import {tpLinks} from '../tradingPartners/tpIds/tp-links/tp-links';
import {RestServiceComponent} from '../services/rest-service.component';
import { MatTableDataSource, MatTableDataSourcePaginator } from '@angular/material/table';
import {
  AUTO_STYLE,
  animate,
  state,
  style,
  transition,
  trigger
} from '@angular/animations';
const DEFAULT_DURATION = 300;
@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css'],
  animations: [
    trigger('collapse', [
      state('false', style({ height: AUTO_STYLE, visibility: AUTO_STYLE })),
      state('true', style({ height: '0', visibility: 'hidden' })),
      transition('false => true', animate(DEFAULT_DURATION + 'ms ease-in')),
      transition('true => false', animate(DEFAULT_DURATION + 'ms ease-out'))
    ])
  ]
})

export class SearchComponent implements OnInit {

  loading:boolean = false;
  selectedTpId ='';
  form!: FormGroup;

  canRenderDetails = false;
  selectedTp:string = '';

  dataSource: TpId[] = [];
  loadedPosts: tpLinks[] = [];

  @ViewChild("searchTpId") focusField: ElementRef;


  constructor(private TradingPartnerService: RestServiceComponent,
    private formBuilder: FormBuilder
  ){

    this.form =new FormGroup({
      tpId: new FormControl()
    });

  }

  async ngOnInit() {

    this.form = this.formBuilder.group({
      searchTpId: ['', Validators.required]

  });


    }
    ngAfterViewInit() {
      this.focusField.nativeElement.focus();
    }


    onTpIdChange()
    {
      console.info('TpId changed');
     let searchTpIdVal = this.form.controls.searchTpId.value.toString().trim();

     console.info('searchTpIdVal: ' + searchTpIdVal);
    console.info(searchTpIdVal);


    this.loadedPosts = [];
    this.dataSource = [];
    this.collapse();
    this.loading = true;
    this.selectedTp = '';

    this.TradingPartnerService.fetchTPforTpId(searchTpIdVal).subscribe((res: any) => {
      console.info('onTpIdChange: ' + res.Name);
      this.selectedTp = res.Name;
      var tp:TpId  = {id:'0', Name:'1', TPID: searchTpIdVal, Type:'BOTH', isEdit:false, isSelected:false};

      this.dataSource.push( tp);

      this.TradingPartnerService.fetchTpLinks(searchTpIdVal).subscribe(
        tpLinksData => {
          this.loadedPosts = tpLinksData;
          this.canRenderDetails = true;
          this.loading = false;
        },
        error => {
          console.error( error.message);
          this.loading = false;
        }
      );

    });


    }
    clearDetails()
    {
      this.canRenderDetails = false;
    }

    collapsed = true;

    toggle() {
      this.collapsed = !this.collapsed;
    }

    expand() {
      this.collapsed = false;
    }

    collapse() {
      this.collapsed = true;
      window.scrollTo(0, 0);
    }

}
